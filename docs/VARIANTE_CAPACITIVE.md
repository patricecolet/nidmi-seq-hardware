# Variante en étude — boîtier plexi + touches capacitives + 3× ESP32-S3

> **Statut : ÉTUDE** (branche `etude/plexi-capacitif`). Ne remplace pas encore
> l'archi de référence ([`ARCHITECTURE.md`](ARCHITECTURE.md), MCP23017 + PB86).
> Objectif : valider la faisabilité avant de figer quoi que ce soit.

## Idée directrice

Façade **plexiglas scellée** : les touches sont des **pastilles capacitives en
cuivre** sous l'overlay acrylique (le plexi est un bon diélectrique → le doigt est
détecté à travers). Plus de boutons mécaniques, plus de galette silicone, plus de
MCP23017. LEDs **SK6812** diffusées sous le plexi → rendu groovebox premium, boîtier
étanche, zéro usure mécanique.

Contrepartie assumée : **pas de retour tactile** (plus de clic) et **lien inter-MCU
dont la latence compte** pour le timing musical.

## Pourquoi 3× ESP32-S3-WROOM-1-N16R8

Le périphérique *touch* matériel de l'ESP32-S3 est **limité à 14 canaux** (T1→T14
sur GPIO 1→14). Touches à lire en capacitif :

| Bloc | Canaux |
|------|--------|
| 16 blanches (pas) + 11 noires | 27 |
| Shift | 1 |
| 5 transport | 5 |
| **Total capacitif** | **33** |

`⌈33 / 14⌉ = 3` → il faut **3 puces**. Les 3 sont des **N16R8 identiques** (même
prix que le N8R2 → pas de raison de prendre moins ; SKU unique, puces
interchangeables, marge flash/PSRAM partout). **Commande : 3× N16R8 ≈ 17 €.**

## Répartition proposée des rôles

```
        ┌──────────────── MAÎTRE (N16R8 #1) ────────────────┐
        │ moteur séquenceur · TFT (SPI) · MIDI · USB         │
        │ pilote le bus SK6812 (RMT, 1 GPIO)                 │
        │ lit quelques canaux touch (voir « point dur »)     │
        └───┬───────────────────────────┬───────────────────┘
            │ I2C (2 fils) + INT          │
   ┌────────┴────────┐          ┌─────────┴────────┐
   │ ESCLAVE A (#2)  │          │ ESCLAVE B (#3)   │
   │ 14 canaux touch │          │ 14 canaux touch  │
   │ + INT vers maître│         │ + encodeurs PCNT │
   └─────────────────┘          └──────────────────┘
```

### ⚠️ Point dur n°1 — allocation des 33 canaux sur 3 puces
2 esclaves « touch pur » = **28 canaux < 33**. Trois résolutions possibles :
- **(a)** le maître lit ~5 canaux lui-même (ex. les 5 transport) sur ses GPIO 1-14
  libres — le *touch* est échantillonné en hardware, surcoût CPU négligeable. **Reco.**
- **(b)** garder transport/Shift en boutons mécaniques discrets (tactile conservé sur
  les fonctions critiques Play/Stop/Rec) → 27 capacitifs = 2 esclaves pile.
- **(c)** contrôleur capacitif I2C externe pour le surplus (ajoute une réf BOM).

À trancher tôt : conditionne le brochage du maître.

### Point dur n°2 — lien inter-MCU
- **I2C** (2 fils, esclaves adressés, ligne INT pour réveiller le maître sur
  changement) → simple, peu de GPIO. **Reco** pour démarrer.
- **UART dédié par esclave** → plus de fils, latence basse déterministe.
- **ESP-NOW** (sans fil) → séduisant mais jitter de quelques ms : **à éviter** pour
  des touches musicales.

## LED RGB — pilotage (sujet explicite)

- **Type** : SK6812 RGB adressable, **1 seul bus 1-fil** chaîné (≥ 27 LED, 1 par
  touche/pas ; exigé par cahier §10.5 : couleur par couche/pas actif/sub).
- **Qui pilote** : le **maître**, sur **1 GPIO** via le périphérique **RMT**
  (timing protocole WS2812/SK6812 généré en hardware, pas de jitter logiciel).
  Les esclaves touch ne touchent pas aux LED.
