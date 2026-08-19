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

> **L'ITO se fissure si on le plie.** C'est une couche céramique de quelques centaines de
> nanomètres sur un PET souple : le support plie, la couche conductrice non. Une pliure ou une
> marque d'ongle sur la languette crée des micro-fissures et un contact **intermittent** — le
> défaut se manifeste comme des décrochages francs vers la valeur « broche nue », pas comme du
> bruit. Garder la languette **plate**, y compris dans la pince.

### Contact de banc (sans matériel spécifique)
Avant d'avoir le 3M 1181, un contact provisoire suffisant pour mesurer :
souder le fil sur un **bout de feuille de cuivre** (ou de tresse à dessouder aplatie) **d'abord**,
loin du film ; poser ce cuivre **à plat** sur la face conductrice de la languette ; **serrer à la
pince** (pince double-clip, crocodile, ou bornier à vis avec le cuivre en interposition).
Vérifier à l'ohmmètre fil ↔ électrode : **dizaines/centaines d'Ω**, et **stable quand on remue
la jonction** — c'est la stabilité qui compte, pas la valeur.

> Ruban cuivre **ordinaire** (adhésif isolant) : la colle ne conduit pas. Le replier **par-dessus
> le bord** de la languette pour que le cuivre touche l'ITO directement, la colle ne servant qu'à
> tenir mécaniquement. Le 3M 1181, lui, conduit à travers l'adhésif — d'où son intérêt.

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

## Bascule de design (2026-08-19, après mesure)

La mesure a validé le capacitif **avec une marge telle** que la contrainte d'origine tombe :
repos 47 000 → doigt 300 000, soit **×6,4**, sur un contact provisoire à la pince croco
(détail dans [`ESSAI_ITO_ESP32.md`](ESSAI_ITO_ESP32.md)). On n'a donc plus besoin que le plexi
serve de diélectrique mince.

**Nouvelle direction** : électrode ITO **près de la surface** sous un revêtement transparent fin,
**pourtour métallique** autour de chaque touche, et le **plexi dédié à la LED** (diffusion) plutôt
qu'au capacitif. Ça supprime le point le plus risqué du concept : la poche fraisée au Dremel avec
une membrane régulière à 1–1,5 mm, dont la faisabilité à la main restait douteuse.

