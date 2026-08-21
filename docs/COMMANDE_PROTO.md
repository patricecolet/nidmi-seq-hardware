# Ce qu'il faut pour le prototype du clavier

> Liste établie le **2026-08-21**, après la séance de conception qui a arrêté
> l'architecture (plaque acrylique continue · un seul ITO · trois éclairages
> indépendants dont deux par en dessous). Détail et justifications :
> [`../mechanical/README.md`](../mechanical/README.md) et [`BOM.md`](BOM.md).
>
> **C'est un prototype** : partout où deux solutions existent, la liste retient
> celle qui se fait à l'atelier, et signale en encadré la voie « série » à viser
> ensuite. Colonnes Qté / Fournisseur / Prix à remplir au moment de commander.

## 0. Déjà en stock — ne pas recommander

| item | état |
|---|---|
| Acrylique coulé **10 mm** | le bloc guide de lumière, déjà en main |
| **Film ITO sur PET** (Adafruit #1309) | reçu, déjà testé au banc |
| **78 LED CMS orange** | récupération — suffisent à tous les essais optiques |
| **ESP32-S3-WROOM-1-N16R8** + platine d'essai | banc capacitif opérationnel |
| **CrowPanel Advance 7.0-HMI** | commandé |

## 1. Acrylique

| ✓ | Item | Pour quoi | Prio | Qté | Fournisseur | Prix |
|---|---|---|---|---|---|---|
| ☐ | Acrylique **coulé transparent 1 mm** | **La plaque continue** — surface touchée. C'est la pièce neuve la plus importante. | **Essentiel** | | | |
| ☐ | Acrylique **coulé transparent 2 mm** | Variante d'épaisseur, si l'essai d'aftertouch dit que 1 mm est trop fin | **Essentiel** | | | |
| ☐ | Acrylique **teinté sombre 1 mm** (chute) | Essai : les noires par la teinte plutôt que par l'impression | Recommandé | | | |
| ☐ | Acrylique **satiné / dépoli 1 mm** (chute) | Essai du satinage local sous la bande du ruban | Recommandé | | | |

> ⚠️ **Coulé, pas extrudé.** L'extrudé fond et bavoche à l'usinage, le coulé se
> fraise proprement et se polit. Pour la plaque, c'est ce qui décide de l'aspect.

## 2. Contact de l'électrode

| ✓ | Item | Réf | Prio | Qté | Fournisseur | Prix |
|---|---|---|---|---|---|---|
| ☐ | **Encre / stylo argent conducteur** | MG Chemicals **842AR** ou **842AR-P** | **Essentiel** | | | |
| ☐ | **Ruban Z-axis** (conducteur dans l'épaisseur seulement) | 3M **9703** | **Essentiel** | | | |
| ☐ | **Époxy argent** (reprise, réparation) | MG Chemicals **8331S** | Recommandé | | | |
| ☐ | **Connecteur élastomère « zébra »** | pas de conduction 0,1–0,5 mm | Optionnel | | | |
| ☐ | **Ruban cuivre à adhésif _conducteur_** | 3M **1181** | Optionnel | | | |
| ☐ | **Vernis de tropicalisation** acrylique | encapsulation de la jonction argent | Recommandé | | | |

> **Jamais de soudure sur l'ITO**, et jamais de contact direct dessus : on passe
> par l'argent. Le ruban Z-axis colle toutes les plages d'un coup sans les
> court-circuiter — c'est la solution proto qui demande le moins d'outillage.
>
> Voie **série** : queue de film sérigraphiée au pas d'un connecteur à charnière
> (FFC/ZIF), rigidifiée par un renfort. Rien à acheter maintenant.

## 3. Éclairage

| ✓ | Item | Pour quoi | Prio | Qté | Fournisseur | Prix |
|---|---|---|---|---|---|---|
| ☐ | **SK6812 3535** RGB | Blanches (tranche avant) + noires (par en dessous) | **Essentiel** | ~30 | | |
| ☐ | **74AHCT125** | Adaptation 3,3 → 5 V du bus 1-fil | **Essentiel** | | | |
| ☐ | Bande SK6812 **60 LED/m** | Ruban — le pas grossier est le bon si le halo est large | Recommandé | | | |
| ☐ | Bandes 96 et 144 LED/m (chutes) | Comparer le pas au halo mesuré | Optionnel | | | |

> Le pas des LED du ruban ne se choisit pas au catalogue : **pas ≤ largeur du
> halo**, à relever au banc sur le bloc de 10 mm.

## 4. Serrage — la mousse est le ressort

| ✓ | Item | Note | Prio | Qté | Fournisseur | Prix |
|---|---|---|---|---|---|---|
| ☐ | **Mousse polyuréthane microcellulaire 3 mm** (type Poron) ou silicone | **Faible déformation rémanente obligatoire** | **Essentiel** | | | |
| ☐ | Visserie **M3** + écrous | dans des poches usinées, jamais taraudé dans l'acrylique | Essentiel | | | |
| ☐ | Entretoises métal | fixer une hauteur de pile déterministe | Recommandé | | | |

> De la mousse d'emballage ordinaire garde l'empreinte en quelques mois : la
> pression tombe et les contacts deviennent erratiques sans qu'on comprenne pourquoi.

## 5. Cartes

| ✓ | Item | Note | Prio | Qté | Fournisseur | Prix |
|---|---|---|---|---|---|---|
| ☐ | PCB **carte horizontale sous le bloc** | 294,8 × 56 mm — LED des noires **et** du ruban ; **posée sur le socle**, dans la **découpe de la mousse** | **Essentiel** | 1 | | |
| ☐ | PCB **tranche avant** | 294,8 × 8 mm, verticale — 16 LED, injection dans les blanches | **Essentiel** | 1 | | |
| ☐ | PCB **latéral** (double face) | **71,5 × 131,9 mm** — 4 PB86 + 3 EC11 devant, ESP32-S3 au dos, connecteurs en bord de carte | **Essentiel** | 2 | | |
| ☐ | Finition **or chimique (ENIG)**, ép. 0,6–0,8 mm | plat et non oxydable — indispensable pour un contact par pression | **Essentiel** | | | |
| ☐ | Connecteur **FFC/ZIF** | si la queue de film est retenue | Optionnel | | | |

## 6. Banc de mesure — la question qui verrouille tout

| ✓ | Item | Pour quoi | Prio |
|---|---|---|---|
| ☐ | **Chutes de PET / feuilles minces** à empiler | 🔴 **Balayage de l'aftertouch en fonction de l'épaisseur** : 0,25 · 0,5 · 1 · 2 mm. Mesuré : 0,125 mm passe, 10 mm ne passe pas. L'intervalle décide de l'épaisseur de la plaque. | **Essentiel** |
| ☐ | Jeu de **résistances série** (470 Ω → 22 kΩ) | Mesurer le vrai plafond de résistance d'un canal tactile, au lieu du 470 Ω–2 kΩ du BOM qui est une valeur de protection | Recommandé |

## 7. Usinage et consommables

| ✓ | Item | Note | Prio |
|---|---|---|---|
| ☐ | Fraises CNC pour acrylique (monodent) | plaque, relief des noires, poches borgnes | **Essentiel** |
| ☐ | Lame de scie fine | traits de scie entre blanches, arrêtés à 20 mm | Essentiel |
| ☐ | Fraise à graver / pointe Dremel | trame d'extraction au dos du bloc | Essentiel |
| ☐ | Film adhésif sombre | fond absorbant, avec fenêtre sous chaque noire | Essentiel |
| ☐ | Abrasifs fins + pâte à polir | chants optiques | Recommandé |

---

## Ordre d'attaque conseillé

1. **L'essai d'aftertouch** — il ne coûte rien et il décide de l'épaisseur de la plaque.
2. **La largeur du halo** d'une LED sous 10 mm de bloc — elle fixe le pas des LED du ruban.
3. Une **cellule complète** : plaque + film + bloc + LED dessous, pour mesurer le
   cross-talk, la dérive et la latence.

**Total estimé :** _(à remplir)_
