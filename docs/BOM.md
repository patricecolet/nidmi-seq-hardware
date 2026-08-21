# BOM — NiDMI Seq (variante plexi capacitive)

> **Source de vérité composants.** Le hardware doit correspondre exactement :
> chaque pièce est définie ici (réf + cotes + implémentation). Le **boîtier suit
> les composants** (modèle `mechanical/facade.scad` paramétrique). Si une pièce
> sourcée diffère, on met à jour la cote → le boîtier se recalcule.
>
> Statuts : 🟢 décidé · 🟡 réf à sourcer/confirmer · 🔴 décision ouverte

## 1. Calcul — 3× ESP32-S3-WROOM-1-N16R8 🟢
- Module 18 × 25,5 × 3,1 mm, castellated/SMD sur PCB.
- Rôles : **A = cerveau** (séquenceur, MIDI, USB, SPI écran, bus LED, comms) ·
  **B + C = tactile** (27 touches + ruban répartis) + lecture encodeurs/boutons.
- *touch* natif = 14 canaux/puce ; 27 touches + ruban (~5) = ~32 / 42 dispo.

## 2. Clavier piano — touches capacitives (27) 🟢 / LED 🟡
- **Électrodes** : cuivre sur PCB (pas de composant). 16 blanches notchées **17 mm**
  + 11 noires **12 mm**, anneau/garde de masse, **R série 470 Ω–2 kΩ / canal**.
