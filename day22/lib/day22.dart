import 'dart:math';

enum Dir {
  e,
  s,
  w,
  n;

  Point<int> toPointOffset() {
    switch (this) {
      case e:
        return Point(1, 0);
      case w:
        return Point(-1, 0);
      case n:
        return Point(0, -1);
      case s:
        return Point(0, 1);
    }
  }

  Dir opposite() {
    return Dir.values[(index + 2) % Dir.values.length];
  }
}

enum TurnDirection {
  left,
  right,
  around,
  none;

  static TurnDirection fromString(String input) {
    switch (input) {
      case "L":
        return left;
      case "R":
        return right;
      default:
        throw Exception("unable to parse TurnDirection");
    }
  }
}

abstract class Instruction {
  Mob apply(Mob mob);
  static Instruction factory(String instructionString) {
    final asInt = int.tryParse(instructionString);
    if (asInt == null) {
      return Rotate(TurnDirection.fromString(instructionString));
    }
    return Move(asInt);
  }
}

class Move implements Instruction {
  final int amount;

  Move(this.amount);
  @override
  Mob apply(Mob mob) {
    print("moving $amount");
    Mob ret = mob;
    for (var i = 0; i < amount; i++) {
      ret = ret.loc.traverse(ret);
    }
    print("new pos: ${ret.loc}");
    return ret;
  }
}

class Rotate implements Instruction {
  final TurnDirection turnDirection;

  Rotate(this.turnDirection);
  @override
  Mob apply(Mob mob) {
    print("rotating $turnDirection");
    switch (turnDirection) {
      case TurnDirection.right:
        final newDirection = (mob.facing.index + 1) % Dir.values.length;
        return Mob(Dir.values[newDirection], mob.loc);
      case TurnDirection.left:
        final newDirection =
            (mob.facing.index + Dir.values.length - 1) % Dir.values.length;
        return Mob(Dir.values[newDirection], mob.loc);
      case TurnDirection.around:
        final newDirection = (mob.facing.index + 2) % Dir.values.length;
        return Mob(Dir.values[newDirection], mob.loc);
      case TurnDirection.none:
        return mob;
    }
  }

  @override
  String toString() {
    return "Rotate $turnDirection";
  }
}

class Mob {
  final Dir facing;
  final Location loc;

  Mob(this.facing, this.loc);
  int getCode() {
    print(loc.position);
    return facing.index +
        4 * (loc.position.x + 1) +
        1000 * (loc.position.y + 1);
  }

  @override
  String toString() {
    return "Mob @ $loc, facing $facing";
  }
}

class Location {
  final Map<Dir, Location> links;
  final Map<Dir, Rotate> edgeBehaviors;
  final LocationType type;
  final Point<int> position;

  Location(this.type, this.position)
      : links = {},
        edgeBehaviors = {};

  Mob traverse(Mob mob) {
    assert(links[mob.facing] != null);
    final newLoc = links[mob.facing]!;
    print("traversing from $position to ${newLoc.position}");

    if (newLoc.type == LocationType.wall) {
      print("hit wall at ${newLoc.position}. staying at $position");
      return mob;
    }
    final strangeBehavior = edgeBehaviors[mob.facing];
    if (strangeBehavior != null) {
      print("*3d seam*");
      return Mob(strangeBehavior.apply(mob).facing, newLoc);
    }
    return Mob(mob.facing, newLoc);
  }

  @override
  String toString() {
    return "$position: $type";
  }
}

enum LocationType {
  wall,
  empty;

  static LocationType? fromString(String input) {
    switch (input) {
      case ".":
        return empty;
      case "#":
        return wall;
      default:
        return null;
    }
  }
}

class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}

class Translation {
  final Face destination;
  final bool reverse;
  final TurnDirection turnDirection;
  final Dir destinationEdge;

  Translation(
      this.destination, this.reverse, this.turnDirection, this.destinationEdge);

  void createSeam(
      Face fromFace, Dir fromDir, Map<Point<int>, Location> allLocations) {
    print("building links for face $fromFace, $fromDir");
    List<Point> fromPoints = fromFace.getEdgePoints(fromDir);
    final List<Point> toPoints = destination.getEdgePoints(destinationEdge);
    if (reverse) {
      fromPoints = fromPoints.reversed.toList();
    }
    final rotate = Rotate(turnDirection);
    for (var i = 0; i < fromFace.faceSize; i++) {
      final from = allLocations[fromPoints[i]];
      final to = allLocations[toPoints[i]];
      from!.links[fromDir] = to!;
      from.edgeBehaviors[fromDir] = rotate;
    }
  }
}

class Face {
  final int number;
  final int minX;
  final int maxX;
  final int minY;
  final int maxY;
  final int faceSize;
  final Map<Dir, Face> naiveLinks;
  final Map<Dir, Translation> links;

  Face(this.minX, this.maxX, this.minY, this.maxY, this.faceSize, this.number)
      : links = {},
        naiveLinks = {};

  static Face fromPointAndSize(Point<int> topLeft, int size) {
    return Face(topLeft.x, topLeft.x + size, topLeft.y, topLeft.y + size, size,
        topLeft.x ~/ size + 4 * topLeft.y ~/ size);
  }

  bool contains(Point<int> point) {
    return point.x >= minX &&
        point.x < maxX &&
        point.y >= minY &&
        point.y < maxY;
  }

  List<Point<int>> getEdgePoints(Dir dir) {
    switch (dir) {
      case Dir.e:
        return List.generate(
            faceSize, (index) => Point(maxX - 1, minY + index));
      case Dir.w:
        return List.generate(faceSize, (index) => Point(minX, minY + index));
      case Dir.n:
        return List.generate(faceSize, (index) => Point(minX + index, minY));
      case Dir.s:
        return List.generate(
            faceSize, (index) => Point(minX + index, maxY - 1));
    }
  }

  @override
  String toString() {
    return "Face #$number: $minX<=x<$maxX $minY<=y<$maxY naiveLinks: ${naiveLinks.entries.map((kv) => "${kv.key}: ${kv.value.number}")}";
  }
}
