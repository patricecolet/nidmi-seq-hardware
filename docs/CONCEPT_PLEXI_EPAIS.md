# Concept — électrodes DANS le plexi épais (proto Dremel)

> **Branche `etude/plexi-epais-grave`.** Alternative à la branche capacitive
> `etude/plexi-capacitif` (où l'électrode, portée par un PCB sous l'entrefer des
> encodeurs + 2 PCB, était à **5-9 mm** du doigt → capacitif trop faible).
> Ici l'électrode est **portée par le plexi lui-même**, à ~1,5 mm de la surface.
> Le reste de l'archi (3× ESP32-S3, écran, MIDI, CV, encodeurs, PB86, LED) est
> **réutilisé** depuis la branche capacitive ([`BOM.md`](BOM.md)).

## Problème résolu
Capacitif : sensibilité ∝ **surface électrode / épaisseur diélectrique**. Avec un
PCB loin sous le plexi, le diélectrique = entrefer (air) + plexi → trop épais.
→ On amène l'électrode **juste derrière la face avant**, dans le plexi.

## Principe
- **Plexi épais** (~**8-12 mm**, acrylique coulé) = panneau **et** substrat. Se
  perce / fraise / rainure **à la Dremel** (rotary tool), sans CNC.
- Au **dos**, par cellule : **poche fraisée** laissant une **membrane avant ~1-1,5 mm**.
- **Électrode** = feuille / ruban **cuivre** (ou peinture conductrice) collée au
  **fond de la poche** → ~1,5 mm du doigt → capacitif sensible.
- **LED** SK6812 dans une poche/perçage, éclaire via une zone **dépolie**.
- **Rainures** au dos pour le **câblage** (fils → pins *touch* ESP32).
- **Électronique** (3 ESP32, écran, expandeurs, alim…) sur une **petite carte** au
  dos, câblée aux électrodes (pas de grand PCB de façade).

## Coupe (principe)
```
   doigt
 ───────────────────────  face avant (lisse)
 ▓ membrane ~1,5 mm ▓▓▓▓   plexi (diélectrique fin devant l'électrode)
 ▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓   ← électrode cuivre au fond de la poche
 ▓▓▓                 ▓▓▓   poche fraisée (Dremel) + rainure câblage
 ▓▓▓   ~8-12 mm plexi épais (structure)   ▓▓▓
 ═══════════════════════  dos → carte électronique câblée
```

## Ce qui change vs la branche capacitive
- **Plus de "spacer" ni de double PCB** pour les touches : le plexi est le support.
- Encodeurs / boutons PB86 / écran : **traversent** le plexi (perçages Dremel).
- LED : poches dans le plexi (au lieu de puits dans une grille espaceur).

## À tester sur proto (outils main)
- Sensibilité capacitive à travers **1-1,5 mm** de membrane (la valider en premier).
- **Précision Dremel à la main** : profondeur de poche régulière → gabarit/guide de
  profondeur ? fraise sur colonne ?
- Diffusion LED à travers plexi dépoli.
- Tenue de l'électrode (adhésif cuivre vs peinture conductrice) + fiabilité du contact câblé.

## Points ouverts
- **Électrode** : ruban cuivre adhésif · feuille cuivre · peinture conductrice (Bare/MG) ?
- **Membrane** : épaisseur mini fiable au Dremel (1 mm risqué à la main ?).
- **Fixation** de la carte électronique au dos + passage des fils.
- Garde de masse / blindage entre cellules (éviter le cross-talk) — faisable en cuivre aussi.
