package com.pessimistic

import java.io.File

fun main(args: Array<String>) {
  val pattern = Regex("(.*)")
    println("Hello, World")
    val text = File("test.txt").readText()
      .lines()
      .filter { it.length>0 }
      .map { pattern.find(it) }
      .map{ it!!.groupValues.slice(1..1)}
    println(text)
}

