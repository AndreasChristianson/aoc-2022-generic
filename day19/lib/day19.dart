import 'dart:math';

enum RT {
  ore,
  clay,
  obsidian,
  geode;
}

class BluePrint {
  final int number;

  final Map<RT, Resources> costs;
  Resources? maxCosts;

  BluePrint(
    this.number,
    this.costs,
  );

  @override
  String toString() {
    var ret = "\n#$number. Robot costs:";
    for (var kv in costs.entries) {
      ret += "\n  ${kv.key}: ${kv.value}";
    }
    return ret;
  }

  int getMaxCost(RT resourceType) {
    maxCosts ??= calcMaxCosts();
    return maxCosts!.get(resourceType);
  }

  Resources calcMaxCosts() {
    var ret = Resources();
    for (var costType in RT.values) {
      var maxCost = 0;
      for (var robot in RT.values) {
        maxCost = max(maxCost, cost(robot).get(costType));
      }
      ret = ret.change(costType, maxCost);
    }
    // print(ret);
    return ret;
  }

  Resources cost(RT newRobot) {
    return costs[newRobot]!;
  }

  // Resources recur(int maxDepth, Resources resources, Resources robots) {
  //   if (maxDepth == 0) {
  //     return resources;
  //   }
  //   final patResouces = Resources.fromMap(resources.map);
  //   patResouces.add(robots);
  //   var bestOption = recur(maxDepth - 1, patResouces, robots);
  //   if (resources.has(costs[RT.geode]!)) {
  //     final newResources = Resources.fromMap(resources.map);
  //     newResources.subtract(costs[RT.geode]!);
  //     newResources.add(robots);
  //     final newRobots = Resources.fromMap(robots.map);
  //     newRobots.change(RT.geode, 1);
  //     final potential = recur(maxDepth - 1, newResources, newRobots);
  //     if (potential.get(RT.geode) > bestOption.get(RT.geode)) {
  //       bestOption = potential;
  //     }
  //   } else {
  //     for (var type in RT.values) {
  //       if (resources.has(costs[type]!)) {
  //         final newResources = Resources.fromMap(resources.map);
  //         newResources.subtract(costs[type]!);
  //         newResources.add(robots);
  //         final newRobots = Resources.fromMap(robots.map);
  //         newRobots.change(type, 1);
  //         final potential = recur(maxDepth - 1, newResources, newRobots);
  //         if (potential.get(RT.geode) > bestOption.get(RT.geode)) {
  //           bestOption = potential;
  //         }
  //       }
  //     }
  //   }
  //   return bestOption;
  // }
}

class Resources {
  final Map<RT, int> map = {
    RT.ore: 0,
    RT.clay: 0,
    RT.obsidian: 0,
    RT.geode: 0,
  };
  Resources();

  Resources.single(RT type, int amount) {
    map[type] = amount;
  }
  Resources.fromMap(Map<RT, int> map) {
    for (final kv in map.entries) {
      this.map[kv.key] = kv.value;
    }
  }

  Resources change(RT resource, int amount) {
    final newMap = Map<RT, int>.from(map);
    newMap[resource] = get(resource) + amount;
    return Resources.fromMap(newMap);
  }

  Resources subtract(Resources other) {
    final newMap = Map<RT, int>.from(map);
    for (var rt in RT.values) {
      newMap[rt] = newMap[rt]! + other.get(rt) * -1;
    }
    return Resources.fromMap(newMap);
  }

  int get(RT resource) {
    return map[resource]!;
  }

  bool has(Resources other) {
    for (var type in RT.values) {
      final needed = other.get(type);
      if (needed > 0 && get(type) < needed) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    var ret = "";
    for (var kv in map.entries) {
      ret += "${kv.key}:${kv.value} ";
    }
    return ret.trim();
  }

  Resources add(Resources other) {
    final newMap = Map<RT, int>.from(map);
    for (var rt in RT.values) {
      newMap[rt] = newMap[rt]! + other.get(rt);
    }
    return Resources.fromMap(newMap);
  }
}

class Factory {
  final Resources resources;
  final Resources robots;
  final BluePrint bluePrint;
  final int minute;
  final Factory? lastState;
  final RT? built;

  Factory(this.bluePrint, this.robots, this.resources, this.minute,
      this.lastState, this.built);
  Factory.start(this.bluePrint)
      : minute = 0,
        robots = Resources.single(RT.ore, 1),
        resources = Resources(),
        lastState = null,
        built = null;

  // void iterate() {
  //   RT? newRobot = makeNewRobot(RT.geode);
  //   for (final rt in RT.values) {
  //     final amount = robots[rt]!;
  //     if (amount > 0) {
  //       print("produced $amount $rt");
  //     }
  //     resources.change(rt, amount);
  //   }
  //   if (newRobot != null) {
  //     robots[newRobot] = robots[newRobot]! + 1;
  //   }
  // }

