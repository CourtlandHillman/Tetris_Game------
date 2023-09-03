import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  int rowLength = 10;
  int colLenght = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:GridView.builder(
        itemCount: rowLength*colLenght,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rowLength), 
          itemBuilder: (context , index) => Center(
            child: Text(
              index.toString(),
              style: TextStyle(color: Colors.white),
              ) ,
            ),
           ) ,
    );
  }
}
