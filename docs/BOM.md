# BOM — NiDMI Seq (variante plexi capacitive)

> **Source de vérité composants.** Le hardware doit correspondre exactement :
> chaque pièce est définie ici (réf + cotes + implémentation). Le **boîtier suit
> les composants** (modèle `mechanical/facade.scad` paramétrique). Si une pièce
> sourcée diffère, on met à jour la cote → le boîtier se recalcule.
>
> Statuts : 🟢 décidé · 🟡 réf à sourcer/confirmer · 🔴 décision ouverte

## 1. Calcul — 3× ESP32-S3-WROOM-1-N16R8 🟢
- Module 18 × 25,5 × 3,1 mm, castellated/SMD sur PCB.
- Rôles : **A = cerveau** (séquenceur, MIDI, USB, SPI écran, bus LED, comms) ·
  **B + C = tactile** (27 touches + ruban répartis) + lecture encodeurs/boutons.
- *touch* natif = 14 canaux/puce ; 27 touches + ruban (~5) = ~32 / 42 dispo.

## 2. Clavier piano — touches capacitives (27) 🟢 / LED 🟡
- **Électrodes** : cuivre sur PCB (pas de composant). 16 blanches notchées **17 mm**
  + 11 noires **12 mm**, anneau/garde de masse, **R série 470 Ω–2 kΩ / canal**.
- **LED RGB par touche** : **27× SK6812 3535** (top-emit, 3,5 × 3,5 × ~1,5-1,9 mm),
  bus 1-fil 800 kbps GRB, **~60 mA/LED** à blanc plein. Variante reverse **MINI-E**
  (3,2 × 2,8 mm) si éclairage par découpe PCB. 🟡 figer 3535 vs MINI-E selon cellule.
- **Level-shifter data 3,3→5 V : 74AHCT125** (SK6812 VIH ≥ 3,4 V → 3,3 V hors spec).

## 3. Encodeurs — 5× EC11 (avec push) 🟡
- Réf : **Bourns PEC11R-4220F-S0024** (datasheet sûr, arbre 20 mm) *ou* **Alps
  EC11E18244AU** (LCSC C202365) *ou* générique EC11 5-pin 20 mm.
- Cotes (CAD) : corps **12,4 × 13,4 × ~6,5 mm**, bossage **M7×0,75 Ø7 × 5 mm**,
  arbre **Ø6 × 15/20 mm**, pattes ~3-3,5 sous PCB, **total ~31-32 mm** (arbre 20).
  Perçage panneau Ø7 + ergot anti-rotation. Bouton Ø15-20, alésage Ø6.
- Élec : A/C/B quadrature (PCNT) + SW/GND push. **Détentes : générique 20/20,
  Alps 15 PPR, Bourns 24** → 🔴 confirmer le ratio avant commande (impact firmware).
- PCNT = 4 unités/puce → **répartir les 5 encodeurs** sur B+C.

## 4. Boutons de fonction — 8× PB86 🟡
- ROW · HARMONY · PROJET · SHIFT · PLAY · STOP · REC · EXPORT.
- 🟢 **PLAY + REC = PB86-A2** (bi-couleur rouge/vert, 8 pins) ; **6 autres = PB86-A1**
  (mono, 6 pins). → LED : 2×bi (4 lignes) + 6×mono (6 lignes) = **10 lignes**.
- Cotes : corps **12,4 × 17,0 mm**, course 2 mm, force 170 gf, SPDT, LED 1,8-2,4 V
  / 20 mA. **Hauteur/cap non publiés** → récupérer du STEP GrabCAD (pb86-switches-1).
- 🔴 **IO** : 8 switches + LED bi-couleur (16 lignes) = ~24 IO → via **expandeur
  I2C (MCP23017 ×1-2)** ou driver LED dédié. À figer. LED PB86 **hors** bus SK6812.
- **Diodes 🟢 → finalement AUCUNE** : les 16 lignes de LED imposent des **MCP23017**
  (voir §12) ; les 8 switches se câblent donc **en direct** sur l'expandeur (1 broche
  chacun) → **pas de matrice → pas de ghosting → pas de diode**. (La table « diode sur
  Shift/Play/Rec » ne s'appliquait qu'à une matrice scannée, abandonnée.)

