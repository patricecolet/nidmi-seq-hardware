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
- **PB86-A2** (bi-couleur rouge/vert, 8 broches) reco pour l'indication d'état ;
  A1 (mono, 6 pins) / A0 (lampless, 4 pins) en variantes.
- Cotes : corps **12,4 × 17,0 mm**, course 2 mm, force 170 gf, SPDT, LED 1,8-2,4 V
  / 20 mA. **Hauteur/cap non publiés** → récupérer du STEP GrabCAD (pb86-switches-1).
- 🔴 **IO** : 8 switches + LED bi-couleur (16 lignes) = ~24 IO → via **expandeur
  I2C (MCP23017 ×1-2)** ou driver LED dédié. À figer. LED PB86 **hors** bus SK6812.

## 5. Ruban capacitif — slider tactile natif 🟢
- Électrode PCB ~**180 × 10 mm** (motif triangulaire/interdigité), **~5 canaux**
  *touch* ESP32-S3, sous plexi. **Rôle : assignable** (choisi à l'écran). Pas de
  composant externe (R série éventuelle).

## 6. Écran — 4,0″ 480×320 SPI 🟡 + ⚠️ impact boîtier
- **Contrôleur** : 🔴 **ST7796 reco** (RGB565 16 bpp, ~40-80 MHz, rapide) **vs
  ILI9488** (18 bpp, plus lent) — **même PCB, drop-in**. Module Elecrow 4,0″ ST7796.
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
- **TRS type-A** (Ring=+, Tip=signal, Sleeve=shield) 🔴 vs DIN5.

## 8. CV / Gate / Clock / Reset — sous-système analogique 🔴 (nouveau)
- **CV** : **MCP4728** (DAC quad 12-bit I2C, MSOP-10, addr 0x60, **0 GPIO** — sur
  l'I2C existant). 4 CV.
- **Mise à l'échelle 1V/oct** : AOP **OPA2192** + **Vref ADR4540 (4,096 V)** ;
  Rf 15 k / Rg 10 k 0,1 % → gain 2,5. 🔴 **0–5 V (simple) vs 0–10 V** : le 0–10 V
  exige un **rail +12 V** (donc alim +12 V à ajouter) ; le 0–5 V évite ça.
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
- Si **CV 0–10 V** : ajouter rail **+12 V**. **LDO 5 V propre** pour le DAC/Vref.

## 11. Mécanique 🟢
- Plexi **2 mm** (overlay capacitif + fenêtre écran + perçages enc/boutons).
- Grille espaceur **3 mm** (puits de lumière). PCB **1,6 mm**. Boîtier parois 2,5 mm,
  cavité ~22 mm. Profondeur ~31 mm (à recaler sur EC11 ~31-32 mm + connecteurs).

## Décisions ouvertes (récap) 🔴
1. Écran **ST7796 vs ILI9488** (même boîtier).
2. CV **0–5 V vs 0–10 V** (le 10 V impose un rail +12 V).
3. PB86 **A1 vs A2** + **comment piloter switches+LED** (expandeur/driver).
4. MIDI **TRS type-A vs DIN5** ; driver OUT **5 V vs 3,3 V**.
5. Encodeurs : **ratio détentes/PPR** (firmware).
6. SK6812 **3535 vs MINI-E** (selon dessin de cellule).

## Implications boîtier à traiter
- **Écran PCB 108 × 62 mm** → re-layout du bandeau / élargir la façade.
- Profondeur cavité à recaler sur encodeurs (~32 mm) + jacks PJ-320A board-edge.