- 🟢 **2026-08-21 — PLAQUE ACRYLIQUE CONTINUE, relief usiné dedans.** Une plaque
  de **1 mm** par-dessus l'ITO, avec le relief des noires (**+1 mm**) usiné dans la
  masse. Elle pince le film sur toute sa surface, protège l'électrode partout,
  supprime la colle. Deux options écartées le même jour : le **clavier lisse**
  (pas de repère au doigt, refusé) et le **relief rapporté de 3 mm** (l'aftertouch
  passe à travers 0,125 mm et pas à travers 10 — à 3 mm les noires l'auraient
  perdu alors que les blanches l'auraient gardé).
  🔴 **À mesurer avant de figer : l'aftertouch à 1–2 mm.** C'est le chiffre dont
  dépend toute l'architecture. Détail : `mechanical/README.md`.
- 🟢 **2026-08-21 — contact par piste d'ARGENT sérigraphiée**, jamais sur l'ITO nu.
  ~0,01 Ω/□ contre ~100 pour l'ITO, donc la distribution reste **sur le film** et
  sort par une queue unique dans un connecteur à charnière. Contrainte
  **perpendiculaire uniquement**, et film **ancré au niveau du contact** (dilatation
  différentielle acrylique/PET : 0,3 mm sur la longueur du clavier).
- 🟢 **2026-08-21 — éclairage des noires PAR EN DESSOUS**, une LED par touche sur
  une carte horizontale posée sur le socle. Le trait de scie s'arrête à **20 mm**,
  donc le bloc est continu sous les noires. Supprimés : cloison transversale et
  2ᵉ symbole, lamelles noires, fente arrière. Le 2ᵉ symbole est reporté sur l'écran.
- **LED RGB par touche** : **27× SK6812 3535** (top-emit, 3,5 × 3,5 × ~1,5-1,9 mm),
  bus 1-fil 800 kbps GRB, **~60 mA/LED** à blanc plein. Variante reverse **MINI-E**
  (3,2 × 2,8 mm) si éclairage par découpe PCB. 🟡 figer 3535 vs MINI-E selon cellule.
- **Level-shifter data 3,3→5 V : 74AHCT125** (SK6812 VIH ≥ 3,4 V → 3,3 V hors spec).
- 🟢 **2026-08-19 — RGB confirmé, alternative monochrome écartée.** Une LED unicolore par touche
  aurait divisé la consommation par ~6 et supprimé le 74AHCT125 et le bus 800 kbps, à budget IO
  constant (driver matriciel type IS31FL3731 sur l'I2C déjà présent). **Écartée quand même** : la
  couleur est le seul canal **catégoriel** disponible, or les 27 touches changent de sens selon la
  vue et Shift bascule note↔fonction — sans couleur il ne reste que luminosité et clignotement,
  soit 6 à 8 états distinguables, et le clignotement fatigue sur une grille. Différencier pas,
  accents et swings demande la couleur.
- Les **1,6 A crête** ci-dessus correspondent au **blanc plein** (3 puces à fond). Une palette de
  travail en allume rarement plus d'une ou deux à luminosité modérée : le plafonnement reste sage,
  mais la marge réelle est confortable.

## 3. Encodeurs — 5× EC11 (avec push) 🟡 → **6 demandés** 🔴

> 🔴 **2026-08-15 — la conception en demande SIX.** `nidmi-seq-vst/CONCEPTION.md` §2
> donne une molette dédiée à chacun des deux niveaux de navigation, `Row` et `Pas`,
> qui ne sont jamais prêtées. Sans elles, changer de niveau demandait un raccourci à
> deux mains pour un geste qu'on fait sans arrêt en composant.
>
> **Électriquement, ça passe** : PCNT offre 4 unités par puce et les encodeurs sont
> répartis sur B et C, soit 8 places pour 6 — voir la répartition ci-dessous, à
> recalculer en B(3)/C(3).
>
> **Mécaniquement, à recaler** : le pas de 33 mm entre encodeurs sur une façade de
> 320 mm de large, et la fenêtre plexi. C'est le seul point ouvert.
- Réf : **Bourns PEC11R-4220F-S0024** (datasheet sûr, arbre 20 mm) *ou* **Alps
  EC11E18244AU** (LCSC C202365) *ou* générique EC11 5-pin 20 mm.
- Cotes (CAD) : corps **12,4 × 13,4 × ~6,5 mm**, bossage **M7×0,75 Ø7 × 5 mm**,
  arbre **Ø6 × 15/20 mm**, pattes ~3-3,5 sous PCB, **total ~31-32 mm** (arbre 20).
  Perçage panneau Ø7 + ergot anti-rotation. Bouton Ø15-20, alésage Ø6.
- Élec : A/C/B quadrature (PCNT) + SW/GND push. **Détentes : générique 20/20,
  Alps 15 PPR, Bourns 24** → 🔴 confirmer le ratio avant commande (impact firmware).
- PCNT = 4 unités/puce → **répartir les encodeurs** sur B+C : 5 en B(3)/C(2), ou **6 en B(3)/C(3)** si la demande ci-dessus est retenue.

## 4. Boutons de fonction — 8× PB86 🟡
- ROW · HARMONY · PROJET · SHIFT · PLAY · STOP · REC · EXPORT.
- 🟢 **PLAY + REC = PB86-A2** (bi-couleur rouge/vert, 8 pins) ; **6 autres = PB86-A1**
  (mono, 6 pins). → LED : 2×bi (4 lignes) + 6×mono (6 lignes) = **10 lignes**.
- Cotes : corps **12,4 × 17,0 mm**, course 2 mm, force 170 gf, SPDT, LED 1,8-2,4 V
  / 20 mA. **Hauteur/cap non publiés** → récupérer du STEP GrabCAD (pb86-switches-1).
- 🔴 **IO** : 8 switches + LED bi-couleur (16 lignes) = ~24 IO → via **expandeur
  I2C (MCP23017 ×1-2)** ou driver LED dédié. À figer. LED PB86 **hors** bus SK6812.
- **Diodes 🟢 → finalement AUCUNE** : les 16 lignes de LED imposent des **MCP23017**
  (voir §12) ; les 8 switches se câblent donc **en direct** sur l'expandeur (1 broche
  chacun) → **pas de matrice → pas de ghosting → pas de diode**. (La table « diode sur
  Shift/Play/Rec » ne s'appliquait qu'à une matrice scannée, abandonnée.)

## 5. Ruban capacitif — slider tactile natif 🟢
- Électrode PCB ~**180 × 10 mm** (motif triangulaire/interdigité), **~5 canaux**
  *touch* ESP32-S3, sous plexi. **Rôle : assignable** (choisi à l'écran). Pas de
  composant externe (R série éventuelle).

### 🟢 2026-08-20 — géométrie d'interpolation, d'après AT11805

Source : **AT11805 — Capacitive Touch Long Slider Design with PTC** (Atmel-42479B, 07/2015).
<http://ww1.microchip.com/downloads/en/AppNotes/Atmel-42479-Capacitive-Touch-Long-Slider-Design-with-PTC_AT11805_ApplicationNote.pdf>

**Ce qui ne s'applique PAS ici.** La note plafonne le slider *self-cap* à **3 canaux et
20–60 mm**, au motif que de grandes électrodes saturent la plage de mesure du périphérique
**PTC d'Atmel**. C'est une limite de *leur* puce et de *leur* bibliothèque, pas de la physique,
et nous n'utilisons ni l'une ni l'autre. Sur notre matériel : ligne de base mesurée
**~47 000 counts pour un plafond à 4 194 303**, soit 1 % de la plage ; et une électrode de ruban
à 5 canaux fait **~360 mm²** contre **~720 mm²** pour une blanche — **plus petite que ce qui
mesure déjà avec des centaines de fois la marge**. Aucun risque de saturation.
(cf. `docs/ESSAI_ITO_ESP32.md`)

**Ce qui s'applique — c'est de la géométrie, donc indépendant du fabricant.**

- **Interpolation spatiale** (dents entrelacées) : praticable **jusqu'à 200 mm**. Nos 180 mm
  passent, sans grande marge. Au-delà la note bascule sur l'interpolation résistive
  (diviseurs entre sous-électrodes, R totale 2–10 kΩ, 300 mm en deux couches, 350 en une).
- **Cotes de dents** : **4 mm maximum** entre deux dents consécutives, **0,25 mm minimum en
  pointe**. Sous 0,25, la surface sous le doigt s'effondre en bord de segment → décrochage
  du signal au passage d'un segment à l'autre.
- **Linéarité** : en tout point, la surface perdue par une électrode doit être exactement celle
  gagnée par sa voisine. C'est ce qui rend la position lisible.
- **Épaisseur de façade admise : 0,5 à 2 mm.** Notre PET fait 0,125 mm → large. (Constantes
  diélectriques tabulées : PMMA 2,8 · Mylar 3 · FR-4 5,2 · verre 7,8.)

**Découpage retenu — 5 canaux sur 180 mm.** N canaux → **N−1 segments**, dont 2 de bout et
N−3 de milieu. Formules de la note (vérifiées sur son propre exemple 240 mm / 7 canaux → 50 et
20 mm) :

    longueur_segment_milieu = (L × 1,25) / (N − 1)
    longueur_segment_bout   = [L − longueur_segment_milieu × (N − 3)] / 2

→ **segments de bout 33,75 mm · segments de milieu 56,25 mm** (2 × 33,75 + 2 × 56,25 = 180).
Des segments de bout plus courts que ceux du milieu, c'est ce qui ramène la **zone morte de
10 % à 3 %** : **~5,4 mm** à chaque extrémité au lieu de 18.

**Ce que les 5 canaux apportent sur 3** : à 3 canaux il n'y a que **deux segments de 90 mm**, et
la linéarité doit tenir sur toute cette longueur. À 5, chaque segment fait 56 mm → **~14 dents
au lieu de ~28**, motif ITO plus simple à graver et linéarité à tenir sur deux fois moins de
longueur. (À 7 canaux : segments de 37,5 mm, ~9 dents — mais 7 canaux tactiles à trouver.)

**Sans effet sur la décision broches** : à 5 canaux le ruban ne tient toujours pas sur les 5
broches libres du CrowPanel sans supprimer l'UART. La migration vers l'ESP32-B ou C reste acquise.

### 🟡 2026-08-20 — piste CrowPanel 7,0″ (écran + ESP32-S3 intégrés)

L'implantation de façade (`mechanical/implantation.scad`) libère la place d'un **7 pouces** :
avec 3 molettes de chaque côté de l'écran et les boutons en colonnes, la rangée haute fait
303,8 mm. Le **CrowPanel ESP32-S3 7,0″** (Elecrow, 800×480, actif 153,84 × 85,63 mm) embarque
la puce **et** l'écran, ce qui supprimerait la nappe FPC 40 broches et le routage des ~20
lignes RGB — l'obstacle qui avait fait écarter un 5″ RGB au profit du 4,0″ SPI.

⚠️ **Deux modèles, et la différence est décisive :**

| | broches libres | verdict |
|---|---|---|
| **CrowPanel 7.0** (24,90 $) | aucun connecteur de broches — Crowtail seulement : 2× I2C, IO38, UART0 | **ne peut pas être le cerveau** |
| **CrowPanel Advance 7.0** | ~10 libres, dont IO2/IO4/IO5/IO6 ; l'écran prend ~20 broches (16 data + DE IO42, HSYNC/VSYNC IO40/41, PCLK IO39) ; I2C sur GPIO15/16 | **candidat crédible** |

Une dizaine de broches suffit au cerveau : I2C (2× MCP23017 + MCP4728), UART vers B et C
plus MIDI, et le ruban tactile.

### Modèle retenu : CrowPanel **Advance 7.0-HMI ESP32 AI Display** — 34,90 $

<https://www.elecrow.com/crowpanel-advance-7-hmi-esp32-ai-display-800x480-ai-ips-touch-screen.html>

**ESP32-S3, 8 Mo PSRAM, 16 Mo flash** = exactement le **N16R8** déjà spécifié pour les trois
puces du projet. Aucun changement de plateforme. 800×480 IPS tactile capacitif (GT911).

⚠️ **Les « 11 broches libres » annoncées sont trompeuses** — « libre » y signifie *sans rôle de
démarrage*, pas *inutilisée* :

| broches | réalité |
|---|---|
| IO7, IO17, IO18, IO21 | **lignes de données de l'écran** → indisponibles |
| IO15, IO16 | **bus I2C**, partagé avec GT911, RTC PCF8563 (0x51), contrôleur rétroéclairage (0x30) |
| **IO2, IO4, IO5, IO6, IO8** | **réellement disponibles** — au prix du haut-parleur I2S, du micro, de la microSD et du buzzer (sans usage ici) |

**Bilan cerveau :**
- **I2C : passe.** Bus partagé, mais aucune collision d'adresse avec MCP23017 (0x20-0x27) ni
  MCP4728 (0x60-0x67).
- **Conflit sur les 5 broches restantes** : le **ruban** demande ~5 canaux tactiles et l'**UART**
  vers B et C en demande 2 à 4. Les deux ne tiennent pas. (IO2/4/5/6/8 sont bien dans la plage
  tactile du S3, donc le ruban serait faisable — mais alors plus rien pour l'UART.)

> 🟢 **2026-08-21 — mise à jour.** Le ruban vit sur le **dos du peigne**, même
> pièce de plexi que les touches, et ses LED sont **sous le bloc** sur la même
> carte horizontale que celles des noires. Il n'y a plus de PCB de tranche partagé.
> Côté canaux tactiles, la décision ci-dessous est inchangée : 5 canaux ne tiennent
> pas sur les broches libres du CrowPanel sans supprimer l'UART.

→ **Décision : le ruban migre sur l'ESP32-B ou C**, ce qui libère les 5 broches pour la liaison
inter-puces. Le repli identifié devient la solution de base.

🔴 **Encombrement de la carte : introuvable.** Ni la fiche produit ni espboards ne le publient.
C'est la cote qui manque pour dessiner la boîte → **mesurer à réception**, ou récupérer le
schéma/manuel chez Elecrow.

Réf. broches : espboards.dev/esp32/elecrow-crowpanel-advance-7-esp32-s3/

🔴 **Point de risque restant : le ruban.** Il demande ~5 canaux tactiles, et seules 4 des broches
libres nommées tombent dans la plage tactile du S3. Surtout, **on a mesuré (2026-08-19) que
« touch-capable » ne veut pas dire « mesure » : sur 14 canaux annoncés d'une carte S3, 4
seulement rendaient des valeurs exploitables** (cf. `docs/ESSAI_ITO_ESP32.md`, `firmware/scan_touch`).
→ Passer `scan_touch` sur la carte réelle avant de figer, et prévoir que le ruban puisse
migrer vers l'ESP32-B ou C.

Refs : espboards.dev/esp32/elecrow-crowpanel-advance-7-esp32-s3/ · elecrow.com/wiki

## 5b. Moteur audio interne — OPTION RÉSERVÉE 🟡 (2026-08-20)

**Décision : place réservée dans le boîtier, réalisation reportée.** Le but initial reste de
piloter des machines externes en MIDI ; le moteur audio ferait de l'instrument un autre objet.

**Matériel visé** (celui du XVA1 de René Ceballos, déjà en possession) :

| | réf | cotes |
|---|---|---|
| FPGA | **Digilent Cmod A7-35T** (Xilinx Artix-7 35T, DIP 48 broches) | 17,78 × 69,85 mm, ~12 mm avec support |
| DAC | **PCM5102A** — *pas* l'UDA1334A du XVA1 | ~40 × 25 × 7 mm |

**Pourquoi le PCM5102A** : il **ne demande pas de MCLK** (il la régénère du BCLK), ce qui évite
de produire et router une horloge à 256×fs côté FPGA. 112 dB de SNR, 32 bits/384 kHz, sortie
**2,1 V RMS** — vrai niveau ligne pour attaquer un étage symétrique. Éviter les modules bon
marché : décalage de niveau incorrect et découplages absents, décrochage au-dessus de 48 kHz.

**Réservation** : volume de **62 × 70 mm, 12 mm de haut** en cavité arrière. En plan la façade
est saturée — la réservation est un volume, pas une surface.

**Sortie audio symétrique, 2 canaux.** Deux conséquences :
- **Étage de sortie** : driver différentiel (DRV134, THAT1646, ou paire d'AOP), ou sortie
  *impedance-balanced* (point froid à la masse via résistance de même valeur) — presque aussi
  efficace contre le mode commun, pour deux résistances.
- 🟢 **DÉCIDÉ 2026-08-21 : jack 3,5 mm.** Le TRS 6,35 mm aurait fait ~14 mm de diamètre et
  **25-30 mm de profondeur**, devenant le composant le plus profond de l'instrument devant le
  CrowPanel (16 mm), et commandant donc l'épaisseur du boîtier. En 3,5 mm (PJ-320A, ~5 mm de
  profondeur), **le CrowPanel redevient le poste dimensionnant**. La sortie reste
  électriquement **symétrique** — seul le format de connecteur change.

**Sur le multitimbral** : sur un moteur multiplexé dans le temps, il coûte de la **mémoire, pas
des multiplieurs** — chaque voix lit les paramètres de sa partie, c'est un index de plus. Les
voix restent **partagées** entre parties. Le poste cher est l'**effet par partie** (d'où les
départs vers effets globaux). Une seule architecture de synthèse, plusieurs patchs : c'est ça
qui reste gratuit.

## 6. Écran — 4,0″ 480×320 SPI 🟡 + ⚠️ impact boîtier
- **Contrôleur** : 🟢 **ILI9488** (choix utilisateur ; 18 bpp, OK en *partial
  refresh*). ST7796 = alternative plus rapide (même PCB) si jamais dispo.
- Cotes : **PCB 61,74 × 108,04 mm**, **actif 55,68 × 83,52 mm**, ép. 1,6 mm,
  verre +3-4 mm, **header 14 broches** sur petit bord, trous M3 aux coins (à mesurer).
- Pilotage : **cerveau, SPI ~6 fils** (SCK MOSI CS DC RST + LED PWM), 3,3 V logique.
  Tactile XPT2046 du module **non câblé**.
- ⚠️ **Impact boîtier** : le **PCB fait 108 × 62 mm** (≫ fenêtre 84 × 56) → il faut
  dégager les contrôles au-delà de ce footprint → **revoir le bandeau haut / élargir
  la façade** (actuellement W=320). Fenêtre plexi ≈ 57 × 85 mm.

## 7. MIDI — voir [`CONNECTEURS_MIDI.md`](CONNECTEURS_MIDI.md) 🟡
- IN : opto **H11L1** (reco, sortie logique 3,3 V) + 220 Ω + 1N4148.
- OUT : buffer **74HC14**, R série 220/220 Ω @5 V (ou 33/10 Ω @3,3 V) 🔴.
- 🟢 **TRS type-A** (Ring=+, Tip=signal, Sleeve=shield).

## 8. CV / Gate / Clock / Reset — sous-système analogique 🟢 0–5 V (nouveau)
- **CV** : **MCP4728** (DAC quad 12-bit I2C, MSOP-10, addr 0x60, **0 GPIO** — sur
  l'I2C existant). 4 CV.
- **Mise à l'échelle 1V/oct, 0–5 V 🟢** : DAC Vref interne ×2 (0–4,096 V) → AOP
  **rail-to-rail 5 V** (MCP6022 / MCP6V07), gain ~1,25 (Rf 2,5 k / Rg 10 k) → 0–5,12 V.
  **Pas de rail +12 V** (alim simplifiée). Vref précision ADR4540 optionnelle (accordage).
- **Gate/Clock/Reset** : 5 V via **74HCT125** (3,3→5 V), Eurorack = gate +5 V.
  **3 GPIO** (proposition : 40/41/42).
- Protection/jack : R série 1 kΩ, clamp **BAT54S**, 100 pF. **LDO 5 V propre**
  (MCP1700-5002) dédié DAC/Vref.

## 9. Connectique 🟡
- **USB-C** : **GT-USB-7010ASV** 16-pin (LCSC C2988369), 8,9 × 7,35 × 3,26 mm.
  **2× CC 5,1 kΩ** (Rd), TVS **USBLC6-2SC6**, polyfuse 0,5-1 A. D+/D- → GPIO19/20.
- **Jacks 3,5 mm** : **PJ-320A** (THT, board-edge, Ø6 panneau, 12 × 5 × 5 mm) pour
  MIDI IN/OUT + CV/GATE/CLK/RST.

## 10. Alimentation 🟡
- Entrée **USB-C 5 V** → **buck 3,3 V 2 A** (AP63203/MP2315) pour 3× ESP32 + logique.
- **74AHCT125** (level-shift LED). Bulk **1000 µF** sur 5 V LED, découplage.
- Budget LED : 27× SK6812 ≈ 1,6 A crête → **plafonner luminosité** (USB-C 15 W).
- CV en **0–5 V** → pas de rail +12 V. **LDO 5 V propre** dédié DAC/Vref (anti-bruit).

## 11. Mécanique 🟢 (profondeur recalée)
- Empilement (haut→bas) : plexi **2 mm** · **entrefer avant 7 mm** (dégage le corps
  EC11 ~6,5 + PB86 + module écran) · PCB **1,6 mm** · **cavité 12 mm** (3× ESP32 ~3 +
  connecteurs) · fond **2,5 mm**. → **profondeur totale ≈ 25 mm.**
- ⚠️ **2 PCB** : sous-couche **électrodes capacitives** près du plexi (touches + ruban,
  gap ~2-3 mm pour la sensibilité) **+ PCB principal** en bas (encodeurs, électronique,
  connecteurs). L'entrefer 7 mm = dégagement du corps des encodeurs entre les deux.
- Jacks **PJ-320A board-edge** (~5 mm) + USB-C sur la **tranche arrière**, au niveau du
  PCB principal. Boîtier parois **2,5 mm**.

## 12. Budget IO / répartition 3 puces 🟡
**Tactile = 32 canaux (27 touches + ruban ~5) → les 3 puces en font** :

| Ressource | A (cerveau) | B | C |
|---|---|---|---|
| Touch (canaux) | **5** (ruban) | **14** (touches) | **13** (touches) |
| Écran SPI (6) · MIDI (2) · USB (2) · LED SK6812 (1, RMT) · I2C master (2) | ✓ | | |
| Gate / Clock / Reset (3 GPIO) | ✓ | | |
| Encodeurs A/B (PCNT) | | 3 enc | 2 enc |
| Comms inter-puces | maître | ✓ | ✓ |

- **I2C (cerveau)** : 2× **MCP23017** (0x20/0x21) + **MCP4728** (0x60). Les MCP23017
  portent **8 switches PB86 (direct) + 10 lignes LED (2 bi + 6 mono) + 5 push encodeurs**
  = **23 / 32 IO** (marge confortable). CV (DAC) = 0 GPIO.
- **PCNT** = 4 unités/puce → 5 encodeurs répartis B(3)/C(2). **1 cran = 1 cycle
  quadrature** (générique 20/20 ou Bourns 24/24) pour 1 clic = 1 pas.
- 🟢 **Lien inter-puces = UART dédié** (latence basse pour le jeu des touches).
- Cerveau : ribbon (5) + gate/clk/rst (3) sur GPIO 1-14 ; écran/MIDI/LED/I2C sur
  GPIO >14 (12 dispo) ; USB 19/20. **Tient, mais serré** → pinout exact à valider au schéma.

## Décisions (récap)
- ✅ Écran = **ILI9488 4,0″ 480×320 SPI**.
- ✅ **CV 0–5 V** (pas de rail +12 V).
- ✅ MIDI = **TRS type-A**.
- ✅ Encodeurs = **1 cran = 1 cycle quadrature** (20/20 ou 24/24).
- ✅ Lien inter-puces = **UART dédié** (latence basse).
- ✅ Boutons : **PLAY/REC = PB86-A2 bi-couleur**, 6 autres = **A1 mono** ; switches en
  direct sur 2× MCP23017 → **aucune diode**.
- 🟡 **LED touches (SK6812 3535 vs MINI-E)** + dessin de cellule → **étude diffusion**
  en cours (voir [`ETUDE_DIFFUSION_LED.md`](ETUDE_DIFFUSION_LED.md)).
- 🟡 Driver MIDI OUT 5 V vs 3,3 V (mineur).

## Implications boîtier
- ✅ **Écran PCB 108 × 62 mm** intégré au modèle (fenêtre active 84×56, contrôles
  reculés à droite du PCB ; enc pitch 33 / boutons 20 → tient en W=320).
- Profondeur cavité à recaler sur encodeurs (~32 mm) + jacks PJ-320A board-edge.
