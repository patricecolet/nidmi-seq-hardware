# Mécanique — modèle 3D de la façade (variante plexi capacitive)

Modèle **paramétrique OpenSCAD** de l'empilement façade :
**plexi** (couvercle) + **grille espaceur** (puits de lumière) + **PCB**
(électrodes capacitives en anneau + SK6812 centrale). Sert à visualiser
l'intégration LEDs / touch et à exporter STL (impression 3D, découpe).

## Fichier
- `facade.scad` — modèle. Tous les paramètres sont en tête de fichier
  (dimensions façade, pad, pitch, épaisseurs, trou LED, écran, encodeurs).

## Pré-requis
OpenSCAD (installé via `brew install --cask openscad`). Binaire : `openscad`.

## Rendu (images)
```sh
cd mechanical

# Vue de dessus + côtes (layout façade)
openscad -o facade_top.png --imgsize=1900,1050 --projection=p \
  --camera=184,75,0,0,0,0,650 -D 'show_dims=true' -D 'explode=0' facade.scad

# Vue éclatée (montre les 3 couches), sans côtes
openscad -o facade_explode.png --imgsize=1500,1100 \
  --camera=184,72,10,60,0,22,640 -D 'show_dims=false' -D 'explode=26' facade.scad

# Boîtier fermé (parois + fond + connecteurs)
openscad -o facade_box.png --imgsize=1700,1200 \
  --camera=160,80,-6,62,0,205,560 -D 'show_box=true' -D 'show_dims=false' -D 'explode=0' facade.scad

# Vue arrière (connecteurs : USB-C | MIDI IN/OUT | CV GATE CLK RST)
openscad -o facade_rear.png --imgsize=1800,900 \
  --camera=160,150,-8,74,0,180,360 -D 'show_box=true' -D 'show_dims=false' -D 'explode=0' facade.scad
```
`explode` : 0 = assemblé, >0 = écarte les couches en Z.
`show_dims` : true = affiche les côtes paramétriques (auto-lues des variables).
`show_box` : true = ajoute parois + fond + connecteurs (objet fermé).

## Cellule plexi épais (branche etude/plexi-epais-grave)
`cellule_plexi.scad` — coupe d'une cellule touche (électrode dans le plexi).
Deux variantes d'électrode via `elec_mode` :
- `"ring"` — anneau **cuivre** opaque + trou central, LED par le trou (membrane percée).
- `"ito"` — film **ITO transparent pleine surface**, la LED traverse l'électrode
  (membrane pleine, pas de hot-spot) + languette de contact. Cf. `docs/CONCEPT_PLEXI_EPAIS.md`.
```sh
# Coupe — variante anneau cuivre (cellule.png)
openscad -o cellule.png --imgsize=1500,950 \
  --camera=0,0,5,87,0,182,52 -D 'show_dims=false' -D 'elec_mode="ring"' cellule_plexi.scad
# Coupe — variante ITO pleine surface (cellule_ito.png)
openscad -o cellule_ito.png --imgsize=1500,950 \
  --camera=0,0,5,87,0,182,52 -D 'show_dims=false' -D 'elec_mode="ito"' cellule_plexi.scad
```
Params en tête : `plexi_t` (10), `membrane` (1,5), `wall`, `led_win`, `elec_mode`. `cut`=coupe.

## Clavier piano — géométrie de facteur (`clavier_piano.scad`)

Modèle dédié du clavier 27 touches, avec la **vraie irrégularité du piano** —
`facade.scad` plaçait les noires sur la limite entre deux blanches, ce qui n'est
pas un clavier de piano.

**Le modèle** : dans le groupe **do-ré-mi** (3 blanches, 2 noires) les talons de
blanche sont égaux entre eux ; dans le groupe **fa-sol-la-si** (4 blanches,
3 noires) ils le sont aussi, mais d'une *autre* valeur. D'où les décalages des
noires par rapport à la ligne de pas : **−1,25 / +1,25** pour do♯ et ré♯,
**−1,87 / 0 / +1,87** pour fa♯, sol♯ et la♯. Symétriques dans chaque groupe, et
**sol♯ exactement sur la ligne** — c'est la signature d'un clavier juste.

**Empilement modélisé** (cf. `../docs/ETUDE_DIFFUSION_LED.md`) : plaque acrylique
transparente découpée en 16 blanches séparées (chacune guide de lumière) · plaque
plus fine et sombre découpée en 11 noires, posée dessus · PCB de tranche **avant**
(16 LED, injection dans les blanches) · PCB de tranche **arrière**, moins haut
(11 LED, injection dans les noires) · caches avant/arrière masquant les PCB.