- **Niveau logique — point à ne pas rater** : SK6812 alimentée en **5 V** veut un
  niveau data haut ≈ 0,7×VDD ≈ **3,5 V**. L'ESP32-S3 sort **3,3 V** → marginal/
  non fiable. **Solution : level-shifter 3,3→5 V** (74AHCT125 ou 74AHCT1G125 sur la
  ligne data). Alternative : alimenter les LED en 3,3 V (luminosité réduite) si réf
  tolérante. **À FIGER.**
- **Budget courant** : SK6812 ≈ 50-60 mA à blanc plein. 27 LED ≈ **1,6 A** crête,
  43 LED ≈ **2,6 A**. En usage réel jamais tout blanc → dimensionner le rail 5 V
  large (≈ 2-3 A) **et plafonner la luminosité firmware**. USB-C 5 V/3 A (15 W) = OK
  si brightness cappée.
- **Bonnes pratiques data/alim** : condo bulk ~1000 µF sur l'alim LED, **résistance
  série 300-500 Ω** sur la data, découplage 0,1 µF par LED (intégré en CMS).
- **Sous plexi** : diffusion via overlay translucide ou guides de lumière → vérifier
  rendu (uniformité, bleeding entre cellules) sur échantillon.

## Écran TFT (sujet explicite)

- **FIGÉ** : **TFT 320×240 couleur, 3,2″, SPI, non tactile** (cf. [`ARCHITECTURE.md`]
  (ARCHITECTURE.md) → Écran ; source cahier VST §10.1 rév. 2026-05). Module ~56×78 mm,
  zone active ~49×65 mm.
- **Qui pilote** : le **maître**, en **SPI** (contrôleur FSPI), sur GPIO non-touch
  (>14) pour laisser GPIO 1-14 au capacitif.
- **Broches** : SCK, MOSI, CS, DC, RST, BL (~6) ; MISO en option (souvent inutile).
- **Contrôleur** : ILI9341 vs ST7789 — à préciser (dispo, lib, vitesse).
- **Alim** : logique 3,3 V ; **rétroéclairage (BL)** parfois 5 V → piloter en **PWM
  via transistor** (gradation + on/off, économie veille).
- **Intégration plexi** : fenêtre de visualisation dédiée (pas de capacitif par-dessus
  l'écran a priori).

## Budget GPIO maître — esquisse (à affiner après point dur n°1)

Pins non-*touch* exploitables sur N16R8 (hors 1-14 *touch*, hors 26-37 réservés
flash/PSRAM, hors strap 0/3/45/46, hors USB 19/20, hors UART0 43/44) :
**15,16,17,18,21,38,39,40,41,42,47,48 ≈ 12 pins.**

| Fonction maître | Pins | Nb |
|-----------------|------|----|
| TFT SPI | SCK,MOSI,CS,DC,RST,BL | 6 |
| MIDI UART (+opto IN, driver OUT) | TX,RX | 2 |
| SK6812 data (RMT) | 1 ligne | 1 |
| I2C vers esclaves (+INT) | SDA,SCL,INT | 2-3 |
| **Sous-total non-touch** | | **~11/12** |
| Touch maître (option a) | sur GPIO 1-14 | ~5 |
| USB-MIDI | D-/D+ (19,20 natifs) | (2) |

→ **Encodeurs (4× quadrature = 8 GPIO PCNT) déportés sur un esclave**, le maître
n'a plus la place. Push-encodeurs (4) → GPIO esclave ou canaux *touch*.

## À FIGER pour cette variante
- [ ] Allocation 33 canaux *touch* sur 3 puces (option a/b/c du point dur n°1).
- [ ] Lien inter-MCU (I2C reco vs UART) + protocole d'événements + ligne INT.
- [ ] Level-shifter data SK6812 (74AHCT125 ?) + tension LED (5 V vs 3,3 V).
- [ ] Dimensionnement alim 5 V (courant LED) + plafond luminosité firmware.
- [ ] Contrôleur TFT (ST7789/ILI9341) + brochage SPI sur pins >14 (diagonale 3,2″ figée).
- [ ] Géométrie pastilles capacitives + épaisseur/matière overlay plexi (test réel).
- [ ] Encodeurs : quel esclave porte la quadrature PCNT ; sort des push.
- [ ] Diffusion LED sous plexi (uniformité, séparation entre cellules).

## Questions ouvertes / risques
- Latence touch→maître→son acceptable pour le geste ? (mesurer sur proto I2C).
- Tuning capacitif à travers plexi (épaisseur, garde, hatch de masse) — guide
  Espressif « Touch Sensor Application Note » à suivre.
- Perte du clic : valider l'ergonomie sur un pavé d'essai avant d'engager la façade.
