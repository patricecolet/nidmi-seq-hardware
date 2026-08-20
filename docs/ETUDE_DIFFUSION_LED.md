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
