# Étude — diffusion / diffraction de la lumière (touches + boutons RGB)

> But : trouver l'empilement qui donne une **cellule qui glow de façon homogène**
> (pas de point chaud, pas de bavure sur la voisine) à travers le plexi, tout en
> gardant la **sensibilité capacitive**. Étude empirique sur échantillons.
>
> Vocabulaire : **diffusion** = étaler la lumière (glow homogène, le besoin).
> **Diffraction** = réseau qui sépare les couleurs (effet arc-en-ciel, optionnel/déco).

## Variables à tester

| Variable | Valeurs à essayer |
|---|---|
| **Matière overlay** | acrylique transparent · acrylique **dépoli/sablé** · acrylique **opale/diffusant** |
| **Film ajouté** | aucun · film **diffuseur** (feuille LCD) · film **diffraction** (réseau, effet déco) |
| **Épaisseur plexi** | 1,5 · 2 · 3 mm |
| **Entrefer LED→plexi** | 0 (collé) · 2 · 3 · 5 mm |
| **Cloison de cellule** | sans · avec paroi opaque (puit de lumière, anti-bavure) |
| **Type LED** | SK6812 **3535** (front-fire) · **MINI-E** (à travers découpe PCB) |
| **Électrode au-dessus de la LED** | anneau (trou central) · hachure · fenêtre |

