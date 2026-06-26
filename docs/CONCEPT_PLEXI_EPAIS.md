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

## Électrode transparente (ITO) — option pleine surface
Une électrode cuivre est **opaque** → elle force l'anneau + trou central (point chaud
au centre, électrode amputée). Alternative : **film ITO sur PET** (transparent conducteur,
~80 % de transmission, 5–100 Ω/□). On colle une électrode **pleine cellule** au dos de la
membrane → max de surface capacitive **et** la LED RGB **traverse** l'électrode (plus de
trou, plus de hot-spot). Se **coupe aux ciseaux** ; **ne se soude pas**.

### Procédure de contact ITO → circuit
On ne soude jamais sur l'ITO (couche de qqs 100 nm, détruite par la chaleur, l'étain ne
mouille pas). On fait un contact méca/adhésif sur une **languette** d'ITO, et on soude le
fil sur le **métal rapporté**.

1. Découper l'ITO avec une **languette d'amenée** au bord de la cellule (vers la rainure
   de câblage du dos).
2. Presser du **ruban cuivre à adhésif _conducteur_** (3M 1181 — pas du cuivre à adhésif
   isolant courant !) sur la languette, **surface généreuse** (R de contact ∝ 1/aire).
3. **Renforcer** le joint d'un point de **peinture/époxy argent** (anti-arrachement + baisse R).
4. **Souder le fil sur le cuivre**, jamais sur l'ITO. Vérifier la continuité ITO↔fil à
   l'ohmmètre : dizaines/centaines d'Ω = **normal et suffisant** pour le tactile.

> **Pourquoi ça marche** : le self-cap (ESP32-S3) tolère **plusieurs kΩ** en série → la R
> de contact ITO n'est pas critique. Mais l'ITO est résistif (5–100 Ω/□) → **garder l'ITO
> limité à l'électrode**, repartir en **cuivre** dans les rainures vers les pins *touch*.

```
   ┌──── électrode ITO pleine cellule (dos de la membrane, LED traverse) ────┐
   └──── languette ITO ──┐
                         │  ← ruban cuivre adhésif CONDUCTEUR (3M 1181)
                         │     + renfort époxy/peinture Ag
                         ●  ← fil soudé SUR LE CUIVRE
                         └──→ rainure de câblage (dos) → pin touch ESP32
```

Variante **démontable** (carte au dos déconnectable) : languette ITO + **ruban Z-axis
3M 9703** + pad sur la carte, pincés par pression — aucune soudure sur la cellule.

### Réfs à commander (échantillons proto)
| Rôle | Réf | Format / note |
|---|---|---|
| **Film ITO/PET** | Adafruit #1309 | 100×200 mm, découpe ciseaux, ~80 % transm. |
| Film ITO (alt. plus grand) | MTI 14 Ω/□ (115 nm) · Thorlabs · Huanyu (Amazon) | 300×1000 mm si besoin de surface |
| **Ruban cuivre adhésif _conducteur_** | 3M 1181 | largeurs 6,35 / 50,8 mm × 16,5 m (~5–60 € selon largeur) |
| **Époxy argent** (joint robuste) | MG Chemicals 8331S | seringue 14 g, bi-composant |
| **Peinture argent** (renfort/rattrapage) | MG Chemicals 842AR | pot 15/150 ml, ou **stylo 842AR-P** 8,6 g |
| Ruban Z-axis (option démontable) | 3M 9703 | conduction par pression, axe Z uniquement |

> Distributeurs EU : RS, Digi-Key, shop-sks (DE). Prix indicatifs à confirmer à la commande.

## Points ouverts
- **Électrode** : **ITO/PET transparent pleine surface** (cf. section ci-dessus) ·
  ruban cuivre adhésif · feuille cuivre · peinture conductrice (Bare/MG) ?
- **Membrane** : épaisseur mini fiable au Dremel (1 mm risqué à la main ?).
- **Fixation** de la carte électronique au dos + passage des fils.
- Garde de masse / blindage entre cellules (éviter le cross-talk) — faisable en cuivre aussi.
