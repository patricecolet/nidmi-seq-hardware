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
