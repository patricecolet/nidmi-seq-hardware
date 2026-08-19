# Essai — électrode ITO derrière membrane plexi, mesurée à l'ESP32-S3

Valide la question n°1 de [`CONCEPT_PLEXI_EPAIS.md`](CONCEPT_PLEXI_EPAIS.md) :
**une électrode ITO pleine cellule, derrière 1–1,5 mm de plexi, donne-t-elle un
signal capacitif exploitable ?** Tant que ce point n'est pas mesuré, la géométrie
de cellule (donc le KiCad, donc l'usinage) reste en suspens.

Banc : [`firmware/test_touch_ito`](../firmware/test_touch_ito) +
[`scripts/touch_log.py`](../scripts/touch_log.py).

## Matériel

- **ESP32-S3-WROOM-1 N16R8** sur platine d'essai — c'est **la puce cible du BOM**,
  et son *touch v2* est celui du produit final : les chiffres mesurés ici sont
  directement transposables (ce ne serait pas le cas d'un ESP32 classique, dont
  le *touch v1* a une polarité et une sensibilité différentes).
- Film **ITO/PET**, découpé aux ciseaux.
- **Ruban cuivre à adhésif conducteur** (3M 1181) pour la reprise de contact.
- Chutes de **plexi** de plusieurs épaisseurs (ou empilage de fines, bien pressées).
- Ohmmètre.

## Précautions de câblage (platine d'essai, dupont, borniers à vis)

Le montage volant est la principale source d'erreur de mesure — pas l'ITO.

- **Le fil fait partie de l'électrode.** 20 cm de dupont ajoutent une capacité
  parasite qui s'additionne à la ligne de base et *écrase le Δ relatif*.
  → fils **les plus courts possible** (< 10 cm si faisable), et **la même
  longueur pour tous les canaux comparés**.
- **Ne jamais comparer deux essais câblés différemment.** Changer un dupont
  invalide la comparaison : refaire la ligne de base (`b`) et re-mesurer la
  référence à vide.
- **Mesure de référence à vide d'abord** : fil branché sur le GPIO, **rien au
  bout**. Ça donne la contribution parasite du câblage seul, à retrancher
  mentalement de tout le reste.
- Ne pas faire courir les fils *touch* en parallèle serrés : ils se couplent
  entre eux (faux cross-talk qui n'existera pas sur PCB).
- Borniers à vis : serrer franchement, et **ne pas visser sur l'ITO** —
  seulement sur le cuivre rapporté ou sur le fil.
- **Garder les mains loin de la platine** pendant la calibration et pendant la
  lecture des canaux voisins.

## Précautions d'alimentation (effet réel et souvent ignoré)

La sensibilité du *self-cap* dépend du couplage de la masse de l'ESP32 à la
terre. Un portable **sur secteur** (donc relié à la terre) donne un Δ nettement
plus fort que le même montage sur **batterie**.

→ **Figer la configuration d'alim pour toute la campagne** et la noter dans le
tableau. Si la cible finale est une alim isolée, refaire au moins une mesure
dans cette condition avant de conclure.

## Préparation de l'échantillon ITO

1. **Trouver la face conductrice** : ohmmètre, deux pointes à ~1 cm.
   Face conductrice = dizaines à centaines d'Ω. Face PET = infini.
2. Découper une électrode **avec sa languette d'amenée** (cf. schéma du concept).
3. **Face conductrice contre le plexi** : elle doit être au plus près du doigt.
   Le PET (~0,125 mm) se retrouve derrière, sans conséquence.
4. Presser le **ruban cuivre conducteur** sur la languette, surface généreuse,
   puis souder le fil **sur le cuivre**. Vérifier la continuité ITO↔fil :
   dizaines/centaines d'Ω = normal et suffisant.
5. **Tout entrefer d'air fausse la mesure vers le bas.** Pour l'essai, presser
   fermement l'ITO contre le plexi (poids, pince, ou adhésif transparent fin).
   Noter la méthode de plaquage dans le tableau — elle fait partie du résultat.

## Déroulé

Pour chaque configuration, main éloignée → `b` (recalibration) → puis :

```sh
scripts/touch_log.py --secs 10 --out mesures/<config>.csv --label "<config>"
```

Pendant les 10 s : **doigt posé à plat, appui normal**, immobile. Le résumé
donne `d moy`, `d max` et `SNR max`.

### Séquence de mesures

| # | Configuration | Ce qu'on cherche |
|---|---|---|
| 0 | Fil seul, rien au bout | base parasite du câblage |
| 1 | ITO nu, doigt direct dessus | Δ plafond de l'électrode |
| 2 | ITO + membrane **1 mm** | sensibilité vs épaisseur |
| 3 | ITO + membrane **1,5 mm** (cible) | **le point de décision** |
| 4 | ITO + membrane **2 mm** | marge si le Dremel dérape |
| 5 | ITO + membrane **3 mm** | pente de dégradation |
| 6 | Électrode **15×15** vs **20×20** vs **25×25** mm, membrane 1,5 mm | surface mini viable |
| 7 | Contact cuivre seul vs cuivre + époxy Ag | le contact limite-t-il ? (attendu : non) |
| 8 | 2 électrodes voisines, écarts 2 / 5 / 10 mm | **cross-talk** : toucher l'une, lire l'autre |
| 9 | Idem 8 + bande de cuivre à la masse entre les deux | efficacité de la garde |
| 10 | Config 3 relue après 10 min de chauffe | **dérive** thermique |

### Critères de réussite

- **SNR max ≥ 10** (Δ ≥ 10× le bruit au repos) sur la config 3 → détection
  robuste avec un simple seuil.
- SNR entre 5 et 10 → exploitable mais demande un suivi de ligne de base
  (baseline tracking) dans le firmware final.
- **SNR < 5 → la piste ITO/1,5 mm ne passe pas** : revoir l'épaisseur de
  membrane avant de figer la mécanique.
- **Cross-talk** : Δ sur le canal voisin non touché < 1/5 du Δ du canal touché.
  Sinon → garde de masse obligatoire entre cellules (config 9).
- **Dérive** sur 10 min < 1/3 du Δ d'un doigt, sinon baseline tracking obligatoire.

## Choix des broches (mesuré, à ne pas supposer)

GPIO1–14 sont annoncées touch-capables ; sur la carte du proto **seules GPIO8, 9,
10 et 12 mesurent réellement**. Les autres rendent `4194303` (0x3FFFFF) avec un
bruit nul — signature d'une mesure qui n'aboutit pas, pas d'une grosse capacité.
**GPIO4 et GPIO5 sont le bus I2C** de la carte, avec pull-ups de 10 kΩ d'origine
(9 kΩ mesurés vers 3V3, carte hors platine, contre 500 kΩ sur GPIO6) : une broche
tenue à un potentiel fixe ne peut pas se charger/décharger, donc ne peut pas
mesurer. Passer `firmware/scan_touch` avant tout nouveau brochage.

## Résultats

Carte : ESP32-S3-WROOM-1 N16R8, alim par USB natif depuis le portable.
Électrode sur **GPIO8**. Bruit de référence d'un canal stable : σ ≈ 11 (GPIO9).

| # | Config | base | Δ (doigt) | Δ relatif | Note |
|---|---|---|---|---|---|
| 0 | broches libres, rien au bout | 28 100 – 31 600 | — | — | σ de 8 à 104 selon le canal |
| 1 | **ITO nu, doigt direct** | **249 500** | **+391 600** | **+157 %** | max 793 900 · **contact intermittent** |
| 1b | **ITO nu, contact pince croco** | **47 000** | **+253 000** | **×6,4** | contact stable, plus de décrochages |
| 1c | ITO, **opérateur relié à la terre** | 47 500 | +1 950 000 | ×42 | pic ~2 M |
| 1c′ | ITO, **opérateur flottant** | 47 500 | +202 000 | ×5,3 | plafond 250 k — **cas de conception** |
| 3 | membrane 1,5 mm | | | | sans objet si le design bascule (cf. concept) |

**Mesure 1 — détail.** Distribution trimodale sur 57 s : broche nue 32 900
(32,5 % des échantillons), électrode au repos 249 500 (45,9 %), doigt posé
641 100 (18,2 %). Le signal capacitif est donc très largement suffisant, mais
**19 décrochages** vers l'état « broche nue » trahissent un contact intermittent
(suspect n°1 : la jonction ITO ↔ ruban cuivre, qui ne se soude pas). Ces
décrochages polluent aussi la ligne de base : σ mesuré à 8 850 au lieu de ~11.
→ Fiabiliser le contact **avant** de mesurer à travers le plexi, sinon la
comparaison entre épaisseurs de membrane n'aura aucun sens.

**Mesure 1b — contact repris.** Une pince croco serrant l'électrode donne un
contact stable : repos 47 000, doigt 300 000, **×6,4**. Le capacitif est donc
validé avec une marge très large, et c'est ce qui autorise la bascule de design
décrite dans [`CONCEPT_PLEXI_EPAIS.md`](CONCEPT_PLEXI_EPAIS.md) (électrode près
de la surface sous revêtement fin, plexi réservé à la LED). Les mesures 2 à 5
« à travers la membrane » perdent alors leur objet ; restent pertinentes la
**taille d'électrode** (6), le **cross-talk** (8-9) et la **dérive** (10).

## Couplage à la masse — facteur 8 mesuré (2026-08-19)

Le self-cap ne mesure pas le doigt dans l'absolu : il mesure la capacité entre
l'électrode et la masse du système **à travers le corps de l'opérateur**. Mesuré
sur la même électrode, même séance :

| condition | plafond au toucher | rapport à la base |
|---|---|---|
| opérateur touchant la terre | ~2 000 000 | ×42 |
| **opérateur flottant** | **250 000** | **×5,3** |

**Régler tous les seuils sur la mesure flottante.** L'instrument fini sera souvent
mal relié (batterie externe, portable sur batterie, alim USB isolée) : un seuil
réglé sur la mesure reliée à la terre donnerait un clavier qui marche à l'atelier
et pas sur scène. Le cas flottant passe très largement — Δ ≈ 202 000 counts pour
un seuil à 241, soit 840× la marge.

**Conséquence pour le firmware du produit** : la ligne de base bouge avec les
conditions de masse (brancher un câble MIDI, un jack CV ou une alim reliée à la
terre change le couplage). Les seuils en **counts absolus sont donc à proscrire**
→ seuil **relatif** (% de la base) + **suivi de ligne de base** (baseline
tracking). Sans objet pour le banc, indispensable pour le produit.

**Levier de conception validé** : la **masse de la carte suffit** — inutile de
rejoindre la terre du secteur. Vérifié en tenant un fil relié au GND de la carte :
le toucher remonte aux ~2 000 000 du cas « relié à la terre ». Donc une **bordure
métallique reliée au GND de l'électronique, là où la paume se pose**, améliore le
couplage du joueur et stabilise la sensibilité, sans rien coûter. À intégrer au
dessin de façade et à essayer sur le coupon.

## Exigences firmware qui découlent des mesures

**Seuil relatif, jamais en counts absolus.** Le contact vaut **+425 %** de la ligne
de base dans le cas défavorable (opérateur flottant) et jusqu'à +4000 % relié à la
masse, quand le bruit vaut quelques dizaines de counts. Un seuil calé sur le bruit
(8σ ≈ 280 counts, soit 0,7 % de la base) est franchi par la dérive **et par une main
qui passe à 20 cm** — l'électrode détecte la proximité bien avant le contact.
Mesuré : seuil à **50 % de la base** sépare contact et approche avec un facteur 8
de marge. Réglable en direct au curseur du client (`S1`…`S200`).

**Suivi de ligne de base obligatoire.** Température et **hygrométrie** déplacent la
base en continu ; sur quelques heures la dérive dépasse largement le bruit, et un
seuil calculé une fois pour toutes finit par déclencher seul. La base est donc
réajustée en permanence (constante ~60 s), **gelée pendant un contact** — sinon un
doigt maintenu serait absorbé dans la base et la touche se relâcherait d'elle-même.

**Ne jamais relâcher une touche d'office.** Un contact très long est légitime sur un
instrument : note tenue, pédale, bourdon, doigt posé pendant un arpège. Un
ré-étalonnage automatique après N secondes couperait la note — et pire, absorberait
la valeur touchée dans la base, faussant la détection au relâchement. Le firmware
**signale** un contact > 60 s, il n'agit pas. Un canal réellement bloqué est un
problème de calibration, à corriger par une recalibration explicite.

## Latence tactile — à mesurer

La montée au toucher est **progressive**, pas instantanée. Deux causes se cumulent :
le driver ne rend pas la valeur brute mais une valeur **lissée par un filtre IIR**
(`TOUCH_SMOOTH_IIR_FILTER_2`, configuration par défaut du core), et le contact
physique s'établit lui-même progressivement à mesure que la pulpe s'écrase.

Ça ne devrait pas poser problème — avec un seuil à ~280 counts pour un Δ de
200 000, le seuil est franchi dès les premiers instants de la montée, très loin du
plateau — mais **ce n'est pas mesuré**, et sur un clavier joué quelques dizaines de
millisecondes s'entendent. À chiffrer avant de figer le firmware : temps entre le
contact et le franchissement du seuil, sur plusieurs frappes, en jouant
normalement. Si nécessaire, le filtre est réglable (`touch_sensor_config_filter`)
et le moyennage du croquis (`OVERSAMPLE`) réductible.

## Ce que l'essai débloque

- ✅ → épaisseur de membrane et taille d'électrode figées → `cellule_plexi.scad`
  passe de paramétrique à coté définitif, puis **schéma KiCad**.
- ❌ → arbitrage à reprendre : membrane plus fine (risque Dremel), électrode plus
  grande, ou retour à une électrode cuivre en anneau.
