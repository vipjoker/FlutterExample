import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';






















void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unblock Car Parking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GamePage(),
    ),
  );
}

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: GameWidget(
        game: UnblockCarGame(),
        overlayBuilderMap: {
          'level_complete': (context, game) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Level Complete!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Moves: ${(game as UnblockCarGame).moves}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        (game as UnblockCarGame).nextLevel();
                      },
                      child: const Text('Next Level'),
                    ),
                  ],
                ),
              ),
            );
          },
          'game_menu': (context, game) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Exit Game?'),
                              content: const Text('Do you want to exit the game?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // SystemNavigator.pop();
                                  },
                                  child: const Text('Exit'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    // Reset level button
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        (game as UnblockCarGame).resetLevel();
                      },
                    ),
                    // Level selector
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Select Level'),
                              content: SizedBox(
                                height: 200,
                                width: 300,
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: 3, // Number of levels
                                  itemBuilder: (context, index) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: (game as UnblockCarGame).currentLevel == index + 1
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        (game as UnblockCarGame).currentLevel = index + 1;
                                        (game as UnblockCarGame).loadLevel(index + 1);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('${index + 1}'),
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Levels'),
                    ),
                  ],
                ),
              ),
            );
          },
        },
      ),
    );
  }
}

// Represents the orientation of a car
enum CarOrientation { horizontal, vertical }

// Represents a car in the game
class Car {
  int id;
  int row;
  int col;
  int length;
  CarOrientation orientation;
  Color color;
  bool isTarget;

  Car({
    required this.id,
    required this.row,
    required this.col,
    required this.length,
    required this.orientation,
    required this.color,
    this.isTarget = false,
  });

  // Get all cells occupied by this car
  List<List<int>> getOccupiedCells() {
    final cells = <List<int>>[];

    if (orientation == CarOrientation.horizontal) {
      for (var i = 0; i < length; i++) {
        cells.add([row, col + i]);
      }
    } else {
      for (var i = 0; i < length; i++) {
        cells.add([row + i, col]);
      }
    }

    return cells;
  }
}

class UnblockCarGame extends FlameGame with TapDetector, MultiTouchDragDetector {
  // Game board size
  static const int gridSize = 6;
  static const double cellPadding = 2.0;
  late double cellSize;

  // Game state
  List<Car> cars = [];
  Car? selectedCar;
  int moves = 0;
  int currentLevel = 1;

  // For dragging
  Offset? dragStart;

  // UI elements
  late TextComponent movesText;
  late TextComponent levelText;

  @override
  Future<void> onLoad() async {
    // Calculate cell size based on screen dimensions
    cellSize = min(size.x, size.y) / gridSize;

    // Add UI components
    movesText = TextComponent(
      text: 'Moves: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(10, 10),
    );
    add(movesText);

    levelText = TextComponent(
      text: 'Level: 1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x - 100, 10),
    );
    add(levelText);

    // Load level
    loadLevel(currentLevel);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // Draw grid background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.grey.shade200,
    );

    // Draw grid lines
    final linePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.0;

