package com.pessimistic;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.stream.Stream;

public class App {
  public static void main(String[] args) throws IOException {

    try (Stream<String> stream = Files.lines(Paths.get("input.txt"))) {
      stream.forEach(System.out::println);
    }
  }
}
