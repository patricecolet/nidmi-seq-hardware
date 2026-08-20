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

La mise à l'échelle stricte donnerait une **noire de 7,47 mm** contre 9,5 mm sur
un piano — étroite, et d'autant moins fiable à toucher en capacitif. Les claviers
mini-touches du commerce (Akai, Arturia, Novation) élargissent leurs noires plus
que la réduction ne le voudrait. `black_ratio` est donc réglé à **0,48 → 8,9 mm**.

> ⚠️ Valeur **estimée**, à recaler en mesurant la largeur d'une noire sur un
> clavier réel. Le pas de 18–19 mm des mini-claviers est en revanche une donnée
> fiable, et le modèle est à 18,5.

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
