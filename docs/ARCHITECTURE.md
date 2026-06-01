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

### LEDs — SK6812 RGB adressables, 1 bus (cahier §10.5)
- Le cahier **exige** WS2812/SK6812 sur les 16 blanches (différenciation de couche).
  **SK6812 préféré** à WS2812 : meilleur à basse luminosité, option RGBW, plus stable.
- 1 broche data, chaîne ≥16 (blanches) extensible à 27+ (toutes touches) — couleur
  libre par LED. À FIGER : 5V ou 3.3V (niveau data → level-shifter si LED en 5V),
  nombre exact, budget courant (≈ 20 mA/LED max à blanc plein).

### MIDI
- OUT : UART TX + driver de ligne.
- IN : **opto-coupleur obligatoire** (6N138 ou H11L1) pour isolation (norme MIDI).
- À FIGER : connecteurs DIN5 classiques ou TRS (type A) ?

### Alimentation
- USB-C 5V → régulateur 3.3V pour ESP32 + logique.
- TFT / WS2812 possiblement 5V → vérifier datasheets.

## BOM à figer avant le schéma
- [ ] Modèle ESP32-S3 exact : WROOM-1 vs WROVER/N16R8 (PSRAM octale mange GPIO 33-37).
      Le cahier §11.2 veut **8 Mo PSRAM** → vérifier les GPIO restants.
- [ ] Écran TFT ~320×240 : référence, contrôleur (ILI9341/ST7789…), SPI, tension, connecteur.
- [ ] Encodeurs : modèle, détente, push intégré.
- [ ] PB86 : confirmer A0 pour les 27 touches ; statuer A0-vs-A1/A2 sur transport/Shift.
- [ ] Connecteurs MIDI : **TRS type A** (cahier penche TRS) vs DIN5.
- [ ] SK6812 : modèle (RGB/RGBW), tension, nombre (16 ou 27+), level-shifter data ?

## Flux de travail KiCad
1. Figer la BOM (ci-dessus).
2. Claude génère `.kicad_pro` + `.kicad_sch` (schéma fonctionnel).
3. Utilisateur ouvre KiCad → lance **ERC** → renvoie les erreurs → itération.
4. Placement/routage : scripts `pcbnew` pour les grilles régulières (touches, LEDs) ;
   ajustement visuel + **DRC** côté utilisateur.
