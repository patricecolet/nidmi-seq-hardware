# Étude de prix — touches « pas » carrées RGB (16 blanches)

> Comparatif établi 2026-06. Prix **indicatifs** (HT, hors port/taxes), deux
> colonnes : **budget** (AliExpress / lot) vs **détail** (Adafruit, Pololu,
> keycapsss, distri EU). Critères de l'utilisateur : **le moins cher** + **le plus
> facile à souder à la main** (petites mains). Toutes les options restent sur le
> **bus 1-fil** (WS281x / SK6812, même protocole, même firmware — cf. cahier §10.5).

## Récap par option (coût pour 16 pas)

| Option | €/touche (budget→détail) | ×16 (budget→détail) | Soudure main | Assemblage fixe | Risque appro |
|---|---|---|---|---|---|
| **1. Tout traversant** (tact carré THT + WS2811 5 mm THT) | 0,40 → 1,75 | **6 → 28 €** | ✅ Facile (tout THT) | 0 € | 🟢 Faible |
| **2a. MX/Kailh + SK6812 MINI-E, soudé main** | 0,65 → 1,45 | 10 → 23 € | ⚠️ LED CMS reverse **difficile** | 0 € | 🟢 Faible |
| **2b. MX/Kailh + SK6812 posé en PCBA** | 0,65 → 1,45 | 10 → 23 € **+ ~20 € fixe** | ✅ Tu ne soudes que les switches THT | ~18–25 € (stencil+setup+1 part) | 🟢 Faible |
| **3. SHANPU SPD tout-en-un** (RGB+IC LED) | 0,50 → 2 (est., devis) | ~8 → 32 € (est.) | ✅ si variante THT | 0 € | 🔴 Élevé (MOQ 500+?, devis, empreinte custom) |

## Détail des coûts unitaires

### Option 1 — Tout traversant *(recommandée selon tes critères)*
| Pièce | Budget | Détail |
|---|---|---|
| Tact switch 12×12 mm THT | ~0,10 € (lot 100) | ~0,30 € |
| Capuchon carré translucide | ~0,05 € (lot 100) | ~0,10 € |
| LED WS2811 5 mm diffusée THT | ~0,25 € (AliExpress) | ~1,40 € (Adafruit/Pololu, pack 10 ≈ 14 $) |
| **Total / touche** | **~0,40 €** | **~1,80 €** |
- ✅ **Le moins cher ET le plus facile** : 100 % traversant, gros picots, zéro CMS.
- ⚠️ Contrepartie **mécanique** : LED ronde 5 mm sous capuchon carré → prévoir
  capuchon/light-pipe diffusant (impression 3D / acrylique). Pas un coût composant.

### Option 2 — Switch méca MX/Kailh + SK6812 MINI-E
| Pièce | Budget | Détail |
|---|---|---|
| Switch Gateron/Kailh | ~0,23 € | ~0,55 € |
| Keycap translucide *shine-through* | ~0,30 € (set) | ~0,60 € |
| SK6812 MINI-E (CMS reverse) | ~0,12 € (AliExpress) | ~0,30 € (keycapsss, pack 10 ≈ 3,40 €) |
| **Total / touche** | **~0,65 €** | **~1,45 €** |
- 2a : la LED CMS reverse-mount est **le point dur** à souder main (4 pastilles
  fines, à l'envers via découpe) → déconseillé pour petites mains.
- 2b : faire **poser le SK6812 par le fabricant** (JLCPCB PCBA) → ~3 $/part unique
  + ~0,01–0,02 $/joint + stencil (~8 $) + setup (~8 $) ≈ **18–25 € fixe one-shot**,
  ensuite tu ne soudes que les switches THT (faciles). Rendu « pad » net.
- ✅ Écosystème KiCad mûr (empreintes MX + SK6812 prêtes : ebastler/kicad-keyboard-parts).
- ⚠️ Stack **haut** (~11 mm + keycap), plus de surface PCB.

### Option 3 — SHANPU SPD (carré illuminé, RGB adressable intégré)
- 1 seul composant (switch + RGB adressable), profil bas (~8 mm), carré 10/12/15/17 mm.
- **Prix public indisponible** → devis SHANPU requis ; MOQ probablement élevé
  (fabricant Taiwan). Empreinte KiCad à créer.
- Intéressant **en production** (BOM la plus simple), risqué **en proto**.

## Extension aux 27 touches (info)
Si on illumine aussi les 11 noires + Shift (même bus) :
- Option 1 : **~11 → 47 €** (×27)
- Option 2a : ~18 → 39 € ; 2b : + ~20 € fixe

## Références retenues — Option 1 (décidée 2026-06)

**LED RGB adressable 5 mm THT diffusée (driver WS2811, bus 1-fil = compat. SK6812) :**
- Adafruit **#1938** (pack 5) — https://www.adafruit.com/product/1938
- Pololu **#2535** (pack 10) — https://www.pololu.com/product/2535
- Variante 8 mm (meilleure diffusion sous cap carré) : Pololu **#2536** — https://www.pololu.com/product/2536
- Budget : AliExpress/LCSC « WS2811 5mm DIP RGB LED » (4 pattes).

**Bouton tactile carré THT (commodité) :**
- Spec : tact switch **12×12×7,3 mm, 4 broches DIP, traversant, momentané**
  + **capuchon carré translucide** 12×12 mm (vendu à part, lots 100).
- Repère : https://www.aliexpress.com/item/32843369435.html — chercher même spec
  sur LCSC/Mouser pour une réf. distributeur traçable.

## Liste d'achat — Option A (voyant RGB à côté du pas), 16 pas

| Pièce | Source | Lien | Prix |
|---|---|---|---|
| Tact switch 12×12×7,3 mm THT | AliExpress | item 1005007660622508 | ~0,05–0,15 €/u |
| Capuchons carrés translucides 12×12 (100) | AliExpress | item 32844716405 | ~1,70 €/100 |
| LED WS2811 5 mm 🇫🇷 fiable | Gotronic ADA1938 (pack 5) | gotronic.fr art 22883 | ~6 €/5 |
| LED WS2811 8 mm 🇫🇷 (diffuse mieux) | Gotronic ADA1734 (pack 5) | gotronic.fr art 22882 | ~6 €/5 |
| LED WS2811 5 mm 💰 lot | AliExpress 20–1000 pcs | item 32713415299 | ~0,15–0,30 €/u |

Stratégie : 2–3 LED test chez Gotronic (valider rendu+soudure, livraison FR), puis
lot AliExpress pour les 16/27. Total 16 pads ≈ **< 10 €** en lot.

### Support (étape schéma)
- ESP32-S3-WROOM-1-N16R8 (figé) · 3× MCP23017 · 74AHCT125 (level-shifter 3,3→5V) ·
  R ~330 Ω data, 100 nF/LED, 1000 µF alim 5V.

## Conclusion
- **Critère « moins cher + plus facile à souder » → Option 1 (tout traversant).**
  Gagnante sur les deux axes pour un proto ; seul travail = capuchon/light-pipe.
- **Si rendu « pad » net souhaité sans douleur de soudure → Option 2b** (SK6812
  posé en PCBA, ~20 € fixe), tu ne soudes que des THT.
- **Option 3** : à reconsidérer seulement au passage en série (devis + MOQ).
