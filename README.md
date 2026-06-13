# NiDMI Seq — Hardware

Cible matérielle du séquenceur **NiDMI Seq**. Design actif (branche
`etude/plexi-capacitif`) : **boîtier plexi + clavier piano capacitif 27 touches +
ruban**, **5 encodeurs**, **8 boutons PB86**, **écran 4,0″ 480×320**, LEDs SK6812,
MIDI (TRS), **CV/Gate**, sur **3× ESP32-S3-WROOM-1-N16R8**.

Le firmware embarquera le moteur `nidmi-sequencer-core` ; ce dépôt ne contient
que l'électronique (schéma, PCB, BOM, fabrication).

## Famille de dépôts

```
repo/
  nidmi-sequencer-core/   ← moteur séquenceur (DSP/logique)
  nidmi-seq-vst/          ← prototype VST/AU/Standalone (présentation + host)
  nidmi-seq-hardware/     ← CE DÉPÔT : carte ESP32-S3
```

## Arborescence

```
kicad/      projet KiCad (.kicad_pro / .kicad_sch / .kicad_pcb)
lib/        symboles & empreintes custom (.kicad_sym / .pretty)
scripts/    automatisation pcbnew (placement de grilles, génération)
docs/       architecture, choix de conception, BOM
```

## Docs (design actif)

- [`docs/VARIANTE_CAPACITIVE.md`](docs/VARIANTE_CAPACITIVE.md) — concept & rationale.
- [`docs/BOM.md`](docs/BOM.md) — **BOM figée** (réfs, cotes, implémentation) = source de vérité composants.
- [`docs/CONNECTEURS_MIDI.md`](docs/CONNECTEURS_MIDI.md) — connecteurs + front-end MIDI.
- [`docs/ETUDE_DIFFUSION_LED.md`](docs/ETUDE_DIFFUSION_LED.md) — étude lumière (chantier ouvert).
- [`mechanical/`](mechanical/) — modèle 3D paramétrique coté (OpenSCAD).
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — *legacy* (ancienne archi MCP23017/PB86-touches).
- Ergonomie (source de vérité) : `nidmi-seq-vst/VISION_ERGO_HARMONIE.md`.

## Statut

🚧 Conception avancée : surface de contrôle + BOM figées. **Seul chantier ouvert** :
étude diffusion LED (cellule touche+LED). Ensuite : schéma KiCad.