  // RT? makeNewRobot(RT target) {
  //   final timeToBeat =
  //       minutesUntilCanAfford(target, resources, Resources.fromMap(robots));
  //   if (timeToBeat == 0) {
  //     resources.subtract(bluePrint.costs[target]!);
  //     print("begin making a $target robot");
  //     return target;
  //   }
  //   print("time to make a $target: $timeToBeat mins");
  //   final requirementsByCost = bluePrint.costs[target]!.map.entries
  //       .where((kv) => kv.value > 0)
  //       .where((kv) => kv.key != target)
  //       .toList();
  //   requirementsByCost.sort((l, r) => (r.value / robots[r.key]!.toDouble() -
  //           l.value / robots[l.key]!.toDouble())
  //       .sign
  //       .toInt());
  //   for (var kv in requirementsByCost) {
  //     final type = kv.key;
  //     final hypotheticalRobots = Map<RT, int>.from(robots);
  //     final hypotheticalResources = Resources.fromMap(resources.map);
  //     print("what if we had another ${type} robot...");
  //     hypotheticalResources.subtract(bluePrint.costs[type]!);
  //     hypotheticalRobots[type] = hypotheticalRobots[type]! + 1;
  //     final augmentedTime = minutesUntilCanAfford(
  //         target, hypotheticalResources, Resources.fromMap(hypotheticalRobots));
  //     print("augmented time to make a $target: $augmentedTime mins");
  //     if (augmentedTime <= timeToBeat) {
  //       print("lets build one..");
  //       return makeNewRobot(type);
  //     }
  //     print("roi too low.");
  //   }
  //   print("nothing we can make that might speed this up. bidding my time.");
  //   return null;
  // }

  // RT? makeNewNonOreRobot() {
  //   for (var rt in RT.values.reversed.where((rt) => rt != RT.ore)) {
  //     if (canAfford(rt)) {
  //       return rt;
  //     }
  //   }
  //   return null;
  // }

  int quality() {
    return bluePrint.number * resources.get(RT.geode);
  }

  @override
  String toString() {
    return "#${bluePrint.number}. Min: $minute. Robots: [$robots], Resources: [$resources] Quality: ${quality()}";
  }

  bool canBuild(RT type) {
    return canAfford(type) && robots.get(type) < bluePrint.getMaxCost(type);
  }

  bool shouldBuild(RT type) {
    return canBuild(type) && !lastDidntBuildButCouldHave(type);
  }

  bool lastDidntBuildButCouldHave(RT type) {
    if (lastState == null) {
      return false;
    } else {
      return lastState!.canBuild(type) && built == null;
    }
  }

  bool canAfford(RT type) {
    return resources.has(bluePrint.cost(type));
  }

  List<Factory> iterateAll() {
    if (canAfford(RT.geode)) {
      return [iterate(RT.geode)];
    }
    final List<Factory> results = [];
    if (shouldBuild(RT.obsidian)) {
      // if (resources.get(RT.ore) < bluePrint.getMaxCost(RT.ore) ||
      //     resources.get(RT.clay) < bluePrint.getMaxCost(RT.clay)) {
      //   return [iterate(RT.obsidian), iterate(null)];
      // }
      // return [iterate(RT.obsidian)];
      results.add(iterate(RT.obsidian));
    }

    if (shouldBuild(RT.clay)) {
      results.add(iterate(RT.clay));
    }

    if (shouldBuild(RT.ore)) {
      results.add(iterate(RT.ore));
    }

    //could be saving up for something
    if (resources.get(RT.ore) < bluePrint.getMaxCost(RT.ore) ||
        resources.get(RT.clay) < bluePrint.getMaxCost(RT.clay) ||
        resources.get(RT.obsidian) < bluePrint.getMaxCost(RT.obsidian)) {
      results.add(iterate(null));
    }
    return results;
  }

  // RT? tryToMake(RT currentTarget) {
  //   if (canAfford(currentTarget)) {
  //     return currentTarget;
  //   }
  //   print("unable to afford a $currentTarget robot");

  //   final missing = resources.subtract(bluePrint.cost(currentTarget));
  //   RT? missingMost;
  //   int negativeAmount = 0;
  //   for (var rt in RT.values) {
  //     if (missing.get(rt) < negativeAmount) {
  //       missingMost = rt;
  //       negativeAmount = missing.get(rt);
  //     }
  //   }
  //   print("$missingMost was the resource we needed most");

  //   if (missingMost != null && missingMost != currentTarget) {
  //     print("lets see if we can make a $missingMost robot..");

  //     return tryToMake(missingMost);
  //   }
  //   return null;
  // }

  // List<Factory> iterateBest() {
  //   return [iterate(tryToMake(RT.geode)), iterate(null)];
  // }

  Factory iterate(RT? newRobot) {
    // lastState = null;
    if (newRobot != null) {
      assert(canAfford(newRobot));
      // print("making $newRobot robot");

      return Factory(
          bluePrint,
          robots.change(newRobot, 1),
          resources.add(robots).subtract(bluePrint.cost(newRobot)),
          minute + 1,
          this,
          newRobot);
    }
    return Factory(
        bluePrint, robots, resources.add(robots), minute + 1, this, null);
  }

  bool glut() {
    for (var rt in [RT.clay, RT.ore]) {
      if (bluePrint.getMaxCost(rt) < resources.get(rt) &&
          resources.get(RT.geode) < 2) {
        print("glut found: $rt");
        return true;
      }
    }
    return false;
  }
}