```sh
# Vue de dessus + côtes (décalages des noires, talons, largeur)
openscad -o clavier_top.png --imgsize=1900,900 --projection=p   --camera=145,29,0,0,0,0,430 -D 'show_dims=true' -D 'explode=0' clavier_piano.scad

# Vue éclatée (les 5 couches)
openscad -o clavier_explode.png --imgsize=1700,1150   --camera=147,25,12,60,0,22,640 -D 'show_dims=false' -D 'explode=24' clavier_piano.scad
```

### Échelle : format « mini-touches », pas piano réel

À `pitch_w = 18.5`, le clavier fait **294,8 mm** et tient dans les 320 mm de
façade. Au pas piano réel de 23,5 mm il faudrait **376 mm** — impossible ici.

Le facteur d'échelle est donc **0,787**… ce qui tombe précisément sur le format
**mini-touches** des contrôleurs du commerce (Arturia, Novation, Akai : 18–19 mm).
Ce n'est donc pas un compromis bâtard mais un standard établi, avec lequel les
joueurs sont déjà familiers.

**Largeur des noires — attention à la cote.** Une noire de piano est
**tronconique** : ~9,5 mm au sommet (où le doigt se pose) mais **13,7 mm à la
base**. Vue de dessus, et à plus forte raison sur une façade **plate** sans aucun
fruit, c'est la **base** qui fait la largeur apparente. Cotes normalisées :
blanche 23,5 mm, noire 13,7 mm → `black_ratio` = **0,583**. Prendre la cote du
sommet donne des noires visiblement maigres.

**Talons des blanches** (partie étroite entre les noires). Des talons **tous
égaux sont mathématiquement impossibles** : il faudrait résoudre en même temps
`3W = 3w + 2B` (groupe do-ré-mi) et `4W = 4w + 3B` (groupe fa-sol-la-si), ce qui
n'admet de solution que pour `B = 0`, donc sans noires. L'arrangement optimal des
facteurs de piano, et le défaut du modèle :

| | talon |
|---|---|
| do, ré, mi | `W − 2B/3` |
| fa, sol, la, si | `W − 3B/4` |

