package com.pessimistic

import java.io.File

fun main(args: Array<String>) {
  fun findCommonChar(list: List<String>): Char {
    return list.drop(1)
        .fold(list.first().toSet(), { acc, string -> acc.intersect(string.toList()) })
        .first()
  }
  fun toPriority(item: Char): Int {
    if ((65..90).contains(item.code)) {
      return item.code - 65 + 27
    } else {
      return item.code - 97 + 1
    }
  }
  val part1 =
      File("input.txt")
          .readText()
          .lines()
          .filter { it.length > 0 }
          .map { it.chunked(it.length / 2) }
          .map { findCommonChar(it) }
          .map { toPriority(it) }
          .sum()
  println(part1)

  val part2 =
      File("input.txt")
          .readText()
          .lines()
          .filter { it.length > 0 }
          .chunked(3)
          .map { findCommonChar(it) }
          .map { toPriority(it) }
          .sum()
  println(part2)
}
