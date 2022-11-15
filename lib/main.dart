import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Game(),
    );
  }
}

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  static const int rowSize = 15;
  static const int colSize = 30;
  static const int numberOfSquares = rowSize * colSize;

  List<int> snake = [37, 52, 67, 82, 97];
  int food = Random().nextInt(numberOfSquares ~/ 2) + numberOfSquares ~/ 2;
  int score = 0;

  String direction = 'down';
  bool paused = true;
  bool gameStarted = false;

  void startGame() {
    gameStarted = true;
    const duration = Duration(milliseconds: 200);

    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (gameIsOver()) {
        timer.cancel();
        gameOver();
      }
    });
  }

  void resumeGame() {
    paused = false;
    if (!gameStarted) {
      startGame();
    }
  }

  bool gameIsOver() {
    if (snake.sublist(0, snake.length - 2).contains(snake.last)) return true;
    return false;
  }

  void gameOver() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: ((BuildContext context) {
          return AlertDialog(
            title: const Text('Game Over!'),
            content: Text('Score: $score'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetGame();
                },
                child: const Text('Close'),
              )
            ],
          );
        }));
  }

  void resetGame() {
    snake = [37, 52, 67, 82, 97];
    food = Random().nextInt(numberOfSquares ~/ 2) + numberOfSquares ~/ 2;
    score = 0;

    direction = 'down';
    paused = true;
    gameStarted = false;

    setState(() {});
  }

  void updateSnake() {
    setState(() {
      if (paused) return;

      switch (direction) {
        case 'up':
          if (snake.last < rowSize) {
            snake.add(snake.last + numberOfSquares - rowSize);
          } else {
            snake.add(snake.last - rowSize);
          }
          break;
        case 'down':
          if (snake.last >= numberOfSquares - rowSize) {
            snake.add(snake.last - numberOfSquares + rowSize);
          } else {
            snake.add(snake.last + rowSize);
          }
          break;
        case 'right':
          if ((snake.last + 1) % rowSize == 0) {
            snake.add(snake.last - rowSize + 1);
          } else {
            snake.add(snake.last + 1);
          }
          break;
        case 'left':
          if (snake.last % rowSize == 0) {
            snake.add(snake.last + rowSize - 1);
          } else {
            snake.add(snake.last - 1);
          }
          break;
        default:
      }

      if (snake.last == food) {
        score++;
        spawnFood();
      } else {
        snake.removeAt(0);
      }
    });
  }

  void spawnFood() {
    do {
      food = Random().nextInt(numberOfSquares);
    } while (snake.contains(food));
  }

  EdgeInsets getMargin(int pos) {
    int i = snake.indexOf(pos);
    double top = 1;
    double bot = 1;
    double left = 1;
    double right = 1;

    int prev = (i == 0 ? pos : snake.elementAt(i - 1));
    int next = (i == snake.length - 1 ? pos : snake.elementAt(i + 1));

    if (prev == pos - 1 || next == pos - 1) {
      // left
      left = 0;
    }
    if (prev == pos + 1 || next == pos + 1) {
      // right
      right = 0;
    }
    if (prev == pos + rowSize || next == pos + rowSize) {
      // down
      bot = 0;
    }
    if (prev == pos - rowSize || next == pos - rowSize) {
      // up
      top = 0;
    }
    return EdgeInsets.only(bottom: bot, top: top, left: left, right: right);
  }

  BorderRadius getBorderRadius(int pos) {
    int i = snake.indexOf(pos);
    double topRight = 0;
    double topLeft = 0;
    double botRight = 0;
    double botLeft = 0;

    if (pos == snake.elementAt(0) || pos == snake.elementAt(snake.length - 1)) {
      // if head or tail
      int prev = (i == 0 ? pos : snake.elementAt(i - 1));
      int next = (i == snake.length - 1 ? pos : snake.elementAt(i + 1));

      if (prev == pos - 1 || next == pos - 1) {
        // left
        botRight = topRight = 4;
      }
      if (prev == pos + 1 || next == pos + 1) {
        // right
        botLeft = topLeft = 4;
      }
      if (prev == pos + rowSize || next == pos + rowSize) {
        // down
        topLeft = topRight = 4;
      }
      if (prev == pos - rowSize || next == pos - rowSize) {
        // up
        botLeft = botRight = 4;
      }
    }

    return BorderRadius.only(
        topRight: Radius.circular(topRight),
        topLeft: Radius.circular(topLeft),
        bottomRight: Radius.circular(botRight),
        bottomLeft: Radius.circular(botLeft));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 90, 227, 110),
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(20)),
          Expanded(
              child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (direction != 'up' && details.delta.dy > 0) {
                direction = 'down';
              } else if (direction != 'down' && details.delta.dy < 0) {
                direction = 'up';
              }
            },
            onHorizontalDragUpdate: (details) {
              if (direction != 'right' && details.delta.dx < 0) {
                direction = 'left';
              } else if (direction != 'left' && details.delta.dx > 0) {
                direction = 'right';
              }
            },
            child: AspectRatio(
              aspectRatio: rowSize / (colSize + 4),
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowSize),
                  itemCount: numberOfSquares,
                  itemBuilder: ((context, index) {
                    var color = Color.fromARGB(90, 173, 235, 200);
                    bool isSnake = false;
                    if (snake.last == index) {
                      /* check's head */
                      isSnake = true;
                      color = Color.fromARGB(255, 173, 161, 243);
                    } else if (snake.contains(index)) {
                      /* check's body*/
                      isSnake = true;
                      color = Colors.lightBlue;
                    } else if (food == index) {
                      /* check's food */
                      color = Color.fromARGB(255, 213, 1, 44);
                    }

                    return Container(
                      margin: (isSnake
                          ? getMargin(index)
                          : const EdgeInsets.all(1)),
                      child: ClipRRect(
                        borderRadius: isSnake
                            ? getBorderRadius(index)
                            : BorderRadius.circular(4),
                        child: Container(color: color),
                      ),
                    );
                  })),
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                    onPressed: (() {
                      if (paused) {
                        resumeGame();
                      } else {
                        paused = true;
                      }
                    }),
                    style: TextButton.styleFrom(
                        backgroundColor: paused
                            ? Colors.lightBlue
                            : Color.fromARGB(255, 213, 1, 44),
                        minimumSize: const Size(90, 40)),
                    child: Text(
                      paused ? 'Start' : 'Pause',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    )),
                Text('Score: $score',
                    style: const TextStyle(color: Colors.white, fontSize: 18))
              ],
            ),
          )
        ],
      ),
    );
  }
}