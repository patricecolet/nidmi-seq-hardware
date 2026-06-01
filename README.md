# NiDMI Seq — Hardware

Cible matérielle du séquenceur **NiDMI Seq** : carte ESP32-S3 qui porte
l'interface (écran TFT, 4 encodeurs, 27 touches + Shift, LEDs, MIDI).

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

## Statut

🚧 Phase de conception. Voir [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

Prochaine étape : figer la BOM (modèle ESP32-S3, écran TFT, encodeurs) avant de
poser les broches réelles dans le schéma.
