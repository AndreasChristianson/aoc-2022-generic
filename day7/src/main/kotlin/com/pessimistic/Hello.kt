package com.pessimistic

fun main(args: Array<String>) {
    println("Hello, World")
}

class Dir(val contents: MutableList<Entry> = mutableListOf(), val path: List<String>) : Entry {
    override fun size(): Int {
        return contents.map(Entry::size).sum()
    }

}

class File(val name: String, val fileSize: Int) : Entry {
    override fun size(): Int {
        return fileSize
    }

}

interface Entry {
    fun size(): Int
}


fun toDirs(input: String): List<Dir> {
    val cdPattern = "\\$ cd (.+)".toRegex()
    val filePattern = "(\\d+) (.+)".toRegex()
    val result = mutableListOf<Dir>();
    val lines = input.split("\n").map { it.trim() }.filter { it.isNotEmpty() }
    val dirPath = mutableListOf<String>()
    var currDir = Dir(mutableListOf(), mutableListOf())
    for (line in lines) {
        when {
            line.startsWith("$ ls") -> {
//                println("found ls (in ${dirPath.joinToString("/")})")
            }

            line.startsWith("dir") -> {

            }

            line.startsWith("$ cd ..") -> {
//                println("found cd .. (in ${dirPath.joinToString("/")})")
                dirPath.removeLast()
                currDir = result.first { it.path == dirPath }
//                result.add(currDir)
            }

            line.startsWith("$ cd /") -> {
//                println("found cd / (in ${dirPath.joinToString("/")})")
                dirPath.clear()
                dirPath.add("ROOT")
                currDir = Dir(path = dirPath.toList())
                result.add(currDir)
            }

            line.startsWith("$ cd") -> {
                val match = cdPattern.find(line)
                val dir = match!!.groups[1]!!.value
//                println("found cd to dir ($dir) (in ${dirPath.joinToString("/")})")
                dirPath.add(dir)
                val newDir = Dir(path = dirPath.toList())
                currDir.contents.add(newDir)
                currDir = newDir
                result.add(currDir)
            }

            else -> {
                val match = filePattern.find(line)
                val file = match!!.groups[2]!!.value
                val size = match.groups[1]!!.value.toInt()
//                println("found file ($file : $size) (in ${dirPath.joinToString("/")})")
                currDir.contents.add(File(file, size))
            }
        }
    }
    println("dirs:\n ${result.map { "${it.path.joinToString("/")}: ${it.size()}" }.joinToString("\n")}")
    return result
}