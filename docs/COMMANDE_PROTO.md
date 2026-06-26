# Commande proto — échantillons (étude plexi épais + diffusion LED)

> Checklist d'achat avant l'étude physique (branche `etude/plexi-epais-grave`).
> Sources : [`CONCEPT_PLEXI_EPAIS.md`](CONCEPT_PLEXI_EPAIS.md) (électrode/contact ITO),
> [`ETUDE_DIFFUSION_LED.md`](ETUDE_DIFFUSION_LED.md) (plexi/LED/diffusion).
> Colonnes Qté/Fournisseur/Prix à remplir au moment de commander.
>
> **Minimum 1er test** (électrode ITO pleine surface + LED qui traverse + capacitif à
> travers 1,5 mm) : acrylique épais + ITO #1309 + 3M 1181 + SK6812 3535 + ESP32.
>
> **Pièges** : `3M 1181` = ruban cuivre à adhésif **CONDUCTEUR** (≠ ruban cuivre déco
> isolant). On ne **soude jamais** sur l'ITO → contact via cuivre/argent.
> Distributeurs EU : RS, Digi-Key ; Adafruit via revendeur EU (ex. Mouser).

## 1. Plexi / acrylique (substrat + diffusion)
| ✓ | Item | Pour quoi | Prio | Qté | Fournisseur | Prix |
|---|---|---|---|---|---|---|
| ☐ | Acrylique **coulé épais 8–12 mm** (chute ~10×10 cm) | Substrat cellule (poche + membrane) | **Essentiel** | | | |
| ☐ | Acrylique **transparent 2 mm** (chute) | Réf diffusion | Essentiel | | | |
| ☐ | Acrylique **dépoli/sablé 2 mm** (chute) | Diffuseur intégré (glow homogène) | Essentiel | | | |
| ☐ | Acrylique **opale/diffusant 2 mm** (chute) | Diffusion max (comparer) | Recommandé | | | |
| ☐ | Acrylique transparent **1,5 / 3 mm** | Membrane mini fiable au Dremel | Optionnel | | | |

## 2. Électrode + contact (ITO)
| ✓ | Item | Réf | Prio | Qté | Fournisseur | Prix |
|---|---|---|---|---|---|---|
| ☐ | **Film ITO sur PET** (100×200 mm) | Adafruit **#1309** | **Essentiel** | | | |
| ☐ | **Ruban cuivre adhésif _conducteur_** | **3M 1181** | **Essentiel** | | | |
| ☐ | **Époxy argent** (joint fil↔ITO) | MG Chemicals **8331S** (seringue 14 g) | Essentiel | | | |
| ☐ | **Peinture/stylo argent** (renfort) | MG Chemicals **842AR** / **842AR-P** | Recommandé | | | |
| ☐ | Ruban **Z-axis** (contact démontable) | 3M **9703** | Optionnel | | | |
| ☐ | Feuille/ruban **cuivre simple** | anneau (plan B) + gardes de masse | Optionnel | | | |

## 3. LED RGB (décision BOM #6 : 3535 vs MINI-E)
| ✓ | Item | Pour quoi | Prio | Qté | Fournisseur | Prix |
|---|---|---|---|---|---|---|
| ☐ | **SK6812 3535** (front-fire) | Stack LED derrière membrane | **Essentiel** | 2–3 | | |
| ☐ | **SK6812 MINI-E** | Émission « par le trou » (mode anneau) | Essentiel | 2–3 | | |
| ☐ | Mini-carte / breakout SK6812 | Souder/câbler les LED | Essentiel | | | |

## 4. Diffusion (films)
| ✓ | Item | Source | Prio | Qté | Fournisseur | Prix |
|---|---|---|---|---|---|---|
| ☐ | **Film diffuseur** | **récup** : dalle LCD HS (feuilles dépolies) | Essentiel | | récup | 0 |
| ☐ | Film **diffraction** (effet déco) | — | Optionnel | | | |

## 5. Électronique de test
| ✓ | Item | Note | Prio | Qté | Fournisseur | Prix |
|---|---|---|---|---|---|---|
| ☐ | **ESP32** (pins *touch*) | piloter SK6812 (NeoPixel/FastLED) + lire capacitif | **Essentiel** | | | |
| ☐ | Fils / fer à souder / ohmmètre | continuité ITO↔fil (dizaines/centaines Ω = OK) | atelier | | | |

---
**Total estimé :** _(à remplir)_
