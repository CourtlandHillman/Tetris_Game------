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
//====================current score=============================
  int currentScore = 0;
  //===========game over status==================================
  bool gameOver = false;

  @override
  void initState() {
    super.initState();

    //========================start game===================
    startGame();
  }

  void startGame() {
    currentPiece.initializedPiece();

    //================frame refresh========================
    Duration frameRate = const Duration(milliseconds: 400);
    gameLoop(frameRate);
  }

  //=============GAMELOOP==================================
  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        //=====================clear lines======================
        clearLines();
        //=================check landing========================
        checkLanding();

        //==================checking game status============
        if (gameOver == true) {
          timer.cancel();
          showGameOverDialog();
        }

        //====================move===============================
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  //game over message
  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("GAME OVER"),
        content: Text("Your score: $currentScore"),
        actions: [
          TextButton(
              onPressed: () {
                //reset game method================================

                resetGame();

                Navigator.pop(context);
              },
              child: Text('Play again'))
        ],
      ),
    );
  }

  //reset========================
  void resetGame() {
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(
        rowLenght,
        (j) => null,
      ),
    );

    gameOver = false;
    currentScore = 0;

    createNewPiece();
    startGame();
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

    if (isGameOver()) {
      gameOver = true;
    }
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

  //====================CLEAR LINES=====================================
  void clearLines() {
    for (int row = colLength - 1; row >= 0; row--) {
      bool rowIsFull = true;
      for (int col = 0; col < rowLenght; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }
      //checking of full row
      if (rowIsFull) {
        //move all rows above the cleared row down
        for (int r = row; r > 0; r--) {
          //copy above row to  current row
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        //set top row empty
        gameBoard[0] = List.generate(row, (index) => null);

        // increase the score
        currentScore++;
      }
    }
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

  bool isGameOver() {
    for (int col = 0; col < rowLenght; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    return false;
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
          Text(
            'Score: $currentScore',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0, top: 50.0),
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
