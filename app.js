(() => {
  "use strict";

  const parts = [
    "src/runtime/part-00.txt",
    "src/runtime/part-01.txt",
    "src/runtime/part-02.txt",
    "src/runtime/part-03.txt",
    "src/runtime/part-04.txt",
    "src/runtime/part-05.txt",
    "src/runtime/part-06.txt"
  ];

  // Some NVIDIA/Linux GLSL compilers fail internally on compound
  // multiplication assignments, especially when the target is a swizzle.
  // These source-level rewrites preserve the original mathematics while
  // presenting the shader in a more widely compatible form.
  const shaderCompatibilityRewrites = [
    ["p *= p + 33.33;", "p = p * (p + 33.33);"],
    ["p *= p + p;", "p = p * (p + p);"],
    ["amplitude *= 0.5;", "amplitude = amplitude * 0.5;"],
    [
      "p.xz *= rot(collective + (a4 - 0.5) * 0.3);",
      "p.xz = p.xz * rot(collective + (a4 - 0.5) * 0.3);"
    ],
    ["pWarp.xz *= rot(slowTurn);", "pWarp.xz = pWarp.xz * rot(slowTurn);"],
    [
      "pWarp.xy *= rot(sin(t * 0.027) * 0.11);",
      "pWarp.xy = pWarp.xy * rot(sin(t * 0.027) * 0.11);"
    ],
    [
      "radius *= 0.87 + 0.13 * sin(t * mix(0.17, 0.39, seedMix(fi + 52.0)) + fi);",
      "radius = radius * (0.87 + 0.13 * sin(t * mix(0.17, 0.39, seedMix(fi + 52.0)) + fi));"
    ],
    [
      "q.xy *= rot((seedMix(fi * 13.0 + 310.0) - 0.5) * 2.3 + sin(t * 0.024 + fi) * 0.13);",
      "q.xy = q.xy * rot((seedMix(fi * 13.0 + 310.0) - 0.5) * 2.3 + sin(t * 0.024 + fi) * 0.13);"
    ],
    [
      "q.xz *= rot((seedMix(fi * 17.0 + 330.0) - 0.5) * 2.1);",
      "q.xz = q.xz * rot((seedMix(fi * 17.0 + 330.0) - 0.5) * 2.1);"
    ],
    [
      "cleftPoint.xy *= rot((seedMix(421.0) - 0.5) * 2.4 + sin(t * 0.019) * 0.16);",
      "cleftPoint.xy = cleftPoint.xy * rot((seedMix(421.0) - 0.5) * 2.4 + sin(t * 0.019) * 0.16);"
    ],
    [
      "cleftPoint.xz *= rot((seedMix(422.0) - 0.5) * 1.9);",
      "cleftPoint.xz = cleftPoint.xz * rot((seedMix(422.0) - 0.5) * 1.9);"
    ],
    ["scale *= 0.68;", "scale = scale * 0.68;"],
    [
      "color *= mix(0.48, 1.0, vignette);",
      "color = color * mix(0.48, 1.0, vignette);"
    ],
    [
      "color *= u_exposure * (0.97 + sin(u_cameraTime * 0.09) * 0.025);",
      "color = color * (u_exposure * (0.97 + sin(u_cameraTime * 0.09) * 0.025));"
    ]
  ];

  function makeDriverCompatible(source) {
    return shaderCompatibilityRewrites.reduce(
      (rewritten, [original, replacement]) => rewritten.replaceAll(original, replacement),
      source
    );
  }

  async function start() {
    try {
      const fragments = await Promise.all(
        parts.map(async (path) => {
          const response = await fetch(path, { cache: "no-store" });
          if (!response.ok) {
            throw new Error(`Could not load ${path} (${response.status})`);
          }
          return response.text();
        })
      );

      // The fragments form one authored WebGL runtime. Indirect eval keeps its
      // private IIFE scope intact after the source has been reconstructed.
      const runtimeSource = makeDriverCompatible(fragments.join("\n"));
      (0, eval)(runtimeSource);
    } catch (error) {
      const message = document.getElementById("error");
      const enter = document.getElementById("enter-button");
      if (enter) enter.hidden = true;
      if (message) {
        message.hidden = false;
        message.textContent = `FEROMORPH could not initialise.\n\n${error.message}`;
      }
      console.error(error);
    }
  }

  start();
})();