---
name: conception-meca
description: Conventions de conception mécanique du NiDMI Seq — à charger avant de créer ou modifier un modèle OpenSCAD, de choisir un matériau, une épaisseur, un procédé de découpe, ou de proposer un empilement de façade. Couvre solidité (matière cassante, congés, trous d'arrêt), vérification des interférences, contrôle visuel des rendus, cotes sourcées vs estimées, et conséquences de fabrication.
---

# Conception mécanique — NiDMI Seq

Ce fichier se remplit **par accumulation**. Chaque règle vient d'une erreur réelle commise
sur ce projet, pas d'une bonne intention. Ajouter une ligne à chaque dérapage.

## 1. Faire un truc solide

C'est le critère qui prime, et il s'applique **pendant** le dessin, pas en relecture.

- **L'acrylique (PMMA) est CASSANT, pas ductile.** Il ne se déforme pas avant de rompre : il
  fissure. Une pièce mal dessinée ne casse pas au montage, elle casse trois mois plus tard.
- **Tout angle interne vif est une amorce de fissure.** Mettre un **congé** partout où de la
  matière rentre dans de la matière. Ordre de grandeur : `r ≥ 1 mm`, et davantage si l'entaille
  est profonde.
- **Fond de fente = trou d'arrêt.** Une fente qui se termine en angle vif propage une fissure
  depuis son extrémité. Percer un trou en bout de fente (diamètre > largeur de fente) l'arrête.
  Technique d'atelier standard, en tôlerie comme en plastique.
- **Se méfier des porte-à-faux longs sur matière cassante** : dents de peigne, languettes,
  becs. Élargir l'encastrement plutôt que d'affiner la dent.
- **Nommer le mode de défaillance** quand on propose une pièce : par quoi va-t-elle casser, et
  au bout de combien de cycles ? Sur un instrument, une touche est sollicitée des dizaines de
  milliers de fois.
- Si la solidité et l'optique s'opposent (chants polis, épaisseurs), **le dire explicitement**
  au lieu d'arbitrer en silence.

## 2. Ne pas confondre la géométrie de la pièce et celle de l'électrode

**Erreur commise** : avoir découpé le plexi sous les touches noires « pour séparer les
électrodes », créant porte-à-faux et amorces de fissure dans une matière cassante.

Sur un clavier **capacitif**, ce qui sépare les touches c'est le **dessin de l'électrode** et
les **gardes à la masse**. Le plexi n'est que diélectrique et guide de lumière. **Rien ne
bouge** : il n'y a donc aucune raison mécanique de le découper.

**Avant de retirer de la matière, se demander quelle fonction l'exige.** Une découpe se
justifie par un mouvement, un passage, ou une isolation optique **mesurée** — pas par une
séparation qui se règle au niveau de l'électrode.

Référence : l'Arturia MicroFreak est un clavier capacitif **plat**, blanches séparées par de
simples reliefs peu profonds (« shallow ridges »), noires portées par une couche légèrement
surélevée, aftertouch polyphonique obtenu en mesurant la surface de contact du doigt.
([Sound On Sound](https://www.soundonsound.com/reviews/arturia-microfreak),
[MusicRadar](https://www.musicradar.com/reviews/arturia-microfreak))

> Partir de la forme la plus **solide** (le bloc plein) et n'enlever que ce qu'une fonction
> réclame. On était parti d'un bloc ; on en est sorti pour un problème de pollution lumineuse
> **non encore mesuré**. Mesurer d'abord, découper ensuite.

## 3. Vérifier les interférences avant d'annoncer un empilement

Deux pièces ne peuvent pas occuper le même volume. **Erreur commise** : les caches du clavier
étaient modélisés en blocs pleins traversant les touches — ils les masquaient entièrement.
Un cache, un capot, une bordure sont des **profilés** (L, U), pas des parallélépipèdes.

Avant d'affirmer qu'un empilement tient : passer chaque paire de pièces voisines en revue,
et vérifier que les jeux existent réellement dans le modèle.

## 4. Regarder le rendu avant d'affirmer ce qu'il montre

**Erreur commise plusieurs fois** : rendus annoncés comme probants alors qu'ils étaient vides,
mal cadrés, ou que les pièces transparentes y étaient invisibles.

- Toujours **ouvrir l'image produite** et la décrire avant de conclure quoi que ce soit.
- Prévoir un **mode de vue opaque** pour le contrôle (`vue_plan`) : une pièce en acrylique
  translucide ne se voit pas sur fond clair.
- Si une pièce est faite pour être cachée (cache, PCB de tranche), **aucune vue assemblée ne la
  montrera** — prévoir une vue dédiée avec les masquants désactivés, ou une coupe.

## 5. Cotes sourcées, cotes estimées

- Sur toute grandeur **normalisée ou documentée**, chercher la référence sur le web **avant**
  de modéliser. **Erreur commise** : plusieurs messages perdus à raisonner de mémoire sur la
  géométrie du clavier de piano, jusqu'à « corriger » à tort un modèle qui était juste.
- **Marquer explicitement** dans le code et la doc toute valeur estimée, avec ce qu'il faudrait
  mesurer pour la caler.
- Attention à **quelle cote** on prend : la noire de piano fait ~9,5 mm au sommet mais 13,7 mm
  à la base. Sur une façade plate, c'est la base qui compte. Prendre la mauvaise donne des
  proportions visiblement fausses.

## 6. La fabrication fait partie du dessin

Sortir les conséquences de fabrication **dans le même mouvement** que la géométrie, pas trois
messages plus tard. **Erreur commise** : la longueur de coupe et l'état de chant sont arrivés
après coup — et ont changé le procédé, puis le nombre de pièces.

À chiffrer en même temps que la forme :

- **longueur de coupe** et **nombre de pièces** (27 pièces et 5 m de coupe ne se manipulent pas
  comme 2 pièces et 4,3 m) ;
- **état de surface exigé par la fonction** : un guide de lumière a besoin de chants
  **optiquement polis** → découpe **laser** (elle fond la matière et polit naturellement), pas
  Dremel qui impose de polir à la main ;
- **ce qui reste faisable à la main** : la gravure au dos veut au contraire une surface
  diffusante, donc Dremel.

## 7. Ce que l'utilisateur sait et que je ne peux pas chercher

Patrice démonte des claviers pour les réparer et conçoit de la lutherie numérique. Son savoir
porte sur les **modes de défaillance réels**, ce qu'un atelier accepte de faire, et ce qu'un
doigt sent. **Le solliciter explicitement** plutôt que de conclure seul sur ces points-là.