## Ce qu'on observe / mesure
- **Homogénéité** : point chaud central vs glow uniforme sur toute la cellule.
- **Bavure** : la lumière déborde-t-elle sur la cellule voisine ? (→ cloison).
- **Mélange RGB** : le blanc (R+G+B) est-il uniforme ou irisé en bord ?
- **Luminosité** : perte due au diffuseur (plus c'est diffus, plus ça perd).
- **Sensibilité capacitive** : l'entrefer qui aide la diffusion **dégrade** le tactile
  → trouver le compromis (entrefer mini + diffuseur, ou pad collé + poche LED).

## Compromis clé à arbitrer
- **Diffusion veut de la distance** (entrefer, plexi épais, diffuseur) ;
- **Capacitif veut la proximité** (pad près du doigt, peu d'air).
- → tester les deux stacks : **(A) pad collé au plexi + LED en poche** (capacitif fort,
  diffusion via plexi dépoli) vs **(B) entrefer 2-3 mm uniforme** (diffusion facile,
  capacitif à compenser par pads plus grands + tuning seuil).

## Échantillons à se procurer
- Chutes acrylique : transparent, dépoli, opale (2 mm prioritaire).
- 1 feuille **film diffuseur** (récup écran LCD HS) ; option : 1 **film diffraction**.
- 2-3 **SK6812** (3535 + MINI-E) sur une mini-carte ou breakout pour piloter le RGB.
- (Pilotage test : un ESP32 + lib NeoPixel/FastLED suffit.)

## Décisions que cette étude débloque
- SK6812 **3535 vs MINI-E** (BOM §2, décision #6).
- Stack de cellule **A vs B** (entrefer) → impacte `spacer_t` et la sensibilité.
- Finition plexi (dépoli/opale) + film éventuel.
- Géométrie électrode (anneau/hachure/fenêtre) → routage PCB des touches.

## Source de test : LED bleues de récupération (2026-08-19)

Lot de LED CMS 2 pattes identifiées au banc `firmware/test_led` : **bleues monochromes**
(seuil ~3 V), encoche = cathode. Identification faite avec le mode auto (LED entre deux GPIO,
polarité alternée, un éclair long vs trois clignotements pour lire le sens).

**Lot inventorié (2026-08-19)** : **76 oranges, 7 vertes, 3 bleues** (86 au total).
Provenances probablement différentes → ne pas généraliser une observation d'une couleur à l'autre.

**Méthode imposée par la répartition** : mettre au point la géométrie de poche avec les
**oranges** (abondantes, sacrifiables au fil des essais Dremel), puis **valider la géométrie
retenue avec une bleue** — seulement 3 en stock, à ne pas gaspiller en tâtonnements.

**Vertes : famille à déterminer.** Vert traditionnel (seuil ~2,1 V) → brille comme les oranges.
Vert **InGaN** (~3,2 V) → se comporte comme une bleue, quasi éteint en 3,3 V, rail 5 V obligatoire.
La sonde `m` de `firmware/test_led` tranche en une mesure.

> **76 oranges > 27 touches** : de quoi monter une **maquette de façade complète illuminée** sans
> rien acheter. Le choix RGB étant acté (BOM §2), elle ne sert plus à trancher monochrome/RGB mais
> à répondre à une question indépendante de la couleur : **la lumière d'une cellule déborde-t-elle
> sur sa voisine ?**
>
> ⚠️ **Débordement lumineux et cross-talk capacitif contraignent tous deux le pas du clavier.**
> Les mesurer sur le **même coupon**, avec les mêmes écarts entre cellules (2 / 5 / 10 mm) — cf.
> `ESSAI_ITO_ESP32.md`. Fixer l'entraxe sur le seul capacitif exposerait à découvrir ensuite que
> les halos se chevauchent.

**Repère d'anode (à revalider par couleur)** : inscription sur le flanc du boîtier, lue **cellule
vers le haut → anode à gauche**. Vérifié au banc en mode sens. Comme le lot est mélangé, revalider
sur un échantillon de chaque couleur avant de s'y fier pour un montage en série. Vérifier aussi
que l'encoche et l'inscription latérale désignent bien le même côté.

**Pour l'étude, utiliser les BLEUES** : c'est le cas le plus défavorable (seuil le plus haut donc
courant le plus faible à montage donné, longueur d'onde la plus courte donc diffusion la plus
marquée). Une géométrie de poche qui donne un halo homogène en bleu le donnera dans toutes les
couleurs ; valider sur une rouge bien lumineuse donnerait un résultat trop optimiste. Garder une
rouge pour comparer dans la **même** poche : l'écart dira si la teinte influe sur l'homogénéité
perçue, utile avant de figer la géométrie pour du SK6812 RGB.

**À alimenter en 5 V + 100 Ω (≈ 20 mA) pour tout essai de diffusion.** En 3,3 V il ne reste que
0,1–0,3 V aux bornes de la résistance → ~2 mA, un dixième du nominal : assez pour identifier la
LED, pas pour juger d'un halo. Corollaire : **une LED bleue ou blanche ne se pilote pas depuis
une broche d'ESP32** (3,3 V ≈ son seuil) — il lui faut le rail 5 V, que le BOM prévoit déjà pour
les SK6812.

> Ces bleues servent à étudier la **géométrie** (profondeur de poche, dépoli, homogénéité du
> halo), pas le rendu final : le BOM prévoit du SK6812 RGB. Conclure sur les formes et les
> distances, pas sur l'intensité ni la teinte perçues — le bleu diffuse un peu plus que le rouge
> à géométrie égale.

## Résultat : guide de lumière à éclairage latéral (2026-08-20)

**Principe validé au proto.** LED sur la **tranche** ; la lumière se propage dans le plexi par
réflexion totale interne et ne sort qu'où la surface est perturbée. La **gravure Dremel** joue le
rôle de structure d'extraction — même principe que les rétroéclairages de dalles LCD.

**Gravure au DOS, pas en face avant** (comparé au proto) : la face avant reste lisse, donc la
réflexion totale y est préservée et la lumière rebondit jusqu'à trouver la gravure ; on regarde un
halo diffus **à travers** de l'acrylique poli, plus net qu'une surface dépolie côté spectateur.
Bénéfices annexes : façade lisse (pas de rainures à crasse ni à rayures), et **la gravure masque
l'électrode** → l'impression en seconde surface envisagée pour cacher le bus bar devient inutile.

**Cross-talk optique : faible.** Une gravure s'allume nettement en face de sa LED et « presque
pas » à côté. C'est la réponse à l'une des deux contraintes qui fixaient le pas du clavier
(l'autre étant le cross-talk capacitif, cf. `ESSAI_ITO_ESP32.md`).

**Deux leviers, qui s'opposent** : la *densité et la profondeur de gravure* règlent la quantité de
lumière extraite (plus creusé = plus lumineux, mais diffuse aussi vers les voisines) ; la
*distance LED↔gravure et l'angle du faisceau* règlent la sélectivité. Chercher le point où la
touche est lisible sans que sa voisine s'éclaire.

**Renfort possible** : une **rainure entre cellules** fait barrière optique à la lumière rasante.
Elle tombe au même endroit que la broche de garde à la masse et les vis de fixation — trois
fonctions dans une zone déjà perdue pour l'optique comme pour le capacitif.

### ⚠️ Tension avec le capacitif — à mesurer

Le guide ne fonctionne que tant que ses faces sont **au contact de l'air**. Plaquer le film ITO
contre la face arrière met le système en **réflexion totale frustrée** : l'indice du PET (~1,57)
est proche de celui de l'acrylique (~1,49), donc la lumière sort **partout où le film touche**, et
plus seulement au niveau de la gravure → perte de la sélectivité. Le capacitif, lui, veut
l'électrode au plus près. Les deux exigences s'opposent.

**La marge permet de trancher en faveur de l'optique** : ×5,3 dans le cas défavorable, 840× le
seuil. Une lame d'air de quelques dixièmes de mm ne coûte qu'une fraction de cette marge.

**Mesure à faire** (banc `firmware/banc_cellules`) : relever le Δ **film plaqué** puis **film
légèrement décollé**, et vérifier à chaque fois si la gravure voisine s'allume. On obtient ce que
l'entrefer coûte en capacitif contre ce qu'il rapporte en sélectivité optique.

> Montage : **l'ITO se fissure sous contrainte** et une arête de gravure est un point dur. Ne pas
> presser le film contre la face gravée avec un appui ponctuel.

### Conséquence pour la décision BOM #6 (SK6812 3535 vs MINI-E)

Le critère change : il ne s'agit plus d'éclairer *depuis l'arrière* mais d'**injecter dans la
tranche** du guide. La question devient celle du couplage LED→tranche (position, angle, logement
fraisé), pas celle de l'émission frontale.

## Touches noires : teinte, puissance et pilotage (points ouverts)

Constat de départ : une plaque **teintée dans la masse** absorbe sur toute la longueur du guide
— à l'aller **et** sur le trajet d'extraction. Augmenter la puissance de la LED ne fait que
compenser une perte volontairement introduite, au prix du courant et de la chaleur.

**Piste privilégiée : guide en acrylique CLAIR + masque noir opaque** (peinture ou film au dos,
sauf au droit de la gravure). La touche est franchement noire à l'arrêt — plus qu'un teinté — le
guide garde son rendement, et à l'allumage c'est la **gravure qui s'illumine sur fond noir**. Sur
une touche de fonction, un symbole lumineux apparaissant dans le noir a plus d'allure qu'une
touche entièrement éclairée.

**Mesure préalable à toute commande** : la **transmission de la plaque candidate** (LED derrière,
comparée à du clair). Un facteur 5 de perte ne se rattrape avec aucune LED raisonnable.

**Monochrome pour les noires — à confronter à la VISION.** En vue PATTERN les noires portent les
**fonctions**. Sans couleur il reste luminosité et clignotement pour distinguer leurs états
(inactive / armée / active). Probablement suffisant pour 11 touches de fonction, contrairement aux
16 pas où l'on distingue accent, swing et durée — mais à vérifier dans la VISION avant de figer.

> ⚠️ **Conséquence BOM** : 11 LED blanches hors du bus SK6812 = **second circuit de pilotage**.
> Les MCP23017 déjà présents ne font que du tout-ou-rien (pas de PWM) → il faudrait un driver LED
> dédié sur l'I2C. **Avant d'accepter ce coût, tester si un SK6812 piloté en blanc plein suffit** :
> un seul bus, une seule référence, un seul firmware. Test de dix minutes.

## Essais de gravure — trois résultats (2026-08-20)

**Pollution lumineuse entre touches : acceptable.** Mesuré sur le proto. C'est ce qui autorise
le **bloc plein** (pas de découpe des touches) — cf. `CONCEPT_PLEXI_EPAIS.md` et
`mechanical/clavier_piano.scad` (`separation = "rainure"`).

**1. Gradient d'extraction — reliefs peu profonds près de la LED, de plus en plus prononcés en
s'éloignant.** C'est le principe fondamental du guide latéral : chaque motif prélève de la
lumière, donc le flux décroît le long du trajet. Une extraction **croissante avec la distance**
compense et donne une luminosité uniforme. Même principe que les motifs des rétroéclairages de
dalles LCD, clairsemés près des LED et denses à l'autre bout.

**2. Les points extraient mieux qu'une rainure continue.** Deux raisons : un point diffuse dans
toutes les directions là où une rainure renvoie surtout perpendiculairement ; et la **densité de
points** se module finement, ce qui est le levier naturel pour réaliser le gradient du point 1
— bien plus praticable au Dremel que de faire varier la profondeur de gravure.

**3. Un fond sombre optimise le rendu.** Il *réduit* le flux total émis mais absorbe le halo
parasite non extrait : les points ressortent nettement au lieu d'être noyés dans un fond diffus.
C'est un gain de **contraste**, pas de flux. Bénéfice secondaire : il absorbe aussi la lumière
rasante qui partirait vers les touches voisines — le fond sombre est donc en même temps un
traitement **anti-pollution lumineuse**. Confirme la piste « guide clair + masque noir »
envisagée pour les noires : elle vaut pour toute la façade.

### Numéro de pas gravé — idée à arbitrer

Graver le numéro de pas dans le motif d'extraction : le chiffre devient la légende **et**
l'émetteur, il s'allume au lieu d'être imprimé. Deux réserves :

- **Surface d'extraction faible** : un chiffre extrait bien moins qu'une plage de points, donc
  il sera plus sombre. Combiné au gradient, les chiffres éloignés de la LED devront être plus
  gras ou plus densément pointillés.
- ⚠️ **Une gravure reste visible éteinte** (elle diffuse en lumière ambiante). Or la VISION fait
  changer le sens des touches selon la vue : en ROLL les blanches sont un clavier chromatique,
  pas des pas. Un « 12 » gravé en permanence sur une touche qui joue parfois un ré est une
  légende fausse la moitié du temps. → soit chiffre discret assumé comme décor, soit légende
  reportée sur l'écran.

## Cloisons entre touches — mesuré (2026-08-21)

**Montage retenu : trait de scie traversant entre blanches**, bloc uni dans la partie cachée
(peigne), film transparent collé par-dessus. Le film **unifie la surface et bloque la poussière**
— une fente ouverte sur un instrument joué se remplit de crasse et devient inintéressable.

**Résultat d'essai :**

| cloison | lumière qui passe |
|---|---|
| trait de scie **nu** | « un tout petit peu » |
| trait de scie + **lamelle noire** | **rien du tout** |

**Deux prédictions théoriques corrigées par la mesure :**

1. **Une lame d'air nue ne réfléchit PAS la lumière guidée.** La normale d'une paroi verticale
   est horizontale, or la lumière guidée voyage presque à l'horizontale : elle frappe la cloison
   bien sous l'angle critique (42° pour PMMA/air) et la traverse. Seuls les rayons les plus
   inclinés (> 42° du plan de la plaque) sont réfléchis, et ils sont minoritaires.
   → **C'est l'ABSORPTION qui fait la barrière**, pas la réflexion totale. Elle agit à tous les
   angles.

2. **Mais l'atténuation nue est bien meilleure que la théorie ne le laissait craindre**, parce
   qu'un trait de scie n'est pas une paroi optique : c'est une surface **dépolie**. Elle diffuse
   au lieu de transmettre — ce qui traverse ne repart plus en faisceau guidé et s'éteint.
   → ⚠️ **La rugosité est un ATOUT ici, pas un défaut.** Corrige un conseil antérieur (« polir
   les parois de cloison ») qui ne valait que pour un mécanisme de réflexion totale inapplicable.
   **Aucun polissage n'est requis dans les fentes.**

> **La tranche d'INJECTION reste l'exception** : elle doit être nette. Une face dépolie à
> l'entrée disperse le flux avant qu'il n'entre dans le guide.

**Ce qui compte pour une cloison** : sa **profondeur** (elle doit occuper une bonne part de
l'épaisseur du guide), pas sa largeur — une interface n'a pas d'épaisseur. Fine et profonde,
jamais large et superficielle. Une découpe traversante est donc le cas idéal, et elle permet en
plus de **glisser une lamelle noire** dans le trait, ce qu'une rainure borgne ne permet pas.

> Point restant à vérifier : **le film continu collé par-dessus peut lui-même conduire un peu de
> lumière** d'une touche à l'autre. Au droit d'une fente il a de l'air dessus et dessous, donc il
> devient localement un mini-guide qui enjambe la coupure. Effet probablement faible (film très
> mince) mais à mesurer, pas à supposer.
