import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:day19/day19.dart';

void main(List<String> arguments) async {
  final file = arguments[0];
  final minutes = int.parse(arguments[1]);
  print('file: $file, min: $minutes');
  final rawFileContents = await readFile(file);
  print(rawFileContents);
  final bluePrints = rawFileContents.map(parseBluePrint).toList();
  // print(bluePrints);
  final factories = bluePrints
      .map(
        (bluePrint) => Factory.start(bluePrint),
      )
      .toList();

  var last = DateTime.now().second;
  var totalQual = 0;
  for (var factory in factories) {
    Map<int, int> maxGeodeRobotPerGeneration = {};
    print(factory.bluePrint);
    final Queue<Factory> queue = Queue();
    Factory? best;
    queue.add(factory);
    int itCount = 0;
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      int maxGeodesThisGen = maxGeodeRobotPerGeneration[current.minute] ?? 0;
      if (current.robots.get(RT.geode) > maxGeodesThisGen) {
        maxGeodeRobotPerGeneration[current.minute] =
            current.robots.get(RT.geode);
      }
      if ((maxGeodeRobotPerGeneration[current.minute - 1] ?? 0) >
          current.robots.get(RT.geode) + 2) {
        //way behind, give up
        continue;
      }
      if (current.minute >= minutes) {
        // print("finished $current");
        if (best == null || best.quality() < current.quality()) {
          best = current;
        }
      } else {
        final now = DateTime.now().second;
        if (now != last) {
          last = now;
          print("ongoing... $itCount $current");
        }
        itCount++;
        // print("${itCount++} $current");
        queue.addAll(current.iterateAll());
      }
    }
    print("BEST: $best");
    totalQual += best!.quality();
  }
  print("overall total qual: $totalQual");
}

Future<List<String>> readFile(String filename) async {
  final file = File(filename);
  return await file
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .where((s) => s.isNotEmpty)
      .toList();
}

final regex = RegExp(
    r'^Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian.$');

BluePrint parseBluePrint(String line) {
  final match = regex.firstMatch(line);
  final name = int.parse(match!.group(1)!);
  final oreRobotOreCost = int.parse(match.group(2)!);
  final clayRobotOreCost = int.parse(match.group(3)!);
  final obsidianRobotOreCost = int.parse(match.group(4)!);
  final obsidianRobotClayCost = int.parse(match.group(5)!);
  final geodeRobotOreCost = int.parse(match.group(6)!);
  final geodeRobotObsidianCost = int.parse(match.group(7)!);

  return BluePrint(name, {
    RT.ore: Resources.single(RT.ore, oreRobotOreCost),
    RT.clay: Resources.single(RT.ore, clayRobotOreCost),
    RT.obsidian: Resources.fromMap(
        {RT.ore: obsidianRobotOreCost, RT.clay: obsidianRobotClayCost}),
    RT.geode: Resources.fromMap(
        {RT.ore: geodeRobotOreCost, RT.obsidian: geodeRobotObsidianCost})
  });
}
