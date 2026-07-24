# FEROMORPH Native

FEROMORPH Native is the standalone Godot edition of Michael Gram's autonomous generative digital sculpture.

This edition replaces the experimental browser raymarcher with ordinary native 3D geometry. The sculpture is assembled from slowly mutating masses, rigid interruptions and temporary ligaments. It is designed to run at a capped 30 FPS and includes an automatic performance safeguard.

## Technical target

- Godot 4.7.1 stable
- Compatibility renderer (OpenGL)
- Linux x86_64 first
- 30 FPS cap
- No web browser, local server, npm or service worker
- No third-party assets or runtime dependencies

## Open in Godot

1. Install Godot 4.7.1 Standard.
2. Import `native/project.godot` from the repository root.
3. Press **F6** or **F5**.

## Controls

| Key | Action |
| --- | --- |
| `N` | Begin a new genesis with a new seed |
| `P` or `Space` | Suspend or resume time |
| `F` | Toggle fullscreen |
| `Q` | Cycle quality profile |
| `1` / `2` / `3` | Safe / Standard / Installation quality |
| `S` | Save the current frame as PNG |
| `H` | Hide or show the interface |
| `Esc` | Leave fullscreen |

## Quality profiles

- **Safe:** 8 masses, 10 ligaments, shadows disabled.
- **Standard:** 12 masses, 18 ligaments, moderate geometry.
- **Installation:** 16 masses, 26 ligaments, higher geometry detail.

If the measured frame rate remains below 19 FPS for five seconds, FEROMORPH automatically steps down one profile.

## Export

Install the official Godot 4.7.1 export templates, then run from the repository root:

```bash
godot --headless --path native --export-release "Linux x86_64" native/build/FEROMORPH.x86_64
```

Concept and artwork © Michael Gram. All rights reserved.
