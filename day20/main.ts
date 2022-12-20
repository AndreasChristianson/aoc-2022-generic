import { key } from "./key.ts";
import { Node } from "./Node.ts";

if (import.meta.main) {
  const data = (await Deno.readTextFile("./input.txt"))
    .split("\n")
    .filter((line) => line.length > 0)
    .map((s) => parseInt(s));

  console.log(data);

  const mixed = mix(data);
  console.log("complete!");
  console.log(mixed);
  console.log(extract(mixed));
}

export function mix(data: number[]): number[] {
  const head = new Node(data[0]);
  let cursor = head;
  for (let index = 1; index < data.length; index++) {
    const ele = data[index];
    const newNode = new Node(ele);
    cursor.next = newNode;
    newNode.prev = cursor;
    cursor = newNode;
  }
  head.prev = cursor;
  cursor.next = head;
  const initialPositions = [];
  initialPositions[0] = head;
  let count = 1;
  for (let cursor = head.next; cursor !== head; cursor = cursor!.next) {
    initialPositions[count++] = cursor!;
  }
  // console.log(initialPositions);
  for (let shuffle = 0; shuffle < 10; shuffle++) {
    initialPositions.forEach((node) => {
      const numMoves = Math.abs(node.data * key) % (data.length - 1);
      const func =
        node.data > 0 ? node.swapNext.bind(node) : node.swapPrev.bind(node);
      for (let index = 0; index < numMoves; index++) {
        func();
        // console.log(unwrap(head));
      }
    });
  }
  return unwrap(head);
}

function rotate(currentPos: number, length: number, delta: number) {
  return (length * 100 + currentPos + delta) % length;
}

export function extract(data: number[]) {
  const currentPos = data.findIndex((i) => i === 0);
  const onek = rotate(currentPos, data.length, 1000);
  const twok = rotate(currentPos, data.length, 2000);
  const threek = rotate(currentPos, data.length, 3000);
  return data[onek] * key + data[twok] * key + data[threek] * key;
}

function unwrap(head: Node<number>): number[] {
  const ret = [head.data];
  let count = 1;
  for (let cursor = head.next; cursor !== head; cursor = cursor!.next) {
    ret[count++] = cursor!.data;
  }
  return ret;
}
