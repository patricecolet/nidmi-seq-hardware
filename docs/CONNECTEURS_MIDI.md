# Connecteurs + front-end MIDI — NiDMI Seq

> Réfs exactes, dimensions en mm, valeurs de circuit. Sources : USB-IF Type-C r2.x,
> MIDI 1.0 (DIN spec), MMA/AMEI **MIDI on 3.5mm TRS — Type A** (RP-054), datasheets
> constructeurs. Tension logique cible : **3,3 V** (ESP32-S3). Variante MIDI 3,3 V
> documentée pour le **OUT**.

---

## 1. USB-C — alim 5 V + USB2 data (USB-MIDI) + flash ESP32-S3

### Réf. figée
| Rôle | Réf. | Distrib. | Notes |
|---|---|---|---|
| **Réceptacle USB-C 16P** | **GT-USB-7010ASV** | LCSC C2988369 | 16 broches, **2 rangées SMD + 4 ergots THT** (mid-mount/board-edge), full-feature mais on n'utilise que USB2. |
| Équiv. | TYPE-C-31-M-12 (LCSC C165948, 16P) ; Korean Hroparts U262-161N-4BVC11 (C319148) | — | Mêmes empreintes courantes 16P. |

On prend le **16P** (et non le 6P/power-only) car il porte D+/D-/CC ⇒ flash + USB-MIDI
natif par le même connecteur.

### Dimensions (GT-USB-7010ASV, typ.)
- Corps : **L ≈ 8,9 (insertion) × l ≈ 7,35 × H ≈ 3,26 mm** (hauteur hors-tout ~3,3 mm).
- Empreinte : pas signal **0,5 mm** (2× rangées de 6 pads SMD) ; **4 trous d'ancrage** THT
  (broches de blindage/shell) Ø ≈ 1,1 mm pour la tenue mécanique.
- Largeur d'ouverture façade requise : **~9,0 × 3,5 mm** (slot connecteur).

### Câblage (USB2, USB-MIDI device + flash)
| Broche C | Signal | Vers |
|---|---|---|
| A4/B4, A9/B9 | VBUS | +5 V (relié) |
| A1/B1, A12/B12 | GND | masse (relié) |
| A6/A7 (ou B6/B7) | D+ / D- | ESP32-S3 GPIO19 (D-) / GPIO20 (D+) natifs |
| A5 | CC1 | R 5,1 kΩ → GND |
| B5 | CC2 | R 5,1 kΩ → GND |

- **CC1 et CC2 : 1 résistance 5,1 kΩ ±5 % chacune vers GND** (Rd, signale un *device/UFP*
  qui consomme du courant). **2 résistances** distinctes obligatoires (jamais une seule
  partagée — sinon non détection à l'insertion retournée). Boîtier 0402/0603.
- **Pas de résistance Rp** côté device.
- D+/D- vont **directement** aux GPIO USB natifs du S3 (pas de pont/PHY externe). Le bridge
  USB-série pour flasher est dans le S3 (ROM) → flash + USB-MIDI sur le même port.

### Protection (device alim + data)
| Fonction | Réf. | Valeur / boîtier | Placement |
|---|---|---|---|
| **TVS ESD data** D+/D- | **USBLC6-2SC6** (SOT-23-6) | clamp ~ ±15 kV (air), Cj ~ 3 pF | au plus près du connecteur, sur D+/D- |
| Équiv. | PRTR5V0U2X, TPD2E009 | — | — |
| **TVS VBUS** | SMAJ5.0A (ou SMF5.0A SOD-123) | clamp 5 V uni | sur VBUS → GND |
| **Fusible VBUS** | PTC/polyfuse 500 mA–1 A (0805) | — | série sur VBUS |
| Découplage VBUS | 10 µF + 100 nF | — | après fusible |

> Budget courant à surveiller (cf. ARCHITECTURE §pads) : SK6812 ×16 ≈ 0,8 A crête +
> TFT + logique. Si > ~0,9 A sous 5 V, **prévoir alim externe** (le port USB hôte/PC
> ne garantit que ~0,5–0,9 A en non-PD) → dimensionner polyfuse en conséquence.

---

## 2. Jacks 3,5 mm TRS — MIDI (TRS type A) + CV/Gate

### Réfs figées
| Rôle | Réf. | Type | Distrib. |
|---|---|---|---|
| **MIDI IN / OUT (TRS-A)** | **PJ-320A** | 3,5 mm TRS, **THT, switché (T + R commutés)** | CUI / clones LCSC C2884952 |
| **CV / Gate (sortie analogique)** | **PJ-325** (ou PJ-320A) | 3,5 mm TRS THT switché | LCSC |
| Variante non-switchée | PJ-313 / PJ-3110 | TRS sans contact de détection | — |

Reco : **PJ-320A partout** (uniformité, le plus répandu, contacts de détection dispo si
besoin de re-router selon insertion). Switché = utile sur CV pour normaliser (détecter
fiche présente) ; pour MIDI les contacts switch restent NC.

### Dimensions (PJ-320A, typ.)
- Corps : **L ≈ 12,0 × l ≈ 5,0 × H ≈ 5,0 mm** (fût + embase).
- Entr'axe broches : pas **2,0 mm** ; **5 pattes THT** (Tip, Ring, Sleeve + 2 contacts
  switch T'/R').
