package com.pessimistic

import org.junit.Test
import java.io.File
import kotlin.test.assertEquals

class HelloTest {
    @Test
    fun part1_test() {
        val test = "\$ cd /\n" +
                "\$ ls\n" +
                "dir a\n" +
                "14848514 b.txt\n" +
                "8504156 c.dat\n" +
                "dir d\n" +
                "\$ cd a\n" +
                "\$ ls\n" +
                "dir e\n" +
                "29116 f\n" +
                "2557 g\n" +
                "62596 h.lst\n" +
                "\$ cd e\n" +
                "\$ ls\n" +
                "584 i\n" +
                "\$ cd ..\n" +
                "\$ cd ..\n" +
                "\$ cd d\n" +
                "\$ ls\n" +
                "4060174 j\n" +
                "8033020 d.log\n" +
                "5626152 d.ext\n" +
                "7214296 k"
        assertEquals(
            95437,
            toDirs(test)
                .filter { it.size() < 100000 }
                .sumOf { it.size() }
        )
    }

    @Test
    fun part1_input() {

        assertEquals(
            1490523,
            toDirs(File("input.txt").readText())
                .filter { it.size() < 100000 }
                .sumOf { it.size() }
        )
    }

    @Test
    fun part2_test() {
        val dirs = toDirs(
            """
                ${'$'} cd /
                ${'$'} ls
                dir a
                14848514 b.txt
                8504156 c.dat
                dir d
                ${'$'} cd a
                ${'$'} ls
                dir e
                29116 f
                2557 g
                62596 h.lst
                ${'$'} cd e
                ${'$'} ls
                584 i
                ${'$'} cd ..
                ${'$'} cd ..
                ${'$'} cd d
                ${'$'} ls
                4060174 j
                8033020 d.log
                5626152 d.ext
                7214296 k
            """.trimIndent()
        )
        val totalSize = dirs[0].size()
        val minNeeded = 30_000_000-(70_000_000 - totalSize)
        println(minNeeded)

        assertEquals(
            24933642,
            dirs
                .filter { it.size() >minNeeded }
                .minOf { it.size() }

        )
    }

    @Test
    fun part2_input() {
        val dirs = toDirs(
            File("input.txt").readText()
        )
        val totalSize = dirs[0].size()
        val minNeeded = 30_000_000-(70_000_000 - totalSize)
        println(minNeeded)

        assertEquals(
            12390492,
            dirs
                .filter { it.size() >minNeeded }
                .minOf { it.size() }

        )
    }
}

