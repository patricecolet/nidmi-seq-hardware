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

## Conclusion
- **Critère « moins cher + plus facile à souder » → Option 1 (tout traversant).**
  Gagnante sur les deux axes pour un proto ; seul travail = capuchon/light-pipe.
- **Si rendu « pad » net souhaité sans douleur de soudure → Option 2b** (SK6812
  posé en PCBA, ~20 € fixe), tu ne soudes que des THT.
- **Option 3** : à reconsidérer seulement au passage en série (devis + MOQ).
