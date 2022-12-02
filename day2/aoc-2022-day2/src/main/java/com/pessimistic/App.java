package com.pessimistic;

import java.io.Console;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.Format;
import java.util.AbstractMap;
import java.util.Arrays;
import java.util.List;
import java.util.AbstractMap.SimpleEntry;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

public class App {
  enum RPC {
    Rock(1, 3, 'A', 'X'),
    Paper(2, 1, 'B', 'Y'),
    Scissors(3, 2, 'C', 'Z');

    int score;
    int beats;
    char them;
    char us;

    RPC(int score, int beats, char them, char us) {
      this.score = score;
      this.beats = beats;
      this.us = us;
      this.them = them;
    }

    public static RPC fromThem(String group) {
      return Arrays.stream(RPC.values()).filter(rpc -> rpc.them == group.charAt(0)).findAny().orElseThrow();
    }

    public static RPC fromUs(String group) {
      return Arrays.stream(RPC.values()).filter(rpc -> rpc.us == group.charAt(0)).findAny().orElseThrow();
    }

    public int getOutComeScore(RPC them) {
      if (beats == them.score) {
        return 6;
      }
      if (this == them) {
        return 3;
      }
      return 0;
    }

    public RPC getBeatenBy() {
      return Arrays.stream(RPC.values()).filter(other -> other.beats == this.score).findAny().orElseThrow();
    }

    public RPC getBeats() {
      return Arrays.stream(RPC.values()).filter(other -> this.beats == other.score).findAny().orElseThrow();
    }
  }

  enum Outcome {
    X,
    Y,
    Z;

    public RPC getThrow(RPC them) {
      switch (this) {
        case X:
          return them.getBeats();
        case Y:
          return them;
        case Z:
          return them.getBeatenBy();
        default:
          throw new RuntimeException();
      }
    }

  }

  public static void main(String[] args) throws IOException {

    Pattern format = Pattern.compile("([ABC]) ([XYZ])");
    List<AbstractMap.SimpleEntry<RPC, RPC>> data = null;
    try (Stream<String> stream = Files.lines(Paths.get("input.txt"))) {

      int score = stream
          .map(line -> format.matcher(line))
          .peek(Matcher::find)
          .map(m -> new AbstractMap.SimpleEntry<RPC, RPC>(RPC.fromThem(m.group(1)), RPC.fromUs(m.group(2))))
          .mapToInt(round -> round.getValue().getOutComeScore(round.getKey()) + round.getValue().score)
          .sum();
      System.out.println(score);
    }

    try (Stream<String> stream = Files.lines(Paths.get("input.txt"))) {
      int score = stream
          .map(line -> format.matcher(line))
          .peek(Matcher::find)
          .map(m -> new AbstractMap.SimpleEntry<RPC, Outcome>(RPC.fromThem(m.group(1)), Outcome.valueOf(m.group(2))))
          .mapToInt(round -> {
            RPC myThrow = round.getValue().getThrow(round.getKey());
            System.out.println(myThrow);
            return myThrow.getOutComeScore(round.getKey())+myThrow.score;
          })
          .sum();
      System.out.println(score);
    }

  }
}
