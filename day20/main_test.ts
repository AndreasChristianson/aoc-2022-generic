import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";
import { mix, extract } from "./main.ts";

Deno.test("move up", () => {
  assertEquals(mix([0, 0, -1]), [0, -1, 0]);
  assertEquals(mix([0, 0, -2]), [-2, 0, 0]);
  assertEquals(mix([0, 0, -3]), [0,  -3,0]);
  assertEquals(mix([0, 0, -4]), [-4, 0, 0]);
  assertEquals(mix([0, 0, -5]), [0, 0, -5]);
  assertEquals(mix([0, -3, 0]), [0, -3,0 ]);
  assertEquals(mix([0, -3, 0,0]), [0, -3,0,0 ]);
  assertEquals(mix([0, -3, 0,0,0,0,0]), [0,0,0,0,-3,0,0]);
  assertEquals(mix([0, -13, 0,0,0,0,0]), [0,-13,0,0,0,0,0]);
});

Deno.test("move down", () => {
  assertEquals(mix([1, 0, 0]), [0, 1, 0]);
  assertEquals(mix([2, 0, 0]), [0, 0, 2]);
  assertEquals(mix([3, 0, 0]), [3, 0, 0]);
  assertEquals(mix([4, 0, 0]), [0, 4, 0]);
});

Deno.test("extract", () => {
  assertEquals(extract([1, 2, -3, 4, 0, 3, -2]), 3);
});

Deno.test("partial rotate", () => {
  assertEquals(mix([0,0,0,-5,0,0,0]), [0,0,0,0,-5,0,0]);
  assertEquals(mix([0,0,0,-9,0,0,0]), [-9,0,0,0,0,0,0]);
  assertEquals(mix([0, -3, 1, 0, 0, 0, 0]), [0,0,1,0,-3,0,0]);
  

});

Deno.test("test data", () => {
  assertEquals(mix([1, 2, -3, 3, -2, 0, 4]), [1, 2, -3, 4, 0, 3, -2]);
});