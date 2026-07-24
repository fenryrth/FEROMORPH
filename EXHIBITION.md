# Exhibition Notes

## Recommended presentation

- Large 16:9 projection or 4K display
- Darkened room with controlled spill light
- Computer connected by cable rather than wireless casting
- Current Chrome or Edge in fullscreen mode
- Cursor hidden by the artwork after the interface fades
- Sound absent in the first version

The work benefits from being displayed slightly larger than a human body. Avoid presenting it as a conventional website on a visible desktop.

## Starting the work

1. Start a local web server in the project directory with `npm run serve` or `python3 -m http.server 8080`.
2. Open `http://localhost:8080` in the browser.
3. Click **ENTER**.
4. Press `F` for fullscreen.
5. Press `H` if the interface remains visible.

A new seed is generated each time the page is opened. Reloading therefore begins a different work-state.

## Stability

For long-running installations:

- disable operating-system sleep and screen savers;
- disable browser tab sleeping;
- connect the computer to mains power;
- test the exact display resolution before opening;
- use a dedicated browser window without extensions;
- reload once before the exhibition opens to begin a fresh genesis.

The renderer automatically lowers its internal resolution if performance drops. This changes image sharpness slightly but preserves movement.

## Capturing a state

Press `S` to export the current frame as a PNG. The filename includes the generation seed and timestamp.

A captured image is a trace of the process, not the work itself.
