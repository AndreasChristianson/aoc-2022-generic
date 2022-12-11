// Learn more at https://deno.land/manual/examples/module_metadata#concepts
if (import.meta.main) {
  const lines = (await Deno.readTextFile("./test2.txt"))
    .split("\n")
    .filter((line) => line.length > 0);
  let value = 1;
  let sum = 0;
  let param = 0;
  let index = 0;
  let crt = "";
  for (let cycle = 1; cycle < 240; cycle++) {
    if ((cycle - 20) % 40 == 0) {
      sum += cycle * value;
    }
    const pos = (cycle % 40) - 1;
    if (Math.abs(value - pos) < 2) {
      crt += "#";
    } else {
      crt += " ";
    }

    if (cycle % 40 == 0) {
      crt += "\n";
    }

    if (param != 0) {
      value += param;
      param = 0;
    } else if (index < lines.length) {
      const line = lines[index];
      index++;
      const splitLine = line.split(" ");
      switch (splitLine[0]) {
        case "noop":
          break;
        case "addx":
          param = parseInt(splitLine[1]);
          break;
        default:
          throw Error("Uh, guys..");
      }
    }
  }
  console.log(sum);
  console.log(crt);
}