- Trou de passage fiche / perçage façade : **Ø 6,0 mm** (fût fileté absent sur PJ-320A →
  **montage sur PCB en bord de carte**, pas d'écrou ; aligner le fût sur l'ouverture façade).
- Si montage panel à écrou souhaité : passer en **PJ-325** (variante à embase) ou jack
  vissable type Lumberg/Neutrik (plus cher, hors budget).

### Montage
- **Bord de PCB (board-edge), horizontal**, fût débordant dans une ouverture Ø6 de la
  façade — pas de fixation mécanique propre (le PCB tient le jack). Cohérent avec la
  façade OpenSCAD (`mechanical/facade.scad`) : prévoir lumières Ø6 alignées au pas des jacks.

---

## 3. Front-end MIDI

### Câblage TRS type-A vs DIN5 (rappel norme RP-054)
MIDI = boucle de courant ~5 mA. Correspondance **DIN5 → TRS-A** :

| Signal | DIN-5 | TRS type-A |
|---|---|---|
| Source courant (+, via 220 Ω) | broche 4 | **Ring (R)** |
| Sink / cathode (–, retour) | broche 5 | **Tip (T)** |
| Shield / masse | broche 2 | **Sleeve (S)** |
| (broches 1,3 = NC) | 1,3 | — |

> **Type-A** (standard MMA, adopté Korg/Make Noise/etc.) : R = +, T = signal. **Type-B**
> (ancien Arturia/Novation) inverse T/R → **ne PAS mélanger**. On fige **Type-A**.
> Côté **IN**, c'est l'émetteur distant qui fournit le courant : T/R définissent juste
> dans quel sens le courant traverse l'optocoupleur.

### Optocoupleur MIDI IN — **H11L1** (figé) vs 6N138

| Critère | **H11L1 (reco)** | 6N138 |
|---|---|---|
| Type | Photo-darlington **+ trigger Schmitt + sortie logique** | Photo-darlington analogique |
| Sortie | **Logique propre**, pas de buffer externe | Collecteur ouvert lent → besoin pull-up + souvent étage |
| Vitesse | **t ~ qq 100 ns**, marge confortable à 31250 baud | Plus lent, distorsion de flanc possible (notes coincées en MIDI dense) |
| Câblage | Minimal | Plus de composants |
| Boîtier | DIP-6 (THT) | DIP-8 |
| Alim sortie | 5 V (ou 3,3 V — voir note) | 5 V |

→ **H11L1** : moins de composants, flancs nets, recommandé pour DIN-MIDI standard.
(Le 6N138 reste acceptable mais demande pull-up + attention aux flancs.)