## 5. Ruban capacitif — slider tactile natif 🟢
- Électrode PCB ~**180 × 10 mm** (motif triangulaire/interdigité), **~5 canaux**
  *touch* ESP32-S3, sous plexi. **Rôle : assignable** (choisi à l'écran). Pas de
  composant externe (R série éventuelle).

## 6. Écran — 4,0″ 480×320 SPI 🟡 + ⚠️ impact boîtier
- **Contrôleur** : 🟢 **ILI9488** (choix utilisateur ; 18 bpp, OK en *partial
  refresh*). ST7796 = alternative plus rapide (même PCB) si jamais dispo.
- Cotes : **PCB 61,74 × 108,04 mm**, **actif 55,68 × 83,52 mm**, ép. 1,6 mm,
  verre +3-4 mm, **header 14 broches** sur petit bord, trous M3 aux coins (à mesurer).
- Pilotage : **cerveau, SPI ~6 fils** (SCK MOSI CS DC RST + LED PWM), 3,3 V logique.
  Tactile XPT2046 du module **non câblé**.
- ⚠️ **Impact boîtier** : le **PCB fait 108 × 62 mm** (≫ fenêtre 84 × 56) → il faut
  dégager les contrôles au-delà de ce footprint → **revoir le bandeau haut / élargir
  la façade** (actuellement W=320). Fenêtre plexi ≈ 57 × 85 mm.

## 7. MIDI — voir [`CONNECTEURS_MIDI.md`](CONNECTEURS_MIDI.md) 🟡
- IN : opto **H11L1** (reco, sortie logique 3,3 V) + 220 Ω + 1N4148.
- OUT : buffer **74HC14**, R série 220/220 Ω @5 V (ou 33/10 Ω @3,3 V) 🔴.
- 🟢 **TRS type-A** (Ring=+, Tip=signal, Sleeve=shield).

## 8. CV / Gate / Clock / Reset — sous-système analogique 🟢 0–5 V (nouveau)
- **CV** : **MCP4728** (DAC quad 12-bit I2C, MSOP-10, addr 0x60, **0 GPIO** — sur
  l'I2C existant). 4 CV.
- **Mise à l'échelle 1V/oct, 0–5 V 🟢** : DAC Vref interne ×2 (0–4,096 V) → AOP
  **rail-to-rail 5 V** (MCP6022 / MCP6V07), gain ~1,25 (Rf 2,5 k / Rg 10 k) → 0–5,12 V.
  **Pas de rail +12 V** (alim simplifiée). Vref précision ADR4540 optionnelle (accordage).
- **Gate/Clock/Reset** : 5 V via **74HCT125** (3,3→5 V), Eurorack = gate +5 V.
  **3 GPIO** (proposition : 40/41/42).
- Protection/jack : R série 1 kΩ, clamp **BAT54S**, 100 pF. **LDO 5 V propre**
  (MCP1700-5002) dédié DAC/Vref.

## 9. Connectique 🟡
- **USB-C** : **GT-USB-7010ASV** 16-pin (LCSC C2988369), 8,9 × 7,35 × 3,26 mm.
  **2× CC 5,1 kΩ** (Rd), TVS **USBLC6-2SC6**, polyfuse 0,5-1 A. D+/D- → GPIO19/20.
- **Jacks 3,5 mm** : **PJ-320A** (THT, board-edge, Ø6 panneau, 12 × 5 × 5 mm) pour
  MIDI IN/OUT + CV/GATE/CLK/RST.

## 10. Alimentation 🟡
- Entrée **USB-C 5 V** → **buck 3,3 V 2 A** (AP63203/MP2315) pour 3× ESP32 + logique.
- **74AHCT125** (level-shift LED). Bulk **1000 µF** sur 5 V LED, découplage.
- Budget LED : 27× SK6812 ≈ 1,6 A crête → **plafonner luminosité** (USB-C 15 W).
- CV en **0–5 V** → pas de rail +12 V. **LDO 5 V propre** dédié DAC/Vref (anti-bruit).

## 11. Mécanique 🟢
- Plexi **2 mm** (overlay capacitif + fenêtre écran + perçages enc/boutons).
- Grille espaceur **3 mm** (puits de lumière). PCB **1,6 mm**. Boîtier parois 2,5 mm,
  cavité ~22 mm. Profondeur ~31 mm (à recaler sur EC11 ~31-32 mm + connecteurs).

## 12. Budget IO / répartition 3 puces 🟡
**Tactile = 32 canaux (27 touches + ruban ~5) → les 3 puces en font** :

| Ressource | A (cerveau) | B | C |
|---|---|---|---|
| Touch (canaux) | **5** (ruban) | **14** (touches) | **13** (touches) |
| Écran SPI (6) · MIDI (2) · USB (2) · LED SK6812 (1, RMT) · I2C master (2) | ✓ | | |
| Gate / Clock / Reset (3 GPIO) | ✓ | | |
| Encodeurs A/B (PCNT) | | 3 enc | 2 enc |
| Comms inter-puces | maître | ✓ | ✓ |

- **I2C (cerveau)** : 2× **MCP23017** (0x20/0x21) + **MCP4728** (0x60). Les MCP23017
  portent **8 switches PB86 (direct) + 10 lignes LED (2 bi + 6 mono) + 5 push encodeurs**
  = **23 / 32 IO** (marge confortable). CV (DAC) = 0 GPIO.
- **PCNT** = 4 unités/puce → 5 encodeurs répartis B(3)/C(2). **1 cran = 1 cycle
  quadrature** (générique 20/20 ou Bourns 24/24) pour 1 clic = 1 pas.
- 🟢 **Lien inter-puces = UART dédié** (latence basse pour le jeu des touches).
- Cerveau : ribbon (5) + gate/clk/rst (3) sur GPIO 1-14 ; écran/MIDI/LED/I2C sur
  GPIO >14 (12 dispo) ; USB 19/20. **Tient, mais serré** → pinout exact à valider au schéma.

## Décisions (récap)
- ✅ Écran = **ILI9488 4,0″ 480×320 SPI**.
- ✅ **CV 0–5 V** (pas de rail +12 V).
- ✅ MIDI = **TRS type-A**.
- ✅ Encodeurs = **1 cran = 1 cycle quadrature** (20/20 ou 24/24).
- ✅ Lien inter-puces = **UART dédié** (latence basse).
- ✅ Boutons : **PLAY/REC = PB86-A2 bi-couleur**, 6 autres = **A1 mono** ; switches en
  direct sur 2× MCP23017 → **aucune diode**.
- 🟡 **LED touches (SK6812 3535 vs MINI-E)** + dessin de cellule → **étude diffusion**
  en cours (voir [`ETUDE_DIFFUSION_LED.md`](ETUDE_DIFFUSION_LED.md)).
- 🟡 Driver MIDI OUT 5 V vs 3,3 V (mineur).

## Implications boîtier
- ✅ **Écran PCB 108 × 62 mm** intégré au modèle (fenêtre active 84×56, contrôles
  reculés à droite du PCB ; enc pitch 33 / boutons 20 → tient en W=320).
- Profondeur cavité à recaler sur encodeurs (~32 mm) + jacks PJ-320A board-edge.