L'écart entre les deux vaut `B/12` — c'est le minimum atteignable.
Refs : [mathpages](https://www.mathpages.com/home/kmath043.htm) ·
[quadibloc](http://quadibloc.com/other/cnv05.htm) ·
[PianoReport](https://pianoreport.com/piano-key-size/)

`tails = [...]` permet de forcer les sept cotes pour coller à un clavier
particulier.

> **Contrainte** : somme des 7 talons + 5 × largeur de noire = 7 × pas. Sinon les
> talons dérivent par rapport aux faces avant, qui restent à pas égal. Le modèle
> vérifie et le signale par un `echo`.

### Les deux plaques découpées, et le travail que ça représente

```sh
openscad -o plaque_blanches.png --imgsize=2000,560 --projection=o \
  --camera=147,29,60,0,0,0,330 -D 'vue_plan=true' -D 'piece="blanches"' clavier_piano.scad
openscad -o plaque_noires.png --imgsize=2000,560 --projection=o \
  --camera=147,29,60,0,0,0,330 -D 'vue_plan=true' -D 'piece="noires"' clavier_piano.scad
```

| plaque | matière | pièces | longueur de coupe |
|---|---|---|---|
| blanches | acrylique clair **10 mm** | 16 | **4,03 m** (dont 22 encoches de 36,8 mm) |
| noires | acrylique teinté **5 mm** | 11 | **1,03 m** |
| | | **27** | **5,06 m** |

> **Découpe laser, pas Dremel.** Ces 4 mètres sont des **chants optiques** : ce
> sont eux qui font fonctionner le guide de lumière, donc chacun doit être poli.
> Le laser fond la matière au lieu de l'arracher et sort des chants
> **naturellement polis, de qualité optique** — on obtient gratuitement ce que le
> Dremel imposerait de polir à la main sur 4 mètres. Pour un guide de lumière ce
> n'est pas un confort mais une condition de fonctionnement.
>
> Le Dremel reste l'outil de la **gravure au dos**, qui veut au contraire une
> surface diffusante.

## Édition interactive
Ouvrir `facade.scad` dans l'app OpenSCAD → fenêtre de preview, on tourne/zoome,
on modifie un paramètre, F5 = aperçu, F6 = rendu final.

## Export STL (impression / découpe)
```sh
# Plexi seul, à plat, pour découpe laser ou impression
openscad -o plexi.stl -D 'explode=0' facade.scad   # (puis isoler la couche voulue)
```
> Pour exporter une couche isolée, commenter les deux autres appels en bas de
> `facade.scad` (`layer_pcb(); layer_spacer(); layer_plexi();`).

## À garder en tête (cf. `../docs/VARIANTE_CAPACITIVE.md`)
- Le modèle est **illustratif** (proportions justes, pas un fichier de fab).
- Entrefer `spacer_t` = compromis sensibilité capacitive ↔ logement LED.
- Hauteur LED `led_h` à caler sur le boîtier SK6812 réel (3535 ≈ 1,6 mm).
- Layout façade = format compact 4×4 (~170×262) ; modifiable via les paramètres.

## Implantation de façade — deux variantes (`implantation.scad`)

Toutes les cotes de façade sont **calculées depuis les composants** : changer une
dimension de composant recalcule l'objet, et les totaux sortent en `echo`. Le
clavier est **importé** de `clavier_piano.scad`, pas redessiné.

```sh
openscad -o implantation_complete.png --imgsize=1400,1150 --projection=o \
  --viewall --autocenter -D 'variante="complete"' implantation.scad
openscad -o implantation_modeste.png --imgsize=1400,1150 --projection=o \
  --viewall --autocenter -D 'variante="modeste"' implantation.scad
```

| variante | façade | contenu |
|---|---|---|
| **complete** | **328 × 185 mm** | clavier 27 touches, écran, 6 encodeurs, 8 boutons, ruban 136 mm |
| **modeste** | **230 × 141 mm** | idem **sans clavier** — module de bureau, notes par MIDI externe |

**Le 6ᵉ encodeur passe** (décision 🔴 du BOM §3), en **deux rangées de trois** au
pas de 30 mm. En une seule rangée de six au pas de 33 il fallait 306 mm pour 296
disponibles ; en 2×3 la rangée haute ne fait plus que 206 mm de large.

**Le ruban passe de 180 à 136 mm** : boutons + ruban sur une même rangée
demandaient 340 mm pour 296 disponibles.

> **Place disponible pour l'écran : 206 mm de large**, contre 108 pour le module
> 4,0″ actuel. Un **7 pouces** (≈165 × 100 mm) rentre en largeur sans rien
> déplacer ; il coûte ~38 mm de profondeur (façade complète ~223 mm) et remplit
> le quadrant supérieur droit, actuellement vide.

> **Les deux variantes partagent la même rangée haute** (écran + encodeurs,
> 206 × 62). La modeste = la complète moins la rangée clavier — même
> sous-ensemble électronique et même firmware d'interface possibles.

## Coupe d'une cellule (`coupe_cellule.scad`)

Coupe **en travers du clavier** : deux blanches et la noire posée à cheval.
Dessinée **explicitement en 2D** plutôt que découpée dans un modèle 3D — ce qu'on
voit est exactement ce qu'on a voulu montrer.

```sh
openscad -o coupe_cellule.png --imgsize=2000,900 --projection=o \
  --camera=50,-10,0,0,0,0,142 coupe_cellule.scad
```

| couche | ép. | rôle |
|---|---|---|
| plaque avant PMMA | 2 mm | surface touchée, rainures peu profondes côté doigt |
| ITO + bus bar | 0,125 mm | **électrode, découpée par touche** + garde à la masse |
| **entrefer** | 1,5 mm | garde la réflexion totale **et** loge les fils de bus bar |
| guide de lumière | 10 mm | LED en tranche, gravure (points, gradient) au dos |
| fond sombre | ~0,05 mm | absorbe le halo non extrait → contraste + anti-pollution |
| mousse | 3 mm | répartit la pression vers l'avant |
| plaque arrière | 2 mm | vissée **en périphérie** — aucune fixation visible |
| | **18,7 mm** | + 3 mm de relief pour les noires |

**Pourquoi deux plaques et pas un bloc.** Le guide ne fonctionne que si ses faces
sont au contact de l'**air**, et le capacitif veut l'électrode **près du doigt**.
Deux arrangements plus simples ont été écartés :

- **électrode derrière le guide** (doigt → 10 mm) : 1 % de signal mesuré, pas
  d'aftertouch, et l'ITO plaqué contre la face gravée met le guide en réflexion
  totale frustrée — la lumière sort partout au lieu de sortir aux points ;
- **électrode sur la face avant du guide** : capacitif excellent, mais l'indice du
  PET est proche de celui du PMMA → la lumière s'échappe sur tout le trajet.

L'entrefer résout les deux : il maintient la réflexion totale et sépare l'ITO de
la face gravée. Il sert en plus de logement aux fils de bus bar.

> ⚠️ **Les noires éloignent le doigt de l'électrode** : 3 mm de relief + 2 mm de
> plaque = **5 mm**, contre 2 mm sur une blanche. La détection passe, l'aftertouch
> non. L'épaisseur de la plaque teintée n'est donc **pas** un simple choix
> d'approvisionnement, c'est un **paramètre capacitif**.
