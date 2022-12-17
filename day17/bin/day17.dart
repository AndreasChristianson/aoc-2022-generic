import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:day17/day17.dart';

final dot = Piece([
  Point(0, 0),
], 1, 1,[1]);
final allPieces = [
  Piece([
    //flat
    Point(0, 0),
    Point(1, 0),
    Point(2, 0),
    Point(3, 0),
  ], 4, 1, [1,1,1,1]),
  Piece([
    //cross
    Point(1, 0),
    Point(1, 1),
    Point(1, 2),
    Point(0, 1),
    Point(2, 1),
  ], 3, 3,[2,3,2]),
  Piece([
    //L
    Point(0, 0),
    Point(1, 0),
    Point(2, 0),
    Point(2, 1),
    Point(2, 2),
  ], 3, 3,[1,1,3]),
  Piece([
    //tall
    Point(0, 0),
    Point(0, 1),
    Point(0, 2),
    Point(0, 3),
  ], 1, 4,[4]),
  Piece([
    //square
    Point(0, 0),
    Point(1, 0),
    Point(0, 1),
    Point(1, 1),
  ], 2, 2,[2,2]),
];

void main() async {
  final file = File('input.txt');
  final text = await file
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .where((s) => s.isNotEmpty)
      .first;

  final gustProducer = Producer(text.split(""));
  print(gustProducer.list);

  final pieceProducer = Producer(allPieces);
  final Pit pit = Pit();
  var pieceCount = 0;
  var piece = pieceProducer.get().from();
  piece.pos = Point(2, pit.tallest + 3);
  final hashes = {};

  while (pieceCount < 4000) {
  // while (pieceCount < 2022) {
    // for (var i = 0; i < 100; i++) {
    final gust = gustProducer.get();
    // print("gust: $gust");
    pit.gust(gust, piece);
    // print("post gust: $piece");
    final fell = pit.fall(piece);
    // print("post fall: $piece");
    if (!fell) {
      // print("stuck!");
      pieceCount++;
      final hash = "${pit.relHeights.join(",")}|${pieceProducer.index%pieceProducer.list.length}|${gustProducer.index%gustProducer.list.length}";
      if(hashes.containsKey(hash)){
        // print("cycle. current height: ${pit.tallest}, last height: ${hashes[hash]}, diff: ${pit.tallest-hashes[hash]}");
        print("cycle. current piece: ${pieceCount}, last piece: ${hashes[hash]}, diff: ${pieceCount-hashes[hash]}");
        
        // print(hash);
        // print(pit);
      }
      hashes[hash] = pieceCount;
      // hashes[hash] = pit.tallest;
      piece = pieceProducer.get().from();
      piece.pos = Point(2, pit.tallest + 3);
      // print(hash);
      // print(pit);
      if(pieceCount%1000000 == 0){
        print(pieceCount);
      }
      if(pieceCount<4000){
        print("${pieceCount}: ${pit.tallest}");
      }
    }
  }
  // print(pit);
  print(pit.tallest);
}

class Piece {
  List<Point<int>> filled;
  Point<int> pos = Point(0, 0);
  int width;
  int height;
  List<int> topHeights;
  Piece(this.filled, this.width, this.height, this.topHeights);
  Piece.withPos(this.filled, this.pos, this.width, this.height, this.topHeights);
  @override
  String toString() {
    return "Piece@(${pos.x},${pos.y}): [${filled.join(", ")}]";
  }

  Piece from() {
    return Piece.withPos(filled, pos, width, height,topHeights);
  }

  bool collides(Piece other) {
    if (pos.squaredDistanceTo(other.pos) > 25) {
      return false;
    }
    for (var myPoint in filled) {
      for (var theirPoint in other.filled) {
        if ((myPoint.x + pos.x == theirPoint.x + other.pos.x) &&
            (myPoint.y + pos.y == theirPoint.y + other.pos.y)) {
          return true;
        }
      }
    }
    return false;
  }
}

class Pit {
  int width = 7;
  Queue<Piece> pieces = Queue();
  int tallest = 0;
  List<int> relHeights = List.filled(7,0);

  gust(String direction, Piece piece) {
    if (direction == "<") {
      //left
      if (piece.pos.x > 0) {
        tryMove(piece, -1, 0);
      } else {
        // print("bump left wall");
      }
    } else {
      if (piece.pos.x + piece.width < 7) {
        tryMove(piece, 1, 0);
      } else {
        // print("bump right wall");
      }
    }
  }

  bool fall(Piece piece) {
    if (piece.pos.y > 0 && tryMove(piece, 0, -1)) {
      return true;
    }
stickLikeGlue(piece);
    return false;
  }

  bool tryMove(Piece piece, int deltaX, int deltaY) {
    // print("try move: ($deltaX,$deltaY)");
    final oldPos = piece.pos;
    piece.pos = Point(piece.pos.x + deltaX, piece.pos.y + deltaY);
    if (piece.pos.y > tallest + 1) {
      return true;
    }
    if (anyCollide(piece)) {
      piece.pos = oldPos;
      return false;
    }
    return true;
  }

  @override
  String toString() {
    var output = "Tallest: $tallest\n  ";
    for (var width = 0; width < 7; width++) {
      output = "$output${ relHeights[width].abs() % 10}";
    }
    output = "$output\n";
    for (var height = tallest; height >= max(tallest-20,0); height--) {
      output = "$output${height % 10}|";
      for (var width = 0; width < 7; width++) {
        dot.pos = Point(width, height);
        if (anyCollide(dot)) {
          output = "$output#";
        } else {
          output = "$output ";
        }
      }
      output = "${output}|\n";
    }
    output = "$output +-------+\n";
    return output;
  }

  bool anyCollide(Piece other) {
    for (var stuck in pieces) {
      if (stuck.collides(other)) {
        return true;
      }
    }
    return false;
  }
  
  void stickLikeGlue(Piece piece) {
        pieces.addFirst(piece);
    if(pieces.length>40){
      pieces.removeLast();
    }
    // tallest = max(piece.height + piece.pos.y, tallest);
    for (var i = 0; i < 7; i++) {
      if(piece.pos.x<=i&&piece.width+piece.pos.x>i){
        // print(i-piece.pos.x)
        if(tallest+relHeights[i]<piece.topHeights[i-piece.pos.x]+piece.pos.y){
          relHeights[i] = piece.topHeights[i-piece.pos.x]+piece.pos.y- tallest;
        }
        
      }
    }
    if(tallest<piece.height + piece.pos.y){
      final delta =piece.height + piece.pos.y-tallest;
      for (var i = 0; i < 7; i++) {
      relHeights[i]-=delta;
    }
      tallest = piece.height + piece.pos.y;
    }
  }
  
}
