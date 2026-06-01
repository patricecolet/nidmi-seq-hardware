# Architecture matérielle — NiDMI Seq

> Document vivant. Décisions actées avec l'utilisateur ; certaines restent à
> trancher (marquées **À FIGER**).

## Schéma bloc

```
                          ┌─────────────────────────┐
                          │      ESP32-S3            │
                          │  (dual-core, USB natif)  │
                          └─────────────────────────┘
        I2C (2 fils) ────────┤ SDA/SCL          SPI ├──── TFT (SCK,MOSI,CS,DC,RST,BL)
             │               │                       │
    ┌────────┴────────┐      │              UART TX ├──── MIDI OUT (DIN5 ou TRS)
    │                 │      │              UART RX ├──── MIDI IN (via opto 6N138)
 MCP23017 #0      MCP23017 #1│                       │
 (0x20)           (0x21)     │           1 GPIO data├──── LEDs WS2812 (chaîne)
 16 entrées       16 entrées │                       │
    │                 │      │     8-12 GPIO directs ├──── 4 encodeurs (A/B + push)
 16 blanches    11 noires    │                       │
                + Shift      └── INT ────────────────┘  (réveil sur appui)
                + 4 libres
```

## Décisions actées

### Lecture des touches : expandeurs I2C MCP23017
- Bus I2C = 2 fils pour ≥32 entrées ; jusqu'à 8 MCP23017 (adr. 0x20→0x27 via A0/A1/A2).
- **Pull-ups internes** → boutons câblés `pin → bouton → GND`, zéro composant externe.
- Broche **INT** → l'ESP32 ne fait pas de polling, réveil sur changement d'état.

### Touches : boutons on/off (pas de vélocité au doigt)
- Pas d'ADC, pas de matrice, pas de diodes anti-ghosting.
- `StepData.velocity` reste **éditable à l'encodeur** (réglage par pas), pas joué.
  → à refléter dans le cahier des charges du VST.

### Budget entrées
| Bloc            | Lignes |
|-----------------|--------|
| 16 blanches     | 16     |
| 11 noires       | 11     |
| Shift           | 1      |
| **Sous-total**  | **28** |
| MCP23017 (2×16) | 32     |
| **Libres**      | **4**  | → Play / Stop / Rec / réserve

## À FIGER

### Encodeurs — reco : GPIO directs ESP32-S3 (périphérique PCNT)
- 4 encodeurs × (A + B + push) = 12 GPIO.
- PCNT = comptage quadrature **matériel**, zéro perte de pas même en rotation rapide.
- Alternative (déconseillée) : 3ᵉ MCP23017 → lecture rapide sur I2C capricieuse.

### LEDs — reco : WS2812 (NeoPixel)
- 1 seule broche data pour toute la chaîne, couleur libre par pas + badge Shift.
- Évite la limite de courant du boîtier MCP.
- À FIGER : 5V ou 3.3V selon modèle ; nombre exact de LEDs.

### MIDI
- OUT : UART TX + driver de ligne.
- IN : **opto-coupleur obligatoire** (6N138 ou H11L1) pour isolation (norme MIDI).
- À FIGER : connecteurs DIN5 classiques ou TRS (type A) ?

### Alimentation
- USB-C 5V → régulateur 3.3V pour ESP32 + logique.
- TFT / WS2812 possiblement 5V → vérifier datasheets.

## BOM à figer avant le schéma
- [ ] Modèle ESP32-S3 exact : DevKit, module WROOM-1, WROVER ? (datasheet → affectation broches)
- [ ] Écran TFT : référence, interface (SPI), tension, connecteur.
- [ ] Encodeurs : modèle, avec/sans détente, push intégré.
- [ ] Type de boutons / keycaps des 27 touches.
- [ ] Connecteurs MIDI : DIN5 vs TRS.
- [ ] Nombre et tension des LEDs.

## Flux de travail KiCad
1. Figer la BOM (ci-dessus).
2. Claude génère `.kicad_pro` + `.kicad_sch` (schéma fonctionnel).
3. Utilisateur ouvre KiCad → lance **ERC** → renvoie les erreurs → itération.
4. Placement/routage : scripts `pcbnew` pour les grilles régulières (touches, LEDs) ;
   ajustement visuel + **DRC** côté utilisateur.
