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

# Vue éclatée (montre les 3 couches)
openscad -o facade_explode.png --imgsize=1400,1400 \
  --camera=85,131,15,62,0,28,560 -D 'explode=28' facade.scad

# Vue assemblée
openscad -o facade_assembled.png --imgsize=1400,1400 \
  --camera=85,131,15,62,0,28,560 -D 'explode=0' facade.scad

# Vue de dessus (layout façade)
openscad -o facade_top.png --imgsize=1000,1500 \
  --camera=85,131,0,0,0,0,640 --projection=p -D 'explode=0' facade.scad
```
`explode` : 0 = assemblé, >0 = écarte les couches en Z.

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
