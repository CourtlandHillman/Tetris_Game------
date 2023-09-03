import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tetris_game/piece.dart';
import 'package:tetris_game/values.dart';

import 'pixel.dart';

class GameBoard extends StatefulWidget {
  GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //current tetris piece
  Piece currentPiece = Piece(type: Tetromino.T);

  @override
  void initState() {
    super.initState();

    //start game
    startGame();
  }

  void startGame() {
    currentPiece.initializedPiece();
    //frame refresh rate\

    Duration frameRate = const Duration(milliseconds: 800);
    gameLoop(frameRate);
  }

  //gameloop

  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        //move piece down'
        currentPiece.movePiece(Direction.down);
      });
    });
  }
  //collision detection 
 bool checkCollision(Direction direction){

    for (int i = 0; i < currentPiece.position.length; i++) {
      
    }
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GridView.builder(
        itemCount: rowLength * colLenght,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: rowLength),
        itemBuilder: (context, index) {
          if (currentPiece.position.contains(index)) {
            return Pixel(
              color: Colors.yellow,
              child: index,
            );
          } else {
            return Pixel(
              color: Colors.grey[900],
              child: index,
            );
          }
        },
      ),
    );
  }
}