### Schéma MIDI IN (H11L1, entrée optocouplée)
Côté **boucle (isolé, relié au câble)** :
```
TRS-A Ring (+) ──► R1 220 Ω ──► H11L1 anode (pin 1)
TRS-A Tip  (–) ──► D1 (1N4148) // LED interne ──► H11L1 cathode (pin 2)
                   (D1 en anti-parallèle = protection inversion)
TRS-A Sleeve ──── NON connecté côté isolé (masse châssis seulement)
```
Côté **logique (3,3 V ou 5 V)** :
```
H11L1 Vcc (pin 6) ── Vlog
H11L1 GND (pin 4) ── GND
H11L1 OUT (pin 5) ── Rpull-up 270 Ω…1 kΩ vers Vlog ──► UART RX (GPIO18)
                     (H11L1 a sa sortie logique ; pull-up léger 270 Ω–1 k recommandé)
```
**Valeurs IN :**
| Comp. | Valeur | Rôle |
|---|---|---|
| R1 (série LED opto) | **220 Ω** | limite courant boucle (avec les 220 Ω côté OUT distant) |
| D1 | **1N4148** anti-parallèle sur LED opto | protège LED en inversion de polarité |
| Rpull-up sortie | **270 Ω – 1 kΩ** vers Vlog | tire la sortie ; 270 Ω = flancs plus nets |
| Vlog | **3,3 V** (alim H11L1 en 3,3 V → sort en 3,3 V, attaque direct le S3) | évite level-shift |

> H11L1 spec'd jusqu'à Vcc 3 V min → **fonctionne en 3,3 V**, sortie compatible GPIO S3
> directement. En 5 V, ajouter un diviseur ou level-shifter sur RX.

### Schéma MIDI OUT (driver de ligne)
Buffer **74HC14** (Schmitt inverseur hex) — 2 inverseurs en série (signal non inversé) ou
1 + ajustement firmware. Alternative : transistor NPN, mais le 74HC14 raidit les flancs.

```
UART TX (GPIO17) ──► 74HC14 inv ──► 74HC14 inv ──► R_hot ──► TRS-A Ring (source +)
GND (logique) ──────────────────────► R_cold ──► TRS-A Tip  (sink –)
TRS-A Sleeve ── masse/shield
```
**Valeurs OUT selon tension de ligne :**
| Variante alim driver | R_hot (sur la sortie active) | R_cold (sur la patte fixe) | Total boucle |
|---|---|---|---|
| **MIDI 5 V classique** | **220 Ω** | **220 Ω** | ~5 mA, conforme DIN |
| **MIDI 3,3 V** | **33 Ω** | **10 Ω** (ou 33 Ω / 33 Ω simplifié) | compense la tension plus basse pour garder ~5 mA dans la LED réceptrice |

> Si le 74HC14 est alimenté en **3,3 V**, utiliser les résistances **33 Ω / 10 Ω**
> (recommandation MIDI-3V3 répandue) pour conserver le courant de boucle. Si on dispose
> d'un 5 V propre, alimenter le buffer en 5 V et garder **220 Ω / 220 Ω** (le plus sûr,
> interopérable avec tout matériel MIDI).

**Reco figée** : buffer **74HC14 alimenté en 5 V + 220 Ω / 220 Ω** (interop maximale).
Repli sans 5 V propre : 74HC14 en 3,3 V + 33 Ω / 10 Ω.

---

## Récap BOM front-end (à intégrer à la BOM globale)
| Réf. | Qté | Valeur / part |
|---|---|---|
| USB-C 16P | 1 | GT-USB-7010ASV (C2988369) |
| R CC1, CC2 | 2 | 5,1 kΩ 0402 |
| TVS data | 1 | USBLC6-2SC6 |
| TVS VBUS | 1 | SMAJ5.0A |
| Polyfuse VBUS | 1 | 500 mA–1 A |
| Jack 3,5 TRS | 2–n | PJ-320A (MIDI IN+OUT) + CV/Gate selon besoin |
| Opto MIDI IN | 1 | **H11L1** (DIP-6) |
| R série boucle IN | 1 | 220 Ω |
| D protection IN | 1 | 1N4148 |
| R pull-up sortie opto | 1 | 270 Ω–1 kΩ |
| Buffer MIDI OUT | 1 | 74HC14 (1 boîtier, 2 inv. utilisés) |
| R OUT (5 V) | 2 | 220 Ω / 220 Ω  *(ou 33 Ω/10 Ω en 3,3 V)* |

## À FIGER
- [ ] Alim driver MIDI OUT : **5 V (220/220 Ω)** vs **3,3 V (33/10 Ω)** → dépend de la
      dispo d'un rail 5 V propre côté carte.
- [ ] Connecteurs MIDI : **TRS-A** (figé ici) — confirmer qu'aucun DIN-5 n'est requis.
- [ ] Nombre de jacks CV/Gate (PJ-320A) selon le périmètre CV final.
- [ ] Marge courant 5 V (USB hôte ~0,5–0,9 A) vs SK6812+TFT → alim externe ?