    for (var i = 0; i <= gridSize; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, gridSize * cellSize),
        linePaint,
      );

      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(gridSize * cellSize, i * cellSize),
        linePaint,
      );
    }

    // Draw exit zone
    canvas.drawRect(
      Rect.fromLTWH(
        gridSize * cellSize,
        2 * cellSize,
        cellSize / 2,
        cellSize,
      ),
      Paint()..color = Colors.green.shade300,
    );

    // Draw cars
    for (final car in cars) {
      // Determine car position
      final x = car.col * cellSize;
      final y = car.row * cellSize;
      final width = car.orientation == CarOrientation.horizontal
          ? car.length * cellSize
          : cellSize;
      final height = car.orientation == CarOrientation.vertical
          ? car.length * cellSize
          : cellSize;

      // Create rounded rectangle for car
      final carRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + cellPadding,
          y + cellPadding,
          width - (cellPadding * 2),
          height - (cellPadding * 2),
        ),
        const Radius.circular(8),
      );

      // Draw car body
      canvas.drawRRect(
        carRect,
        Paint()..color = car.color,
      );

      // Draw highlight if selected
      if (selectedCar == car) {
        canvas.drawRRect(
          carRect,
          Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }

      // Draw car details (headlights, etc.) for the main/target car
      if (car.isTarget) {
        if (car.orientation == CarOrientation.horizontal) {
          // Draw headlights
          canvas.drawCircle(
            Offset(x + width - 15, y + height / 3),
            5,
            Paint()..color = Colors.yellow,
          );
          canvas.drawCircle(
            Offset(x + width - 15, y + (height / 3) * 2),
            5,
            Paint()..color = Colors.yellow,
          );

          // Draw rear lights
          canvas.drawCircle(
            Offset(x + 15, y + height / 3),
            5,
            Paint()..color = Colors.red.shade700,
          );
          canvas.drawCircle(
            Offset(x + 15, y + (height / 3) * 2),
            5,
            Paint()..color = Colors.red.shade700,
          );
        } else {
          // Draw headlights for vertical car
          canvas.drawCircle(
            Offset(x + width / 3, y + 15),
            5,
            Paint()..color = Colors.yellow,
          );
          canvas.drawCircle(
            Offset(x + (width / 3) * 2, y + 15),
            5,
            Paint()..color = Colors.yellow,
          );
        }
      }
    }

    super.render(canvas);
  }

  // Convert screen position to grid position
  List<int> screenToGrid(Offset position) {
    final row = (position.dy / cellSize).floor();
    final col = (position.dx / cellSize).floor();
    return [row, col];
  }

  // Find a car at a specific grid position
  Car? getCarAt(int row, int col) {
    for (final car in cars) {
      for (final cell in car.getOccupiedCells()) {
        if (cell[0] == row && cell[1] == col) {
          return car;
        }
      }
    }
    return null;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    final gridPos = screenToGrid(info.eventPosition.global.toOffset());
    selectedCar = getCarAt(gridPos[0], gridPos[1]);
    return false;
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {

    dragStart = info.eventPosition.global.toOffset();
    final gridPos = screenToGrid(dragStart!);
    selectedCar = getCarAt(gridPos[0], gridPos[1]);
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    if (selectedCar == null || dragStart == null) return false;

    final currentPos = info.eventPosition.global.toOffset();
    final deltaX = currentPos.dx - dragStart!.dx;
    final deltaY = currentPos.dy - dragStart!.dy;

    // Only allow movement in the car's orientation
    if (selectedCar!.orientation == CarOrientation.horizontal && deltaX.abs() > cellSize / 3) {
      final direction = deltaX > 0 ? 1 : -1;
      moveCar(selectedCar!, direction, 0);
      dragStart = currentPos;
    } else if (selectedCar!.orientation == CarOrientation.vertical && deltaY.abs() > cellSize / 3) {
      final direction = deltaY > 0 ? 1 : -1;
      moveCar(selectedCar!, 0, direction);
      dragStart = currentPos;
    }

    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    dragStart = null;
    return false;
  }

  // Check if a car can move in the specified direction
  bool canMoveCar(Car car, int deltaCol, int deltaRow) {
    if (car.orientation == CarOrientation.horizontal && deltaRow != 0) return false;
    if (car.orientation == CarOrientation.vertical && deltaCol != 0) return false;

    final newCol = car.col + deltaCol;
    final newRow = car.row + deltaRow;

    // Check bounds
    if (car.orientation == CarOrientation.horizontal) {
      if (newCol < 0 || newCol + car.length > gridSize) return false;

      // Special case for target car - allow it to exit
      if (car.isTarget && newCol + car.length == gridSize && car.row == 2) {
        return true;
      }
    } else {
      if (newRow < 0 || newRow + car.length > gridSize) return false;
    }

    // Check collision with other cars
    final newCells = <List<int>>[];
    if (car.orientation == CarOrientation.horizontal) {
      for (var i = 0; i < car.length; i++) {
        newCells.add([car.row, newCol + i]);
      }
    } else {
      for (var i = 0; i < car.length; i++) {
        newCells.add([newRow + i, car.col]);
      }
    }

    for (final otherCar in cars) {
      if (otherCar.id == car.id) continue;

      for (final cell in otherCar.getOccupiedCells()) {
        for (final newCell in newCells) {
          if (cell[0] == newCell[0] && cell[1] == newCell[1]) {
            return false;
          }
        }
      }
    }

    return true;
  }

  // Move a car in the specified direction
  void moveCar(Car car, int deltaCol, int deltaRow) {
    if (!canMoveCar(car, deltaCol, deltaRow)) return;

    // Move the car
    car.col += deltaCol;
    car.row += deltaRow;

    // Update move counter
    moves++;
    movesText.text = 'Moves: $moves';

    // Check win condition
    final targetCar = cars.firstWhere((car) => car.isTarget);
    if (targetCar.orientation == CarOrientation.horizontal &&
        targetCar.col + targetCar.length >= gridSize &&
        targetCar.row == 2) {
      levelComplete();
    }
  }

  // Handle level completion
  void levelComplete() {
    overlays.add('level_complete');
  }

  // Load the next level
  void nextLevel() {
    currentLevel++;
    loadLevel(currentLevel);
    overlays.remove('level_complete');
  }

  // Reset current level
  void resetLevel() {
    loadLevel(currentLevel);
  }

  // Load a specific level
  void loadLevel(int level) {
    cars.clear();
    moves = 0;
    movesText.text = 'Moves: 0';
    levelText.text = 'Level: $level';

    // Define different levels
    switch (level) {
      case 1:
      // Level 1 - Easy
        cars = [
          Car(
            id: 1,
            row: 2,
            col: 0,
            length: 2,
            orientation: CarOrientation.horizontal,
            color: Colors.red,
            isTarget: true,
          ),
          Car(
            id: 2,
            row: 0,
            col: 0,
            length: 2,
            orientation: CarOrientation.vertical,
            color: Colors.blue,
          ),
          Car(
            id: 3,
            row: 0,
            col: 1,
            length: 3,
            orientation: CarOrientation.horizontal,
            color: Colors.green,
          ),
          Car(
            id: 4,
            row: 1,
            col: 3,
            length: 3,
            orientation: CarOrientation.vertical,
            color: Colors.purple,
          ),
          Car(
            id: 5,
            row: 3,
            col: 1,
            length: 2,
            orientation: CarOrientation.horizontal,
            color: Colors.orange,
          ),
          Car(
            id: 6,
            row: 4,
            col: 2,
            length: 2,
            orientation: CarOrientation.vertical,
            color: Colors.teal,
          ),
        ];
        break;
      case 2:
      // Level 2 - Medium
        cars = [
          Car(
            id: 1,
            row: 2,
            col: 1,
            length: 2,
            orientation: CarOrientation.horizontal,
            color: Colors.red,
            isTarget: true,
          ),
          Car(
            id: 2,
            row: 0,
            col: 0,
            length: 3,
            orientation: CarOrientation.vertical,
            color: Colors.blue,
          ),
          Car(
            id: 3,
            row: 0,
            col: 1,
            length: 2,
            orientation: CarOrientation.horizontal,
            color: Colors.green,
          ),
          Car(
            id: 4,
            row: 1,
            col: 1,
            length: 1,
            orientation: CarOrientation.vertical,
            color: Colors.purple,
          ),
          Car(
            id: 5,
            row: 3,
            col: 2,
            length: 3,
            orientation: CarOrientation.horizontal,
            color: Colors.orange,
          ),
          Car(
            id: 6,
            row: 4,
            col: 0,
            length: 2,
            orientation: CarOrientation.vertical,
            color: Colors.teal,
          ),
          Car(
            id: 7,
            row: 3,
            col: 0,
            length: 2,
            orientation: CarOrientation.vertical,
            color: Colors.pink,
          ),
          Car(
            id: 8,
            row: 4,
            col: 3,
            length: 2,
            orientation: CarOrientation.horizontal,
            color: Colors.amber,
          ),
        ];
        break;
      case 3:
      // Level 3 - Hard
        cars = [
          Car(
            id: 1,
            row: 2,
            col: 0,
            length: 2,
            orientation: CarOrientation.horizontal,
            color: Colors.red,
            isTarget: true,
          ),
          Car(
            id: 2,
            row: 0,
            col: 0,
            length: 2,
            orientation: CarOrientation.horizontal,
            color: Colors.blue,
          ),
          Car(
            id: 3,
            row: 0,
            col: 2,
            length: 3,
            orientation: CarOrientation.vertical,
            color: Colors.green,
          ),
          Car(
            id: 4,
            row: 0,
            col: 3,
            length: 2,
            orientation: CarOrientation.vertical,
            color: Colors.purple,
          ),
          Car(
            id: 5,
            row: 0,
            col: 4,
            length: 2,
            orientation: CarOrientation.horizontal,
            color: Colors.orange,
          ),
          Car(
            id: 6,
            row: 1,
            col: 0,
            length: 2,
            orientation: CarOrientation.vertical,
            color: Colors.teal,
          ),
          Car(
            id: 7,
            row: 1,
            col: 1,
            length: 2,
            orientation: CarOrientation.horizontal,
            color: Colors.pink,
          ),
          Car(
            id: 8,
            row: 3,
            col: 0,
            length: 3,
            orientation: CarOrientation.horizontal,
            color: Colors.amber,
          ),
          Car(
            id: 9,
            row: 3,
            col: 3,
            length: 3,
            orientation: CarOrientation.vertical,
            color: Colors.indigo,
          ),
          Car(
            id: 10,
            row: 4,
            col: 4,
            length: 2,
            orientation: CarOrientation.horizontal,
            color: Colors.brown,
          ),
        ];
        break;
      default:
      // Loop back to level 1 if we run out of levels
        currentLevel = 1;
        loadLevel(currentLevel);
        break;
    }
  }
}