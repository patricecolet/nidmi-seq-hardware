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
