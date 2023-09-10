import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris_game/piece.dart';
import 'package:tetris_game/pixel.dart';
import 'package:tetris_game/values.dart';

/*
GAME BOARD
This is 2x2 grid with null representative an empty space .
A non empty space will have the color representative the landed pieces


*/

List<List<Tetromino?>> gameBoard = List.generate(
  colLenght,
  (i) => List.generate(
    rowLength,
    (j) => null,
  ),
);

//====================game board==========================

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  //====================grid dimmenssion===================

  int rowLenght = 10;
  int colLength = 15;

  //==================current tetris piece=================
  Piece currentPiece = Piece(type: Tetromino.L);

  @override
  void initState() {
    super.initState();

    //========================start game===================
    startGame();
  }

  void startGame() {
    currentPiece.initializedPiece();

    //================frame refresh========================
    Duration frameRate = const Duration(milliseconds: 200);
    gameLoop(frameRate);
  }

  //=============GAMELOOP==================================
  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        //=================check landing========================
        checkLanding();

        //====================move===============================
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  //==============Check Collision in a future possition======
  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      //=======row and column current position formuls
      int row = (currentPiece.position[i] / rowLenght).floor();
      int col = currentPiece.position[i] % rowLenght;

      // ========adjust the row and col based on the direction

      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }
      //=========if piece out of bounds==================
      if (row >= colLength || col < 0 || col >= rowLenght) {
        return true;
      }
    }
    //============if no collision detected =================
    return false;
  }

  void checkLanding() {
    // ==========if going down is occupied or landed on other pieces
    if (checkCollision(Direction.down) || checkLanded()) {
      // =============mark position as occupied on the game board
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;

        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      //============= once landed, create the next piece
      createNewPiece();
    }
  }

  bool checkLanded() {
    //================ loop through each position of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      //================ check if the cell below is already occupied
      if (row + 1 < colLength && row >= 0 && gameBoard[row + 1][col] != null) {
        return true; // collision with a landed piece
      }
    }

    return false; //============= no collision with landed pieces
  }

  void createNewPiece() {
    //====================create random type=========================
    Random rand = Random();

    //====================create new piiece==========================

    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializedPiece();
  }

  //=============move left=============================================
  void moveLeft() {
    //==============checking empty and free space for moving piece======
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  //=============move Rotate=============================================
  void rotatePiece() {
    //==============checking empty and free space for moving piece======
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  //=============move Right=============================================
  void moveRight() {
    //==============checking empty and free space for moving piece======
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
                itemCount: rowLenght * colLength,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowLenght),
                itemBuilder: (context, index) {
                  int row = (index / rowLenght).floor();
                  int col = index % rowLenght;

                  //=============current piece================
                  if (currentPiece.position.contains(index)) {
                    return Pixel(
                      color: currentPiece.color,
                      child: index,
                    );
                  }
                  //===============landed piece=============
                  else if (gameBoard[row][col] != null) {
                    final Tetromino? tetrominoType = gameBoard[row][col];
                    return Pixel(
                      color: tetrominoColors[tetrominoType],
                      child: '',
                    );
                  }
                  //=============black piece================
                  else {
                    return Pixel(
                      color: Colors.grey[900],
                      child: index,
                    );
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //====================LEFT=============================
                IconButton(
                  onPressed: moveLeft,
                  color: Colors.white,
                  icon: Icon(
                    Icons.arrow_circle_left,
                  ),
                ),

                //=======================ROTATE=========================
                IconButton(
                  onPressed: rotatePiece,
                  color: Colors.white,
                  icon: Icon(
                    Icons.rotate_right,
                  ),
                ),

                //========================RIGHT=========================
                IconButton(
                  onPressed: moveRight,
                  color: Colors.white,
                  icon: Icon(
                    Icons.arrow_circle_right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
