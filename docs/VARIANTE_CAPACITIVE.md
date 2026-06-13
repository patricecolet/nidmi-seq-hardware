# Concept — boîtier plexi + touches capacitives + 3× ESP32-S3

> **Design actif** (branche `etude/plexi-capacitif`). Ce doc = **concept &
> rationale**. Les **specs figées** (réfs, cotes, implémentation) sont dans
> [`BOM.md`](BOM.md) ; le **modèle 3D coté** dans [`../mechanical/`](../mechanical/) ;
> l'**ergonomie** dans `nidmi-seq-vst/VISION_ERGO_HARMONIE.md` (source de vérité).
> L'ancienne archi MCP23017/PB86-touches est dans [`ARCHITECTURE.md`](ARCHITECTURE.md)
> (**legacy**, divergente).

## Idée directrice

Façade **plexiglas** : les **27 touches piano** et le **ruban** sont des **électrodes
capacitives** sous l'overlay acrylique (le doigt est détecté à travers le plexi).
LEDs **SK6812** diffusées sous le plexi → rendu groovebox, peu d'usure mécanique.
Le geste continu du ruban complète une machine sinon entièrement quantifiée.

## Capacitif vs mécanique (qui est quoi)

| Bloc | Techno |
|------|--------|
| **27 touches piano** (16 blanches + 11 noires) | **capacitif** (électrodes PCB) |
| **Ruban** assignable | **capacitif** (slider tactile natif, ~5 canaux) |
| **5 encodeurs** (push) | **mécaniques** (EC11, traversent le plexi) |
| **8 boutons fonction** | **mécaniques** illuminés (PB86, traversent le plexi) |

→ Capacitif = **27 + ~5 = ~32 canaux**. Les boutons/encodeurs sont mécaniques
(clic conservé sur transport ; pas de diode car switches en direct sur MCP23017).

## Pourquoi 3× ESP32-S3-WROOM-1-N16R8

Le périphérique *touch* de l'ESP32-S3 = **14 canaux max** (T1→T14). 32 canaux
capacitifs ⇒ `⌈32/14⌉ = 3` puces. 3× N16R8 identiques (SKU unique, ~17 €).
Répartition : A (cerveau) = ruban + écran/MIDI/LED/USB/I2C ; B/C = touches + encodeurs.
**Lien inter-puces = UART** (latence basse). Détail → [`BOM.md`](BOM.md) §12.

## LED RGB (rappel)
- **SK6812** RGB, **1 bus 1-fil** (RMT, piloté par le cerveau), 1 par touche.
- **Level-shifter 74AHCT125** (data 3,3→5 V) indispensable. Budget courant + cellule
  (3535 vs MINI-E, diffusion) → [`BOM.md`](BOM.md) §2 + [`ETUDE_DIFFUSION_LED.md`](ETUDE_DIFFUSION_LED.md).

## Contraintes/risques propres au capacitif sous plexi
- **Sensibilité ↔ entrefer** : le capacitif veut l'électrode près du plexi (~2-3 mm),
  mais les encodeurs imposent un entrefer avant de ~7 mm → **2 PCB** (sous-couche
  électrodes près du plexi + PCB principal en bas). Voir [`BOM.md`](BOM.md) §11.
- **Tuning à travers plexi** : pads larges, anneau de garde, hachure de masse, overlay
  fin (suivre la *Touch Sensor Application Note* Espressif).
- **Latence touch→son** : à mesurer sur proto (lien UART).
- **Pas de clic** sur les touches (assumé ; clic conservé sur les PB86).

## Seul chantier ouvert
- **Étude diffusion/diffraction LED** ([`ETUDE_DIFFUSION_LED.md`](ETUDE_DIFFUSION_LED.md))
  → fige la cellule touche+LED (SK6812 3535/MINI-E, finition plexi, géométrie électrode,
  détail des 2 PCB). Le reste de la BOM est figé.
