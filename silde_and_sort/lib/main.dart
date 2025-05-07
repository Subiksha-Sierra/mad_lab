import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(SlideAndSort());
}

class SlideAndSort extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle Queen',
      debugShowCheckedModeBanner: false,
      home: PuzzlePage(),
    );
  }
}

class PuzzlePage extends StatefulWidget {
  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  int gridSize = 3;
  List<int> tiles = [];
  int secondsPassed = 180;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    _stopTimer();
    secondsPassed = 180;

    int totalTiles = gridSize * gridSize;

    // Create a list of numbers from 0 to gridSize^2 - 1
    do {
      tiles = List.generate(totalTiles - 1, (index) => index + 1)..add(0);
      tiles.shuffle();
    } while (!_isSolvable(tiles));

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        secondsPassed--;
      });
      if (secondsPassed == 0) {
        _stopTimer();
        _showGameOverDialog();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  bool _isSolvable(List<int> tiles) {
    int inversions = 0;
    for (int i = 0; i < tiles.length - 1; i++) {
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[i] != 0 && tiles[j] != 0 && tiles[i] > tiles[j]) {
          inversions++;
        }
      }
    }
    int blankRow = tiles.indexOf(0) ~/ gridSize;
    return (inversions + blankRow) % 2 == 0;
  }

  bool _isAdjacent(int a, int b) {
    int rowA = a ~/ gridSize;
    int colA = a % gridSize;
    int rowB = b ~/ gridSize;
    int colB = b % gridSize;
    return (rowA == rowB && (colA - colB).abs() == 1) ||
        (colA == colB && (rowA - rowB).abs() == 1);
  }

  void _onTileTap(int index) {
    int emptyIndex = tiles.indexOf(0);
    if (_isAdjacent(index, emptyIndex)) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = 0;
      });

      if (_isCompleted()) {
        _stopTimer();
        _showWinDialog();
      }
    }
  }

  bool _isCompleted() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles[tiles.length - 1] == 0;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('You Win! 🎉'),
        content: Text('Time taken: ${_formatTime(180 - secondsPassed)}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _generatePuzzle();
              });
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Game Over 😢'),
        content: Text('Time is up! You lost!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _generatePuzzle();
              });
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double tileSize = MediaQuery.of(context).size.width / gridSize;

    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle King'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Time Left: ${_formatTime(secondsPassed)}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGridSizeButton(3),
              SizedBox(width: 10),
              _buildGridSizeButton(4),
              SizedBox(width: 10),
              _buildGridSizeButton(5),
            ],
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (context, index) {
                int value = tiles[index];
                return GestureDetector(
                  onTap: () => _onTileTap(index),
                  child: Container(
                    margin: EdgeInsets.all(4),
                    width: tileSize,
                    height: tileSize,
                    decoration: BoxDecoration(
                      color: value == 0 ? Colors.grey[300] : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        value == 0 ? '' : value.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              value == 0 ? Colors.transparent : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _generatePuzzle();
              });
            },
            icon: Icon(Icons.refresh),
            label: Text("Shuffle"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGridSizeButton(int size) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          gridSize = size;
          _generatePuzzle();
        });
      },
      child: Text('$size x $size'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: TextStyle(fontSize: 16),
      ),
    );
  }
}
