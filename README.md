# FEROMORPH

**FEROMORPH** is an autonomous generative digital sculpture by Danish artist [Michael Gram](https://michaelgram.com).

It is not a prerecorded animation. Every opening begins from a newly generated state. A virtual material continuously grows, fuses, ruptures, scars, becomes still and reorganises itself. The system never attempts to produce a final form.

> A feral form: matter that has ceased to obey its maker.

## Open the work

The published work is deployed automatically through GitHub Pages.

To run FEROMORPH locally:

1. Download or clone this repository.
2. Open a terminal in the project directory.
3. Run `npm run serve` or `python3 -m http.server 8080`.
4. Open `http://localhost:8080` in a current desktop browser.
5. Press **Enter** and, for an exhibition, use fullscreen mode.

There is no build process and no third-party dependency. A local web server is required because the WebGL runtime is reconstructed from authored source fragments.

## Controls

| Key | Action |
| --- | --- |
| `N` | Initiate a new genesis |
| `Space` | Impose or release stillness |
| `F` | Enter or leave fullscreen |
| `S` | Save the current state as a PNG |
| `H` | Show or hide the discreet interface |
| `P` | Suspend or resume time |

Pointer movement produces a restrained change in viewpoint. The work remains autonomous and does not require interaction.

## The system

FEROMORPH is rendered in real time with a dependency-free WebGL 2 raymarching engine.

The body is constructed from:

- moving implicit volumes joined by smooth unions;
- temporary ligaments between otherwise independent masses;
- internal voids that rupture the body from within;
- procedural surface grain, patina and scars;
- curated material families rather than unrestricted random colour;
- long generational cycles that transition from one genetic state to another;
- rare autonomous pauses and ruptures;
- a performance controller that adapts render resolution to the computer.

A cryptographic random seed is generated locally at every opening. No images, personal information or analytics are transmitted.

## Files

```text
FEROMORPH/
├── index.html                    # Artwork shell and minimal interface
├── app.js                        # Runtime loader
├── src/runtime/part-00…06.txt    # WebGL engine, sculpture and lifecycle
├── styles.css                    # Exhibition-oriented presentation
├── ARTISTIC_DIRECTION.md         # Concept and development principles
├── EXHIBITION.md                 # Practical installation notes
└── .github/workflows/pages.yml   # Automatic GitHub Pages deployment
```

## Browser requirements

FEROMORPH requires WebGL 2. Current versions of Chrome, Edge, Firefox and Safari are recommended. A dedicated GPU is beneficial for large projections.

## Authorship and rights

Concept and artwork © Michael Gram. All rights reserved.

The repository is published without an open-source licence. No permission is granted to reproduce, exhibit, distribute or create derivative works without the artist's written consent.
