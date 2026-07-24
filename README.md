# FEROMORPH

**FEROMORPH** is an autonomous generative digital sculpture by Danish artist [Michael Gram](https://michaelgram.com).

> A feral form: matter that has ceased to obey its maker.

## Current direction: Native

The principal edition is now being rebuilt as a standalone Godot application. It does not require a browser, localhost, npm or a service worker.

The native alpha lives in [`native/`](native/) and is designed around:

- ordinary rasterised 3D geometry rather than full-screen raymarching;
- a hard 30 FPS cap;
- Safe, Standard and Installation quality profiles;
- automatic quality reduction if the host computer becomes overloaded;
- autonomous phases of formation, stillness, rupture and metamorphosis;
- curated material families: oxidised bronze, charred iron, ashen porcelain and buried mineral.

See [`native/README.md`](native/README.md) for controls, technical requirements and export instructions.

## Browser prototype

The root-level WebGL files are retained as an early experiment and historical prototype. This edition is no longer the recommended way to run FEROMORPH because its raymarching renderer proved too demanding and driver-sensitive on the artist's Linux workstation.

## Repository structure

```text
FEROMORPH/
├── native/                       # Standalone Godot edition
│   ├── project.godot
│   ├── scenes/main.tscn
│   ├── scripts/main.gd
│   └── export_presets.cfg
├── index.html                    # Archived browser prototype
├── app.js
├── src/runtime/
├── ARTISTIC_DIRECTION.md
└── EXHIBITION.md
```

## Authorship and rights

Concept and artwork © Michael Gram. All rights reserved.

The repository is published without an open-source licence. No permission is granted to reproduce, exhibit, distribute or create derivative works without the artist's written consent.
