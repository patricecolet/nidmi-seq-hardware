# Mécanique — modèles paramétriques

> ## ⚠️ Deux fichiers sont PÉRIMÉS, gardés pour mémoire
> - **`facade.scad`** — implantation d'origine. Noires à espacement **régulier**
>   (ce n'est pas un clavier de piano), 5 encodeurs, écran 4,0″. Remplacé par
>   **`implantation.scad`**. Reste utile pour une seule chose : c'est le seul
>   modèle qui esquisse le **boîtier** (`show_box`).
> - **`cellule_plexi.scad`** — électrode dans une **poche fraisée** du plexi épais,
>   membrane de 1–1,5 mm. Concept **abandonné** : la pollution lumineuse mesurée
>   acceptable a permis de revenir au bloc plein, et l'électrode est passée sur une
>   plaque avant distincte. Remplacé par **`coupe_cellule.scad`**.
>
> Leurs rendus ont été supprimés du dépôt : une image fausse coûte plus cher
> qu'une image absente.

# Modèle d'origine (périmé) — façade plexi capacitive

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

## Plan global d'encombrement — `implantation.scad -D plan=true`

> 🟢 **2026-08-21 — le boîtier peut être dessiné.** Les cotes du CrowPanel
> Advance 7.0-HMI ont été **fournies par l'utilisateur**, qui a passé la commande
> et relevé les dimensions : elles ne figurent ni sur la fiche produit ni sur
> espboards. C'est la référence du projet — **ne pas chercher à les re-sourcer**.

> ⚠️ **Un seul fichier, pas trois.** Le plan a d'abord été écrit dans un
> `encombrement.scad` séparé, et `boite.scad` traînait encore à côté. Résultat :
> **trois modèles avec trois cotes de clavier différentes** (58+5, 52+18, et un
> ruban placé dans une rangée derrière le clavier). Les deux fichiers en trop ont
> été **supprimés** et tout est revenu dans `implantation.scad`.
>
> **Règle qui en sort : on corrige le modèle existant, on n'en ajoute pas un à
> côté.** Un modèle de plus, c'est une cote de plus à tenir à jour, et c'est comme
> ça qu'on fabrique des contradictions.

```sh
# le PLAN (3 vues 2D cotées)
openscad -o encombrement.png --imgsize=1500,2500 --projection=o \
  --camera=175,-15,0,0,0,0,1900 --colorscheme=Tomorrow -D 'plan=true' implantation.scad

# le modèle 3D de la façade (comportement par défaut, inchangé)
openscad -o implantation_complete.png --imgsize=1400,1150 --projection=o \
  --viewall --autocenter -D 'variante="complete"' implantation.scad
```

Chaque vue **nomme son plan de coupe** — c'est le point d'ambiguïté récurrent :

| vue | plan de coupe |
|---|---|
| **A** dessus | aucun — façade de face, tranche arrière rabattue au-dessus |
| **B** coupe longitudinale | vertical, axe avant-arrière, **au milieu** : traverse le clavier **et** l'écran |
| **C** coupe transversale | vertical, gauche-droite, **au droit de la rangée haute** |

Le clavier **en travers** n'est pas repris — `coupe_cellule.scad` le traite.

### Ce que le plan donne

| | cote |
|---|---|
| façade | **337,26 × 226,36 mm** (hors-tout 342,26 × 231,36) |
| hauteur intérieure | **33 mm** — minimale calculée 32,6 |
| hors-tout | **342 × 231 × 36,5 mm** |

**La largeur est imposée par la rangée haute** (313,26 mm), pas par le clavier
(298,8).

### La façade est un cache, et le plexi passe dessous

Décidé le 2026-08-21. La pièce de plexi n'affleure plus : elle est **sous la
façade**, que le doigt atteint par **deux ouvertures** — une pour les touches,
une pour le ruban. La bande de façade entre les deux **masque le dos du peigne
des noires et la zone de contact du film**, et un bord arrière masque la fin du
dos.

> 🔴 **Conséquence : le dos ne pouvait pas rester à 18 mm.** Il ne loge pas que
> le ruban ; il doit aussi donner à la façade de quoi cacher. Décompte :
>
> | | mm |
> |---|---|
> | cache (entre les deux ouvertures) | **6** 🔴 estimé |
> | jeux d'ouverture (3 × 1) | 3 |
> | ruban | 10 |
> | bord arrière | **5** 🔴 estimé |
> | **dos nécessaire** | **24** — il en manquait **6** |
>
> La pièce de plexi passe donc de 70 à **76 mm**, et la façade de 220,36 à
> **226,36**. Les deux valeurs en rouge sont des estimations : la largeur du cache
> devrait être dimensionnée sur l'encombrement réel de la reprise de contact
> (piste d'argent + connecteur ZIF), qui n'est pas encore arrêtée.

> ⚠️ `clavier_piano.scad` porte `Wh` et `dos` **en dur** (`use <>` n'importe pas
> les variables). Ils doivent valoir ce que calcule `implantation.scad` —
> **76 et 24**. Un echo le vérifie et crie `DESYNCHRONISE` sinon : c'est
> exactement le décalage qui, la fois précédente, avait laissé le ruban hors du
> plexi.

> 🔴 **Le poste dimensionnant en hauteur n'est plus l'écran : c'est le PB86.**
> À 20 mm il dépasse les 16 mm du CrowPanel. Or cette cote est **estimée** — le
> BOM note « hauteur/cap non publiés → STEP GrabCAD (`pb86-switches-1`) ». Tant
> qu'elle n'est pas relevée, l'épaisseur de l'instrument n'est pas figée.
>
> Les **~25 mm** du BOM §11 sont périmés : ils dataient du module 4,0″.

> 🟡 **Pas encore placés** : le PCB principal, les deux ESP32 et le câblage. Leur
> volume est réservé (12,6 mm) mais leur position attend le KiCad. Les zones
> **jaunes** sont ce qui reste libre.

### Les cartes, et la place qu'elles ont

Quatre cartes identifiées, plus l'alimentation qui n'est pas placée.

| carte | taille | note |
|---|---|---|
| **latérale gauche** (ESP32-B) | **71,5 × 131,9 mm** — 94 cm² | double face : boutons + molettes devant, ESP32 derrière |
| **latérale droite** (ESP32-C) | idem | idem |
| **LED avant** | 294,8 × 8 mm, verticale | 16 LED, injection en tranche des blanches |
| **LED du dessous** | 294,8 × 56 mm | posée sur le socle, dans la découpe de la mousse |

**Les latérales sont dimensionnées au maximum utilisable**, pas à l'emprise des
commandes. La rangée de boutons et molettes ne fait que 66 × 108,36 (71,5 cm²) ;
en prenant tout ce qui est libre à cette hauteur on obtient **94 cm², soit un
tiers de plus**. Les limites sont réelles, pas arbitraires :

- **en largeur**, jusqu'au bord de l'écran — au-delà, le CrowPanel descend à
  −16 mm alors que la carte est à −9,6 : elle ne peut pas passer dessous ;
- **en profondeur**, de l'arrière du clavier à la paroi arrière — vers l'avant, la
  pièce de plexi descend à −16,3 et barre le passage.

Hauteur disponible : **8 mm au-dessus** de la carte pour les composants
traversants, **23,4 mm en dessous** pour tout le reste. La carte s'arrête à 2 mm
de la paroi arrière, donc l'USB-C et des jacks peuvent y être **en bord de carte**.

**La connectique est en bord de carte**, plus de carte de connectique séparée ni
de fils vers la tranche : les latérales arrivent à 2 mm de la paroi arrière.

| | contenu | occupé / dispo |
|---|---|---|
| **gauche** | USB-C + CV, GATE, CLK, RST | **71** / 71,5 mm |
| **droite** | MIDI IN, MIDI OUT + audio L/R | **62** / 71,5 mm |

La répartition sépare l'**alimentation** (USB-C et les sorties 5 V, à gauche) des
**sorties audio** (à droite, loin du convertisseur à découpage, et du côté où
irait le moteur audio). L'entraxe de 12 mm n'est pas dicté par les embases mais
par le **diamètre des fiches** : une fiche 3,5 fait ~9 mm de corps, il faut
pouvoir la saisir. Le côté gauche est plein à 0,5 mm près.

> ⚠️ **Corrigé au passage** : `n_jack` valait **5** alors que son propre
> commentaire listait six jacks — MIDI IN, MIDI OUT, CV, GATE, CLK, RST. Il
> manquait donc un jack sur la tranche depuis le début.

> 🟡 Reste ouvert : ces deux cartes sont-elles **identiques** ? L'implantation
> étant boutons à l'extérieur et molettes à l'intérieur des deux côtés, la même
> carte tournée de 180° présente le bon ordre de l'autre côté — un seul dessin,
> une seule série. Charger l'une de l'alimentation et l'autre du moteur audio y
> ferait renoncer.

### Trois erreurs de dessin corrigées le jour même

**Les noires étaient tracées en bande pleine.** La position était juste mais la
lecture fausse : la bande coupait le plexi en deux et laissait croire que **la
pièce s'arrêtait avant le ruban**, alors qu'elle est d'un seul tenant — 52 mm de
blanches plus 18 de dos. Les onze noires sont maintenant tracées séparément, aux
décalages de facteur de piano, pour qu'on voie les **talons des blanches** passer
entre elles. C'est l'article 2 du skill `conception-meca` : le relief des noires
est **usiné dans la plaque**, il n'interrompt rien.

**La coupe B montrait un relief de noire qui n'existe pas là.** Prise au milieu,
elle tombe entre **si et do** — deux blanches adjacentes.

**Le clavier était dessiné en un bloc de 16,3 mm**, ce qui le faisait paraître
plus épais que l'écran. Faux : **le plexi ne fait que 10 mm**, donc *moins* que
les 16 de l'écran. Les 6 mm restants sont la **suspension** — mousse et socle.
Les couches sont désormais distinctes et cotées.

### Cotes réconciliées entre les trois modèles

`clavier_piano.scad` portait encore la géométrie d'avant l'architecture arrêtée.
Aligné sur `coupe_cellule.scad` :

| | avant | après |
|---|---|---|
| **pièce entière** (`Wh`) | 58 | **70** |
| dos du peigne (`dos`) | 5 | **18** — il porte le ruban |
| noire (`Bh` / `Lb`) | 36 | **32** |
| noires (`t_noires`) | plaque teintée 5 mm | **relief usiné de 1 mm** |
| caches | affichés | **supprimés** — c'est la boîte qui fait cet office |

> 🔴 **Le piège qui a fait rater le clavier deux fois : `Wh` est la longueur
> TOTALE de la pièce, dos inclus** — et non la partie avant. C'est
> `y_dents = Wh - dos` qui donne la fin des touches. En lisant `Wh` comme « la
> blanche » et en posant `Wh = 52, dos = 18`, on obtient une pièce de **52 mm**,
> pas de 70 : le plexi s'arrête alors **16 mm avant le ruban**, qui flotte dans le
> vide. Bon réglage : `Wh = 70`, `dos = 18`.
>
> Deux conséquences ont dû être corrigées dans la foulée :
> - `by0` mesurait la noire **depuis le fond de la pièce**, donc le dos la
>   rognait — avec un dos de 18 il n'en restait que 14 mm au lieu de 32. La noire
>   part maintenant de `y_dents - Bh` : elle fait `Bh` et **bute sur le dos**.
> - `noires_2d()` **inclut `dos_2d()`**, héritage de l'époque où les noires
>   étaient une plaque teintée rapportée avec son propre dos. Utilisé tel quel, le
>   dos sortait tout noir et le ruban disparaissait dessous. Le modèle 3D appelle
>   donc `blacks_2d()`, qui ne donne que le relief.
>
> 🟡 **Reste à trancher** : `clavier_piano.scad` sépare les blanches sur toute la
> zone de touche (52 mm), alors que `coupe_cellule.scad` arrête le trait de scie à
> **20 mm**. Les deux ne peuvent pas être vrais.

> ⚠️ `use <>` n'importe **que les modules et fonctions, pas les variables**. Les
> décalages des noires sont donc recopiés dans `implantation.scad` (`noires_plan`)
> pour la vue de dessus du plan, et doivent suivre `clavier_piano.scad`.

## Assemblage du clavier (`coupe_cellule.scad`)

> ### 🟢 2026-08-21 — architecture arrêtée en séance de conception
>
> Trois décisions structurent tout le reste. Elles remplacent le clavier plat et
> le peigne rapporté, tous deux abandonnés le même jour.

**1 — Une plaque continue d'acrylique par-dessus l'ITO**, avec le relief des
noires **usiné dedans**. Elle pince le film sur toute sa surface, protège
l'électrode partout et supprime la colle. Le doigt voit 1 mm sur une blanche,
2 mm sur une noire.

> 🔴 **Le seul chiffre qui verrouille le reste : l'aftertouch à 1–2 mm.**
> Mesuré : à travers **0,125 mm** (PET seul) la marge suffit ; à travers **10 mm**
> le contact est détecté mais l'aftertouch est perdu. L'intervalle n'est pas sondé.
> Se pince en un quart d'heure en empilant des chutes de PET sur une électrode et
> en relevant la dynamique entre effleurement et appui franc.
> **Une noire en relief rapporté de 3 mm était condamnée par là** : aftertouch sur
> les blanches et pas sur les noires, intenable sur un clavier.

**2 — Un seul film ITO pour tout**, touches et ruban gravés d'un seul coup. Un
seul calage, figé par le **masque** et non par le montage.

**3 — Trois éclairages indépendants.** Les blanches par la tranche avant, en
lumière guidée, extraite par la gravure. Les **noires et le ruban par en
dessous**, sur une **même carte horizontale**.

> **L'argument optique qui rend le point 3 possible.** Une LED couplée par
> l'**air** n'émet dans le PMMA qu'à **±42°** — exactement l'angle critique. Tout
> sort donc au premier contact et **rien ne passe en mode guidé** : cette lumière
> ne peut pas voyager horizontalement, donc elle n'interagit pas avec la gravure
> des blanches. Deux corollaires à ne jamais oublier :
> - **ne rien coller sous ces LED** — un indice ~1,5 rouvrirait le cône à 90° et
>   l'isolement disparaîtrait ;
> - **satiner le dessous de la plaque**, jamais la face inférieure du bloc, qui
>   renverrait de la lumière en mode guidé.

### Ce qui a été supprimé, et ce que ça rapporte

| supprimé | pourquoi | gain |
|---|---|---|
| cloison transversale + 2ᵉ symbole | l'écran porte le détail | 16 rainures et 16 lamelles en moins |
| lamelle noire des traits de scie | apportait plus de problèmes que de solutions | 15 pièces en moins |
| fente arrière + PCB partagé par la tranche | les LED sont passées dessous | une lame verticale en moins |

Le trait de scie **s'arrête à 20 mm** au lieu de descendre jusqu'à l'arrière :
plus aucun trait sous les noires ni sous le ruban, le bloc reste continu à
l'arrière, et les dents passent de porte-à-faux de 52 mm à des entailles de 20.
Le peigne cesse d'être la pièce fragile du projet.

Ce que portait le 2ᵉ symbole se répartit : **l'écran** prend le détail, la **LED
de la blanche** porte la grille métrique en fond sous l'état actif, et **un trait
de scie sur quatre** marqué donne le repère au doigt — les 16 blanches sont déjà
une rangée de 16 pas uniformes, il suffit de la marquer.

### Les cinq vues

**A** coupe en travers avant (moins de 20 mm du bord : la seule zone fendue) ·
**B** coupe en travers arrière au droit d'une noire (bloc continu, poche et LED
par en dessous) · **C** coupe en long d'une blanche jusqu'au ruban · **D** vue de
dessus du bloc (ce qui est usiné, et où) · **E** le film à plat.

```sh
openscad -o coupe_cellule.png --imgsize=1500,3000 --projection=o \
  --camera=58,-192,0,0,0,0,1080 --colorscheme=Tomorrow coupe_cellule.scad
```

| couche | ép. | rôle |
|---|---|---|
| **plaque acrylique** | 1 mm | la surface touchée · relief des noires usiné dedans (+1 mm) |
| **PET** | 0,125 mm | porteur du film |
| **ITO gravé** | ~0 | îlots d'électrodes ; la **garde est la mer** autour |
| film d'air | ~0,1 mm | le film est **plaqué** par la plaque, pas collé |
| **bloc PMMA** | 10 mm | guide de lumière des blanches · traits de scie sur 20 mm · poches par le dessous |
| fond sombre | ~0,05 mm | absorbe le halo non extrait · **fenêtre** sous chaque noire |
| mousse | 3 mm | **le ressort** — à faible déformation rémanente |
| socle | 2 mm | référence **rigide** des LED |

### Contact de l'électrode

**On ne contacte jamais l'ITO directement.** L'industrie sérigraphie par-dessus
une piste d'**argent** — le liseré sombre au pourtour des dalles tactiles — et
c'est l'argent qu'on contacte. L'encre d'argent fait ~0,01 Ω/□ contre ~100 Ω/□
pour l'ITO, soit des milliers de fois moins : **la distribution peut donc rester
sur le film** et sortir par une queue unique dans un connecteur à charnière.

Deux règles quelle que soit la solution retenue :

- la contrainte sur l'ITO doit être **uniquement perpendiculaire** à la surface.
  Jamais de cisaillement, jamais de traction : il fissure.
- **ancrer le film au niveau du contact** et le laisser flotter à l'autre bout.
  L'acrylique se dilate ~4× plus que le PET — **0,3 mm** sur la longueur du
  clavier pour 20 °C — et un film pincé aux deux bouts se met en tension.

> 🟡 L'argent migre sous tension continue en milieu humide. Parade proportionnée :
> surimpression diélectrique laissant les plages nues, ou vernis de tropicalisation
> sur la jonction. Le risque reste faible ici — plages espacées de millimètres,
> 3,3 V, boîtier clos, et pilotage en charge-décharge plutôt qu'en continu.

### La carte LED du dessous, et la découpe de la mousse

🔴 **La carte LED est POSÉE SUR LE SOCLE, et la mousse est découpée pour elle.**
Point rappelé par l'utilisateur le 2026-08-21 après avoir été perdu une fois —
il ne doit plus l'être. Trois conséquences :

- **Elle ne s'ajoute pas à l'empilement.** Elle vit *dans* l'épaisseur de la
  mousse, pas entre le bloc et elle. Le clavier reste à 16,3 mm sous la face
  touchée.
- **La mousse est le ressort ; la découper lui retire de l'appui** là où la carte
  passe, c'est-à-dire sous les noires et sous le ruban — donc sur presque toute la
  largeur. Il faut vérifier ce qu'il reste comme surface d'appui, et où, sinon le
  bloc s'appuie sur une couronne et fléchit au milieu.
- **La cote tombe juste, mais sans marge** : carte ENIG 0,6–0,8 + SK6812 3535
  ~1,9 = **~2,7 mm** au-dessus du socle, pour **3 mm** de mousse. La LED affleure
  sous le bloc sans entrer dans la poche — l'air est conservé, ce qui est
  exactement ce qu'on veut pour garder le cône à ±42°.

### Serrage

**Ne jamais serrer du rigide sur du rigide** : la pression devient imprévisible et
l'acrylique fissure. La **mousse est le ressort** ; les vis ne fixent qu'une
position, la mousse la convertit en force. Elle pousse le bloc contre la lèvre du
cadre supérieur, ce qui référence la face touchée sur une pièce **rigide** — c'est
ce qui garantit que la distance LED↔surface, donc le **diamètre des taches**,
reste identique d'une touche à l'autre.

On dimensionne donc un **écrasement**, pas un couple. Vis M3 dans des écrous logés
en poches usinées, jamais de taraudage dans l'acrylique, un point tous les 50 à
80 mm, et des **trous de passage surdimensionnés** à cause de la dilatation.

### Ruban

Sur le dos du peigne, même pièce de plexi — 24 mm de profondeur de façade libérés
puisqu'il n'a plus de rangée propre. **5 canaux**, interpolation spatiale, cotes
d'AT11805 : segments de bout **33,75 mm**, de milieu **56,25 mm** sur 180, zone
morte ramenée de 10 % à **3 %**, dents **4 mm** max et **0,25 mm** mini en pointe.

C'est un **témoin**, pas un vu-mètre : peu de LED et **interpolation lumineuse**
entre voisines, le recouvrement des halos faisant glisser la tache. Critère de
choix du pas : **pas ≤ largeur du halo**, à mesurer au banc. Le fondu ne sera pas
linéaire (le PWM l'est, la perception non) — la courbe se règle à l'œil.

> 🟡 **`clavier_piano.scad` modélise encore les noires en plaque teintée de 5 mm**
> — à réconcilier quand les cotes seront figées.

## Coupe d'une cellule (`coupe_cellule.scad`) — ⛔ **VERSION PÉRIMÉE, gardée pour mémoire**

> ⛔ **Ce qui suit décrit l'architecture d'AVANT le 2026-08-21** : deux plaques séparées
> par un entrefer de 1,5 mm, plaque avant de 2 mm, noires en relief rapporté de 3 mm,
> 18,7 mm d'empilement. **Remplacée** par « Assemblage du clavier » plus haut — plaque
> continue de 1 mm, relief usiné dedans, film plaqué sur le bloc.
>
> 🟡 **Un point de cette section reste ouvert et n'a pas été rejugé** : l'argument optique
> qui justifiait l'entrefer. L'ITO plaqué contre la face du guide met celui-ci en
> **réflexion totale frustrée** (l'indice du PET est proche de celui du PMMA) — la lumière
> sortirait sur tout le trajet au lieu de sortir aux points gravés. L'architecture actuelle
> a ramené l'entrefer à un **film d'air de ~0,1 mm**. Est-ce suffisant ? **À trancher.**


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

**Ce que la coupe montre au droit d'une noire.** L'électrode de la noire (violet)
est **dans le même plan** que celles des blanches : un seul film ITO porte le
**dessin complet du clavier**. Et les électrodes des blanches **s'arrêtent de part
et d'autre** — c'est l'équivalent électrique exact du talon de blanche sur un
piano. Sans cette troncature, toucher une noire déclencherait les deux blanches
sous elle. La géométrie de facteur de piano n'est donc pas qu'une affaire
d'apparence : **c'est le dessin de l'électrode**.

La noire est par ailleurs **son propre guide de lumière**, gravure sur sa face
inférieure, injection par la tranche arrière (invisible en coupe transversale).

> ⚠️ **Les noires sont pénalisées deux fois** : le doigt est à **5 mm** au lieu de
> 2 (3 mm de relief + 2 de plaque), **et** l'électrode est plus petite (~8,4 × 36
> contre ~16 × 45). Le signal variant en gros comme surface/distance, une noire
> est de l'ordre de **six fois moins sensible** qu'une blanche. La détection passe
> largement — seuils par canal, marge de plusieurs centaines. L'**aftertouch**, lui,
> devient douteux sur les noires.
>
> L'épaisseur de la plaque teintée n'est donc **pas** un simple choix
> d'approvisionnement, c'est un **paramètre capacitif** : à 2 mm au lieu de 3, le
> rapport tombe de 6 à ~4,5.
