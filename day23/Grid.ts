import { Elf } from "./Elf.ts";

export class Grid {
  hardComputeBlanks(): any {
    this.maxX = 0;
    this.maxY = 0;
    this.minX = 0;
    this.minY = 0;
    for (const pos of this.data.keys()) {
      const xy = fromKey(pos);
      this.updateMaxes(xy[0], xy[1]);
    }
    return (this.maxX - this.minX+1) * (this.maxY - this.minY+1) - this.data.size;
  }
  maxX = 0;
  maxY = 0;
  minX = 0;
  minY = 0;
  data = new Map<string, Elf>();
  turn = 0;

  createElf(x: number, y: number) {
    this.data.set(toKey(x, y), new Elf());
    this.updateMaxes(x, y);
  }

  takeTurn():boolean {
    const proposals = new Set<string>();
    const newDirections = this.getDirection();
    console.log(`directions:`, newDirections);
    let noElfMoved=true;
    for (const pos of this.data.keys()) {
      const elf = this.data.get(pos)!;
      const xy = fromKey(pos);
      const directions = allDirections
        .map((toBeChecked) =>
          toKey(toBeChecked[0] + xy[0], toBeChecked[1] + xy[1])
        )
        .map((key) => !this.data.has(key));
      if (directions.every((t) => t)) {
        continue;
      }
      for (const dir of newDirections) {
        const { move, checks } = dir;
        if (
          directions[checks[0]] &&
          directions[checks[1]] &&
          directions[checks[2]]
        ) {
          const requestedMove = toKey(move[0] + xy[0], move[1] + xy[1]);
          if (!proposals.has(requestedMove)) {
            elf.requestedMove = requestedMove;
            proposals.add(requestedMove);
          } else {
            proposals.delete(requestedMove);
          }
          break;
        }
      }
    }

    console.log(`proposals: ${proposals.size}`);
    for (const pos of this.data.keys()) {
      const elf = this.data.get(pos)!;
      if (elf.requestedMove != null && proposals.has(elf.requestedMove)) {
        this.data.delete(pos);
        this.data.set(elf.requestedMove, elf);
        const xy = fromKey(elf.requestedMove);
        this.updateMaxes(xy[0], xy[1]);
        noElfMoved = false
      }
      elf.requestedMove = null;
    }
    this.turn++;
    return noElfMoved
  }
  getDirection(): {
    checks: number[];
    move: number[];
  }[] {
    const start = this.turn % 4;
    let ret: {
      checks: number[];
      move: number[];
    }[] = [];
    for (let index = start; index < start + 4; index++) {
      ret = [...ret, moveQueue[index % 4]];
    }
    return ret;
  }

  updateMaxes(x: number, y: number) {
    this.minX = Math.min(this.minX, x);
    this.minY = Math.min(this.minY, y);
    this.maxX = Math.max(this.maxX, x);
    this.maxY = Math.max(this.maxY, y);
  }

  debug() {
    let s = `Grid Data at turn ${this.turn} (${this.data.size} elves):\n`;
    for (let y = this.minY; y <= this.maxY; y++) {
      for (let x = this.minX; x <= this.maxX; x++) {
        const potentialElf = this.data.get(toKey(x, y));
        if (potentialElf) {
          s = `${s}#`;
        } else {
          s = `${s} `;
        }
      }
      s = `${s}\n`;
    }
    console.log(`${s}`);
  }
}

function toKey(x: number, y: number): string {
  return `${x},${y}`;
}
// I hate javascript.
function fromKey(key: string): [number, number] {
  const asarray = key.split(",").map((s) => parseInt(s));
  return [asarray[0], asarray[1]];
}

const moveQueue = [
  {
    checks: [0, 1, 7],
    move: [0, -1],
  },
  {
    checks: [3, 4, 5],
    move: [0, 1],
  },
  {
    checks: [1, 2, 3],
    move: [-1, 0],
  },
  {
    checks: [5, 6, 7],
    move: [1, 0],
  },
];

const allDirections = [
  [0, -1],
  [-1, -1],
  [-1, 0],
  [-1, 1],
  [0, 1],
  [1, 1],
  [1, 0],
  [1, -1],
];
