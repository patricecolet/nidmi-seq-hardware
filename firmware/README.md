# firmware — bancs de test

Croquis Arduino de mesure, pas de code produit. Compilés avec `arduino-cli`
(core `esp32:esp32` 3.3.1, IDF 5.5).

## `test_touch_ito/` — sensibilité capacitive d'une électrode ITO

Lit N canaux *touch*, calibre une ligne de base + son bruit au démarrage, puis
sort en continu du CSV `t_ms,ch,raw,delta,snr` sur le port série à 115200.
`delta` est normalisé **positif au toucher** sur les deux générations de touch
(v1 ESP32 : la valeur descend ; v2 S2/S3 : elle monte).

Broches par défaut (à ajuster en tête du `.ino`) :

| Cible | Canaux | GPIO |
|---|---|---|
| ESP32-S3 (touch v2) | TOUCH4–7 | 4, 5, 6, 7 |
| ESP32 classique (v1) | T0, T4, T6, T7 | 4, 13, 14, 27 |

Sur S3 tout GPIO1–14 est touch-capable ; on évite 0 / 45 / 46 (strapping).

### Compiler et téléverser

```sh
cd firmware/test_touch_ito

# ESP32-S3-WROOM-1 N16R8, via le port USB-UART de la carte
arduino-cli compile -b esp32:esp32:esp32s3:PSRAM=opi,FlashSize=16M .
arduino-cli upload  -b esp32:esp32:esp32s3:PSRAM=opi,FlashSize=16M -p /dev/cu.usbXXXX .

# variante : port USB natif du S3 (série sur l'USB de la puce)
arduino-cli compile -b esp32:esp32:esp32s3:PSRAM=opi,FlashSize=16M,CDCOnBoot=cdc .

# ESP32 classique
arduino-cli compile -b esp32:esp32:esp32 .
```

Trouver le port : `ls /dev/cu.usb*` (ou `arduino-cli board list`).

### Lire les mesures

```sh
arduino-cli monitor -p /dev/cu.usbXXXX -c baudrate=115200   # brut
scripts/touch_log.py --secs 10 --out mesures/ito_25mm_plexi15.csv \
                     --label "ITO 25x25 / membrane 1,5 mm"   # + résumé stats
```

Commandes série : `b` = refaire la ligne de base (main éloignée), `h` = aide.

### Observer en direct pendant un test

```sh
scripts/touch_scope.py --port /dev/cu.usbmodemXXXX   # puis http://localhost:8765
```

Sert une page locale qui se rafraîchit toute seule : **histogramme** des valeurs
brutes (vue principale), chronogramme, stats par canal, et un bouton qui envoie
la recalibration à la carte.

L'histogramme est la bonne vue ici, et pas la moyenne : un contact intermittent
apparaît comme **plusieurs pics séparés** — broche nue / électrode au repos /
doigt posé — là où une moyenne afficherait une valeur intermédiaire qui ne
correspond à aucun état réel. C'est ce qui a permis de voir que l'électrode
décrochait, et pas seulement qu'elle était « bruitée ».

**Le scope redémarre la carte en s'y connectant**, et c'est nécessaire : sur l'USB
natif du S3, une carte déjà en marche dont l'hôte précédent s'est déconnecté
**n'émet plus rien** pour le suivant. Le reset garantit aussi une entête (donc la
correspondance canal→GPIO) et une ligne de base fraîches. Compter ~10 s de
préchauffage et de calibration, main éloignée. `--no-reset` pour s'attacher sans
perturber une mesure en cours — mais la carte peut alors rester muette.

> Un seul programme à la fois peut ouvrir le port série : arrêter `touch_log.py`
> avant de lancer `touch_scope.py`, et inversement. Le scope reprend tout seul
> si la carte est débranchée puis rebranchée.

> Commandes série du croquis : `b` = recalibrer · `i` = réimprimer l'entête
> canal→GPIO (sans toucher à la ligne de base) · `h` = aide.

Protocole d'essai complet : [`docs/ESSAI_ITO_ESP32.md`](../docs/ESSAI_ITO_ESP32.md).

## `banc_cellules/` — cellule complète : 4 touches + 4 LED appairées

Le banc à utiliser pour tester une implantation réelle. Reprend la mesure tactile
de `test_touch_ito` (même format CSV, donc `touch_scope.py` et `touch_log.py`
fonctionnent tels quels) et y ajoute 4 LED, **une par canal**.

| | broches |
|---|---|
| électrodes | GPIO **8, 9, 10, 12** |
| LED | GPIO **15, 16, 17, 18** → `100 Ω` → anode ; cathodes au GND commun |

**Modes LED** (boutons dans le client, ou touche série) : `t` tactile — la LED *n*
s'allume quand la touche *n* est touchée · `r` rampe 5 s · `c` clignotement ·
`f` fixe · `x` éteint. Luminosité au curseur (ou `L0`…`L255` en série).

Détection : seuil = `max(8σ, 150 counts)` au-dessus de la ligne de base, avec
**hystérésis à 60 %** pour éviter le battement quand le doigt effleure la limite.
Les seuils calculés sont affichés à la calibration, et chaque passage touché ⇄
relâché est annoncé sur le port série.

> **Les oranges, rouges et vertes traditionnelles (seuil ~2 V) se pilotent
> directement depuis un GPIO** en 3,3 V : (3,3 − 2,0)/100 = ~13 mA. Une **bleue**
> ou une **blanche** (seuil ~3 V) n'y arriverait pas — ~2 mA, invisible. Pour
> celles-là, rail 5 V et montage où le GPIO tire le courant (logique inversée).

## `scan_touch/` — quelles broches touch sont réellement utilisables

À passer **avant** de figer un brochage, et à chaque recâblage. Fait deux choses :

1. **Intégrité électrique** de GPIO1–14 (`INPUT_PULLUP` puis `INPUT_PULLDOWN`) :
   `pu=1 pd=0` = broche libre · `pu=1 pd=1` = tirée au 3V3 · `pu=0 pd=0` = à la
   masse. Une broche tirée d'un côté ou de l'autre **ne peut pas mesurer** : le
   pad ne se charge plus et le canal part en timeout.
2. **Balayage touch** des 14 canaux. Un canal qui rend `4194303` (0x3FFFFF) ne
   mesure pas — ce n'est pas une capacité énorme, c'est une mesure qui n'aboutit
   pas. Compter ~2 s par canal en échec.

**GPIO4 et GPIO5 sont le bus I2C de la carte** (SDA/SCL), avec leurs pull-ups de
10 kΩ montées d'origine — mesuré 9 kΩ vers 3V3, carte hors platine, contre 500 kΩ
sur GPIO6. Elles ne peuvent pas servir au tactile, et le BOM les réserve déjà à
l'I2C (MCP23017, MCP4728).

Mesuré sur la carte ESP32-S3-WROOM-1 N16R8 du proto : seules **GPIO8, 9, 10, 12**
donnent des valeurs exploitables (~30 000 counts, bruit σ = 8 à 104). Les autres
saturent, y compris des broches électriquement libres. Ne pas supposer qu'une
broche marche parce que la doc la dit touch-capable.

> Le message `touch_sensor_trigger_oneshot_scanning: Wait for measurement done
> timeout` du core 3.3.1 apparaît sur **tous** les canaux, y compris ceux qui
> rendent ensuite des valeurs valides. Ce n'est pas un critère d'échec.
