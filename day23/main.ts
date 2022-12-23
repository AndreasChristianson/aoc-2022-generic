import { Grid } from "./Grid.ts";

if (import.meta.main) {
  const lines = await readData();

  const data = parseData(lines);

  while (!data.takeTurn()) {
    data.debug();
  }
  data.debug();
  console.log("done!");
  console.log(data.hardComputeBlanks());
}

function parseData(lines: string[]) {
  const data = new Grid();
  lines.forEach(function (line, row) {
    const chars = line.split("");
    chars.forEach(function (char, col) {
      switch (char) {
        case "#":
          data.createElf(col, row);
      }
    });
  });
  return data;
}

async function readData() {
  return (await Deno.readTextFile(Deno.args[0]))
    .split("\n")
    .filter((line) => line.length > 0);
}
