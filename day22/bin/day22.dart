import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:day22/day22.dart';

void main(List<String> arguments) async {
  final file = arguments[0];
  final int faceSize = int.parse(arguments[1]);
  final rawFileContents = await readFile(file);
  print(rawFileContents);
  final rawMaze = rawFileContents.sublist(0, rawFileContents.length - 1);
  final rawInstructions = rawFileContents.sublist(
      rawFileContents.length - 1, rawFileContents.length)[0];

  final instructions = RegExp(r'(\d+|[RL])')
      .allMatches(rawInstructions)
      .map((match) => match[0])
      .map((instString) => Instruction.factory(instString!));
  print(instructions);

  Point<int>? start;
  final Map<Point<int>, Location> allLocations = {};
  rawMaze.asMap().forEach((rowNum, line) => {
        line.split("").asMap().forEach((colNum, char) {
          final point = Point(colNum, rowNum);
          final type = LocationType.fromString(char);
          if (type != null) {
            start ??= point;
            allLocations[point] = Location(type, point);
            print("location at $point: $char");
          }
        })
      });
  var mob = Mob(Dir.e, allLocations[start]!);
  crossLink(allLocations);
  crossLinkToCube(allLocations, faceSize);
  print("starting position: $mob");
  for (var instruction in instructions) {
    mob = instruction.apply(mob);
  }
  print(mob.getCode());
}

void crossLink(Map<Point<int>, Location> allLocations) {
  for (var location in allLocations.values) {
    for (var dir in Dir.values) {
      if (location.links[dir] != null) {
        continue;
      }
      final offset = dir.toPointOffset();
      Location? potential = allLocations[location.position + offset];
      if (potential == null) {
        //part1 code
        // var current = location.position;
        // final opposite = dir.opposite().toPointOffset();
        // while (allLocations[current] != null) {
        //   current += opposite;
        // }
        // potential = allLocations[current + offset];
        continue;
      }
      location.links[dir] = potential!;
    }
    print("location: ${location.position}. links:${location.links}");
  }
}

void crossLinkToCube(Map<Point<int>, Location> allLocations, int faceSize) {
  List<Face> faces = identifyFaces(allLocations, faceSize);
  fillNaiveLinks(faces);
  final Map<int, Face> facebook = {};
  for (var face in faces) {
    facebook[face.number] = face;
  }
  print(facebook);
  if (faceSize == 4) {
    foldSmall(facebook);
  } else {
    foldLarge(facebook);
  }
  applySeams(facebook, allLocations);
}

void applySeams(
    Map<int, Face> facebook, Map<Point<int>, Location> allLocations) {
  for (var face in facebook.values) {
    for (var dir in Dir.values) {
      final link = face.links[dir];
      if (link != null) {
        link.createSeam(face, dir, allLocations);
      }
    }
  }
}

void foldSmall(Map<int, Face> facebook) {
  print("folding: Small");
  facebook[2]!.links[Dir.n] =
      Translation(facebook[4]!, true, TurnDirection.around, Dir.n);
  facebook[2]!.links[Dir.w] =
      Translation(facebook[5]!, false, TurnDirection.left, Dir.n);
  facebook[2]!.links[Dir.e] =
      Translation(facebook[11]!, true, TurnDirection.around, Dir.e);

  facebook[4]!.links[Dir.n] =
      Translation(facebook[2]!, true, TurnDirection.around, Dir.n);
  facebook[4]!.links[Dir.w] =
      Translation(facebook[11]!, true, TurnDirection.right, Dir.s);
  facebook[4]!.links[Dir.s] =
      Translation(facebook[10]!, true, TurnDirection.around, Dir.s);

  facebook[5]!.links[Dir.n] =
      Translation(facebook[2]!, false, TurnDirection.right, Dir.w);
  facebook[5]!.links[Dir.s] =
      Translation(facebook[10]!, true, TurnDirection.left, Dir.w);

  facebook[6]!.links[Dir.e] =
      Translation(facebook[11]!, true, TurnDirection.right, Dir.n);

  facebook[10]!.links[Dir.w] =
      Translation(facebook[5]!, true, TurnDirection.right, Dir.s);
  facebook[10]!.links[Dir.s] =
      Translation(facebook[4]!, true, TurnDirection.around, Dir.s);

  facebook[11]!.links[Dir.e] =
      Translation(facebook[2]!, true, TurnDirection.around, Dir.e);
  facebook[11]!.links[Dir.n] =
      Translation(facebook[6]!, true, TurnDirection.left, Dir.e);
  facebook[11]!.links[Dir.s] =
      Translation(facebook[4]!, true, TurnDirection.left, Dir.w);
}

void foldLarge(Map<int, Face> facebook) {
  print("folding: Large");
  facebook[1]!.links[Dir.n] =
      Translation(facebook[12]!, false, TurnDirection.right, Dir.w);
  facebook[1]!.links[Dir.w] =
      Translation(facebook[8]!, true, TurnDirection.around, Dir.w);

  facebook[2]!.links[Dir.n] =
      Translation(facebook[12]!, false, TurnDirection.none, Dir.s);
  facebook[2]!.links[Dir.e] =
      Translation(facebook[9]!, true, TurnDirection.around, Dir.e);
  facebook[2]!.links[Dir.s] =
      Translation(facebook[5]!, false, TurnDirection.right, Dir.e);

  facebook[5]!.links[Dir.w] =
      Translation(facebook[8]!, false, TurnDirection.left, Dir.n);
  facebook[5]!.links[Dir.e] =
      Translation(facebook[2]!, false, TurnDirection.left, Dir.s);

  facebook[8]!.links[Dir.w] =
      Translation(facebook[1]!, true, TurnDirection.around, Dir.w);
  facebook[8]!.links[Dir.n] =
      Translation(facebook[5]!, false, TurnDirection.right, Dir.w);

  facebook[9]!.links[Dir.e] =
      Translation(facebook[2]!, true, TurnDirection.around, Dir.e);
  facebook[9]!.links[Dir.s] =
      Translation(facebook[12]!, false, TurnDirection.right, Dir.e);

  facebook[12]!.links[Dir.w] =
      Translation(facebook[1]!, false, TurnDirection.left, Dir.n);
  facebook[12]!.links[Dir.s] =
      Translation(facebook[2]!, false, TurnDirection.none, Dir.n);
  facebook[12]!.links[Dir.e] =
      Translation(facebook[9]!, false, TurnDirection.left, Dir.s);
}

void fillNaiveLinks(List<Face> faces) {
  for (var face in faces) {
    for (var peer in faces) {
      if (peer.maxX == face.minX && face.minY == peer.minY) {
        face.naiveLinks[Dir.w] = peer;
      }
      if (peer.minX == face.maxX && face.minY == peer.minY) {
        face.naiveLinks[Dir.e] = peer;
      }
      if (peer.maxY == face.minY && face.minX == peer.minX) {
        face.naiveLinks[Dir.n] = peer;
      }
      if (peer.minY == face.maxY && face.minX == peer.minX) {
        face.naiveLinks[Dir.s] = peer;
      }
    }
  }
}

List<Face> identifyFaces(Map<Point<int>, Location> allLocations, int faceSize) {
  final List<Face> ret = [];
  for (var col = 0; col < faceSize * 4; col += faceSize) {
    for (var row = 0; row < faceSize * 4; row += faceSize) {
      final point = Point(col, row);
      if (allLocations[point] != null) {
        ret.add(Face.fromPointAndSize(point, faceSize));
      }
    }
  }
  return ret;
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
