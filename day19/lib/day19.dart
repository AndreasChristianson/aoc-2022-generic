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
    return ret;
  }

  Resources cost(RT newRobot) {
    return costs[newRobot]!;
  }
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
    final List<Factory> results =
        [RT.obsidian, RT.clay, RT.ore].where(shouldBuild).map(iterate).toList();

    //could be saving up for something
    if (resources.get(RT.ore) < bluePrint.getMaxCost(RT.ore) ||
        resources.get(RT.clay) < bluePrint.getMaxCost(RT.clay) ||
        resources.get(RT.obsidian) < bluePrint.getMaxCost(RT.obsidian)) {
      results.add(iterate(null));
    }
    return results;
  }

  Factory iterate(RT? newRobot) {
    if (newRobot != null) {
      // assert(canAfford(newRobot));

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
