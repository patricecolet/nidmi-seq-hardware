# Architecture matérielle — NiDMI Seq

> Document vivant. Décisions actées avec l'utilisateur ; certaines restent à
> trancher (marquées **À FIGER**).

## Schéma bloc

```
                              ┌─────────────────────────┐
                              │      ESP32-S3            │
                              │  (dual-core, USB natif)  │
                              └─────────────────────────┘
        I2C (2 fils) ────────────┤ SDA/SCL          SPI ├──── TFT ~320×240 (SCK,MOSI,CS,DC,RST,BL)
             │                   │                       │
    ┌────────┼────────┐          │              UART TX ├──── MIDI OUT (TRS-A ou DIN5)
    │        │        │          │              UART RX ├──── MIDI IN (via opto 6N138/H11L1)
 MCP23017 MCP23017 MCP23017      │                       │
  (0x20)   (0x21)   (0x22)       │           1 GPIO data├──── SK6812 RGB (1 bus, ≥16 → 27+)
   37 entrées (sur 48)           │                       │
    │        │        │          │     8 GPIO (PCNT A/B) ├──── 4 encodeurs (quadrature)
 28 touches  5 transport         │                       │
 (16+11+⇧)   4 push-encodeurs    └── INT ────────────────┘  (réveil sur appui)
```

## Décisions actées

### Module : ESP32-S3-WROOM-1-N16R8 (16 Mo flash + 8 Mo PSRAM octale)
- **La PSRAM additionnelle est non-négociable** (banque de patterns, cahier §11.2) :
  s'en passer risquerait de bloquer le projet. On garde donc les **8 Mo**.
- 8 Mo ⇒ **PSRAM octale (R8)** ⇒ réserve en interne **GPIO 26-37** (flash + PSRAM).
- **Sans conséquence ici** : les 37 boutons sont sur I2C, donc seuls ~20 GPIO sont
  requis pour ~25 exploitables sur le N16R8 → marge confortable (voir budget GPIO).

### Budget GPIO ESP32-S3 (N16R8, pins 26-37 réservés exclus)
| Fonction                  | GPIO                         | Nb |
|---------------------------|------------------------------|----|
| I2C (3× MCP23017)         | SDA, SCL                     | 2  |
| TFT SPI                   | SCK, MOSI, CS, DC, RST, BL   | 6  |
| MIDI UART                 | TX, RX                       | 2  |
| SK6812 data               | 1 ligne                      | 1  |
| Encodeurs quadrature A/B  | 4× (A+B)                     | 8  |
| MCP INT (chaîné)          | 1 ligne                      | 1  |
| **Total requis**          |                              | **20** |
| USB-MIDI                  | D-/D+ (19,20 natifs)         | (2)|
| **Exploitables N16R8**    | hors 0/3/45/46 (strap), 19/20 (USB), 43/44 (UART0) | **~25** |

Affectation provisoire (à figer avec le contrôleur TFT exact) — éviter strapping
(0,3,45,46), flash/PSRAM (26-37), USB (19,20) :
- I2C : SDA=8, SCL=9 · TFT(FSPI) : SCK=12, MOSI=11, CS=10, DC=13, RST=14, BL=21
- MIDI : TX=17, RX=18 · SK6812 : 47 · INT MCP : 38
- Encodeurs A/B : 1,2,4,5,6,7,15,16 · USB-MIDI : 19,20

### Lecture des touches : expandeurs I2C MCP23017 (×3)
- Bus I2C = 2 fils ; jusqu'à 8 MCP23017 (adr. 0x20→0x27 via leurs broches A0/A1/A2).
- **3× MCP23017 = 48 entrées** pour 37 boutons → marge confortable (0x20/0x21/0x22).
- **Pull-ups internes** → boutons câblés `pin → bouton → GND`, zéro composant externe.
- Broche **INT** → l'ESP32 ne fait pas de polling, réveil sur changement d'état.
- **NKRO natif** (cf. §10.6 cahier) : 1 broche dédiée par bouton → lecture du port
  complet, **16 touches simultanées sans ghosting, sans diodes**. Mieux que la
  « matrice de scan » évoquée au cahier (qui imposerait des diodes anti-ghosting).

### Touches : boutons-poussoirs PB86, on/off (pas de vélocité au doigt)
- **PB86** : poussoir rond panel-mount (~12 mm, écrou), momentané. Stock dispo en
  **A0 (sans LED)**, **A1 (LED mono)**, **A2 (LED bi-couleur)**.
- Câblage MCP23017 `pin → bouton → GND` (pull-up interne) ; pas d'ADC, pas de matrice.
- `StepData.velocity` reste **éditable à l'encodeur** (réglage par pas), pas joué.
  → à refléter dans le cahier des charges du VST.

