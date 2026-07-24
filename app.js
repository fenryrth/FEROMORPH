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
      (0, eval)(fragments.join("\n"));
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