**Le revêtement est déjà là.** L'ITO est déposé sur un **PET de ~0,125 mm**. En orientant le film
**PET vers le doigt, ITO vers l'intérieur**, le PET fait revêtement de protection : le doigt ne
touche jamais la couche conductrice, et le diélectrique ajouté est négligeable devant le ×6,4
mesuré. (Inverse la consigne « face conductrice vers le doigt », qui ne valait que pour compenser
l'épaisseur de plexi.)

**Pourtour métallique = bus bar de l'électrode** (pas une garde). C'est la technique standard des
dalles ITO et des panneaux EL : ceinturer l'électrode d'un conducteur en laissant le centre libre
pour la lumière. Deux effets :

- **Résistance de contact effondrée** : elle varie en 1/surface, et un pourtour complet en offre
  bien plus qu'une languette. Plus de point de fragilité unique, plus de languette à plier — donc
  plus de fissuration de l'ITO, la cause des décrochages mesurés.
- **Uniformité du potentiel** : l'ITO fait 5–100 Ω/□. Alimenté par un seul coin, le centre de la
  cellule voit plusieurs centaines d'ohms ; alimenté par tout le pourtour, la distance maximale au
  bus tombe à la moitié de la cellule. C'est la raison d'être des bus bars argent sérigraphiés.

**Il s'emboîte avec l'orientation PET-vers-le-doigt** : l'ITO étant tourné vers l'intérieur, le
pourtour se pose sur la face interne → **caché derrière le film, inaccessible au doigt** (plus de
souci d'ESD ni d'abrasion sur du métal exposé), et sans contrainte d'affleurement.

> **Conséquence à ne pas manquer** : ce pourtour est **au potentiel de mesure**, il fait partie de
> l'électrode. Le métal se couplant bien mieux que l'ITO, le **cross-talk se joue entre pourtours
> voisins** — c'est l'écart entre cadres, et non entre zones ITO, qui fixera le pas du clavier.
> Si l'écart seul ne suffit pas, prévoir une **piste de masse distincte entre les cellules**
> (là serait la vraie garde).

Réalisation proto : cadre au **ruban cuivre conducteur 3M 1181**, tracé au **stylo argent
842AR-P**, ou **broches de résistance** logées dans des rainures fraisées au Dremel (cf. coupon
ci-dessous). Vérification : résistance fil ↔ **centre** de l'électrode, à comparer au montage à
languette unique — c'est là que le gain doit se voir.

## Coupon d'essai 3 cellules (rainures Dremel + broches de résistance)

Cadres et garde réalisés en **broches de résistance** logées dans des rainures fraisées au dos du
plexi. Conductivité largement suffisante : même en acier cuivré, la broche est négligeable devant
les 5–100 Ω/□ de l'ITO. **Décaper les broches** (papier de verre fin) — vernis ou oxyde suffisent
à ruiner un contact par pression.

> ⚠️ **Deux conducteurs de nature opposée, physiquement semblables, dans des rainures voisines :**
> le **cadre** de chaque cellule est **au potentiel de mesure** (→ broche touch) ; la **broche
> entre cellules** est **à la masse** (la vraie garde). Les inverser sur une cellule la rend
> muette, et le symptôme imite un défaut de contact plutôt qu'une erreur de câblage.

**Contact fil rond sur film plat = une ligne, pas une surface.** Remède géométrique : creuser la
rainure **moins profonde que le diamètre du fil**, pour que la broche dépasse de 0,1–0,2 mm. Le
film plaqué par-dessus est alors pressé contre le fil sur tout le pourtour. Cadre plus simple à
réaliser en **4 segments droits soudés aux angles** qu'en rectangle plié, fil de liaison soudé sur
un coin.

### Assemblage : pression par l'arrière (aucune fixation visible)

**Contrainte dominante : l'esthétique.** Une plaque de serrage vissée en face avant, avec des vis
entre les touches, est mécaniquement correcte et visuellement inacceptable sur un contrôleur.
→ La pression vient de **derrière**, la face avant reste une plaque continue sans perçage.

```
   doigt
 ─────────────────────────   face avant = plaque plexi CONTINUE, sans perçage
 ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   (1,5–2 mm : la surface qu'on voit et qu'on touche)
 ░░░░░░░░░░░░░░░░░░░░░░░░░   film ITO, couche ITO tournée vers l'arrière
 ══╡                   ╞══   cadres en broches, dans les rainures du support
 ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   mousse de repartition
 ═════════════════════════   plaque arriere, vissee EN PERIPHERIE, dans le boitier
```

- **Aucune fixation visible** : les vis passent au pourtour de la façade, à l'intérieur du boîtier.
- **Le PET n'est plus la surface de contact** — c'est le plexi. Le problème de rayure disparaît,
  et avec lui la raison d'être d'une plaque de serrage frontale.
- **La mousse répartit la pression** bien mieux que des vis ponctuelles (montage classique des
  claviers à membrane) et absorbe les tolérances d'un usinage à la main.
- **Les rainures Dremel vont dans le support arrière**, que personne ne voit : la précision
  d'usinage n'est plus un enjeu esthétique.

> **Conséquence : plus besoin de plexi épais sculpté.** Le bloc épais n'était nécessaire que
> lorsqu'il devait être structure **et** diélectrique mince. Ici la face avant est une simple
> plaque plate de 1,5–2 mm : **la poche fraisée à membrane régulière — le point le plus risqué du
> concept — disparaît**.

**Cadres visibles par transparence → impression en seconde surface.** Décor imprimé ou peint au
**dos** de la plaque avant : un bandeau opaque dessinant le contour de chaque touche, avec des
fenêtres claires pour la LED. Les broches et les bords du film se cachent derrière ce bandeau,
l'encre est protégée par le plexi lui-même, la face avant reste parfaitement lisse — c'est la
construction des façades d'appareils du commerce. Alternative assumée : laisser les cadres
visibles comme un liseré net autour de chaque touche (sur un clavier piano, une séparation
franche entre touches peut être un parti pris).

Mise en œuvre :

- **Fil dépassant de 0,1–0,2 mm**, pas plus : sous une plaque rigide la pression se concentre sur
  les lignes de fil (ce qu'on veut) sans tendre le film au point de le marquer.
- **Cyano aux angles des rainures seulement**, jamais dans la zone de contact — de la colle entre
  fil et ITO et le contact est mort.
- **Ne pas serrer fort** : au-delà du contact établi la pression n'apporte plus rien. Serrer en
  surveillant l'histogramme du scope : dès que le pic « broche nue » disparaît, c'est bon.
- **Centre des cellules libre** de colle et de vis : c'est le chemin de la LED.

> Alternative **permanente** pour la version finale : **adhésif optique transparent** (3M 468MP /
> OCA) laminant le film au dos de la plaque avant — c'est la construction des écrans de téléphone.
> La question de la pression disparaît pour le film ; il ne reste qu'à plaquer les broches contre
> l'ITO par la mousse arrière.
>
> À éviter : simple **ruban adhésif en périphérie**. Pression faible et inégale au niveau des
> fils = retour des décrochages.

**Trois mesures à tirer du coupon :**

1. **Écarts inégaux entre cellules** (p. ex. 2 / 5 / 10 mm) plutôt qu'uniformes → c'est le
   cross-talk qui fixera le **pas du clavier 27 touches**, donc la largeur de façade.
2. **Coût de la garde** : Δ avec la broche de masse connectée, puis débranchée. Elle capte des
   lignes de champ qui allaient au doigt et ajoute de la capacité à la ligne de base — l'A/B dit
   ce qu'elle coûte en sensibilité pour ce qu'elle rapporte en cross-talk.
3. **Budget d'épaisseur en façade** : empiler des chutes transparentes sur le coupon et relever le
   Δ à chaque épaisseur. La question n'est plus « est-ce que ça passe » (réglé, ×6,4) mais
   « combien d'épaisseur puis-je m'offrir avant de descendre sous SNR 10 ». Nécessaire parce que
   **le PET exposé se raiera** sous les doigts — un clavier, ça se joue.

**Protection ESD.** Avec 0,125 mm de diélectrique au lieu de 1,5 mm de plexi, une décharge
statique atteint bien plus facilement la broche. Le self-cap tolérant plusieurs kΩ en série, une
**résistance série de 1–10 kΩ par canal** ne coûte rien en signal → à porter au schéma KiCad.

## Points ouverts
- **Électrode** : **ITO/PET transparent pleine surface** (cf. section ci-dessus) ·
  ruban cuivre adhésif · feuille cuivre · peinture conductrice (Bare/MG) ?
- **Membrane** : épaisseur mini fiable au Dremel (1 mm risqué à la main ?).
- **Fixation** de la carte électronique au dos + passage des fils.
- Garde de masse / blindage entre cellules (éviter le cross-talk) — faisable en cuivre aussi.