#### Affectation variante PB86 → rôle (piloté par cahier §10.3–10.5)
- **16 blanches (pas)** → **A0 (sans LED)** + SK6812 RGB séparées. Le §10.5 **exige**
  du RGB adressable (4 couches × couleur + pas actif + sub) ; les LED intégrées
  A1/A2 ne savent pas le faire. Mettre A1/A2 ici = gâchis.
- **11 noires + Shift + 5 transport** → état à peu de valeurs. **Reco : A0 + SK6812**
  partout (1 seul bus, firmware uniforme). Option : A1/A2 ici pour valoriser le
  stock, mais ajoute un 2ᵉ chemin de pilotage LED (driver courant constant) → +complexité PCB.
- A1/A2 conservés en **réserve** / variante simplifiée du produit.

### Budget entrées (cf. §11.3 cahier)
| Bloc                        | Lignes |
|-----------------------------|--------|
| 16 blanches + 11 noires     | 27     |
| Shift                       | 1      |
| 5 transport (Play/Stop/Rec/Vue/Export) | 5 |
| 4 push-encodeurs            | 4      |
| **Total boutons**           | **37** |
| 3× MCP23017                 | 48     |
| **Libres**                  | **11** |
- Push-encodeurs sur MCP (pas critique en vitesse) → libère des GPIO ESP32.
- Quadrature A/B des encodeurs **pas** sur MCP (voir Encodeurs).

### Encodeurs — quadrature sur GPIO ESP32-S3 (PCNT), push sur MCP
- Quadrature **A/B = 8 GPIO directs** lus par le périphérique **PCNT** (comptage
  matériel, zéro perte de pas même en rotation rapide). Ne pas mettre A/B sur I2C.
- **Push (4)** → déportés sur MCP23017 (pas critique) → économise 4 GPIO ESP32.

### LEDs — RGB adressables 1-fil, 1 bus (cahier §10.5)
- Le cahier **exige** du RGB adressable sur les 16 blanches (différenciation de couche).
- **Choix touches « pas » : LED WS2811 5 mm THT diffusée** (Adafruit #1938 / Pololu
  #2535 ; 8 mm = Pololu #2536) — voir `ETUDE_PRIX_TOUCHES.md`. Critère : **le moins
  cher + 100 % soudable main** (petites mains). WS281x = même protocole 1-fil que
  SK6812 → même bus, même firmware.
- Bouton « pas » : tact switch carré **12×12×7,3 mm THT** + capuchon carré translucide.
- ⚠️ Intégration mécanique : LED ronde sous cap carré → capuchon/light-pipe diffusant
  (impression 3D / acrylique), à prototyper.
- Alternative rendu « pad » net : SK6812 MINI-E CMS posé en **PCBA** (tu ne soudes
  que les switches THT), ~20 € fixe. À reconsidérer plus tard.
- À FIGER : 5V/3.3V (level-shifter data si 5V), budget courant (WS2811 5 mm ≈ 50 mA
  à blanc plein → 16 pas ≈ 0,8 A crête ; dimensionner l'alim 5V).

### MIDI
- OUT : UART TX + driver de ligne.
- IN : **opto-coupleur obligatoire** (6N138 ou H11L1) pour isolation (norme MIDI).
- À FIGER : connecteurs DIN5 classiques ou TRS (type A) ?

### Alimentation
- USB-C 5V → régulateur 3.3V pour ESP32 + logique.
- TFT / WS2812 possiblement 5V → vérifier datasheets.

## BOM à figer avant le schéma
- [x] Module : **ESP32-S3-WROOM-1-N16R8** (16 Mo flash + 8 Mo PSRAM octale). PSRAM
      non-négociable ; GPIO 26-37 réservés mais sans impact (budget GPIO OK).
- [ ] Écran TFT ~320×240 : référence, contrôleur (ILI9341/ST7789…), SPI, tension, connecteur.
- [ ] Encodeurs : modèle, détente, push intégré.
- [ ] PB86 : confirmer A0 pour les 27 touches ; statuer A0-vs-A1/A2 sur transport/Shift.
- [ ] Connecteurs MIDI : **TRS type A** (cahier penche TRS) vs DIN5.
- [x] LED pas : **WS2811 5 mm THT diffusée** (Adafruit #1938 / Pololu #2535) +
      tact carré 12×12 THT + cap translucide. À FIGER : nb (16 ou 27+), 5V/3.3V,
      level-shifter data, budget courant alim 5V.

## Flux de travail KiCad
1. Figer la BOM (ci-dessus).
2. Claude génère `.kicad_pro` + `.kicad_sch` (schéma fonctionnel).
3. Utilisateur ouvre KiCad → lance **ERC** → renvoie les erreurs → itération.
4. Placement/routage : scripts `pcbnew` pour les grilles régulières (touches, LEDs) ;
   ajustement visuel + **DRC** côté utilisateur.
