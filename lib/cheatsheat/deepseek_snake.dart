import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget(game: SnakeGame()),
      ),
    );
  }
}

class SnakeGame extends FlameGame with KeyboardEvents {
  final int gridSize = 20;
  late double cellSize;
  List<Vector2> snakeSegments = [];
  Vector2 direction = Vector2(1, 0);
  Vector2 foodPosition = Vector2.zero();
  int score = 0;
  double stepTime = 0.15;
  double timeSinceLastMove = 0;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    resetGame();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    cellSize = (size.x / gridSize).floorToDouble();
    if (cellSize * gridSize > size.y) {
      cellSize = (size.y / gridSize).floorToDouble();
    }
  }

  void resetGame() {
    snakeSegments = [Vector2(10, 10)];
    direction = Vector2(1, 0);
    score = 0;
    generateFood();
  }

  void generateFood() {
    do {
      foodPosition = Vector2(
        random.nextInt(gridSize).toDouble(),
        random.nextInt(gridSize).toDouble(),
      );
    } while (snakeSegments.contains(foodPosition));
  }

  void moveSnake() {
    final newHead = snakeSegments.first + direction;

    // Collision detection
    if (newHead.x < 0 || newHead.x >= gridSize ||
        newHead.y < 0 || newHead.y >= gridSize ||
        snakeSegments.contains(newHead)) {
      resetGame();
      return;
    }

    snakeSegments.insert(0, newHead);

    if (newHead == foodPosition) {
      score++;
      generateFood();
    } else {
      snakeSegments.removeLast();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    timeSinceLastMove += dt;
    if (timeSinceLastMove >= stepTime) {
      timeSinceLastMove = 0;
      moveSnake();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw snake
    final snakePaint = Paint()..color = Colors.green;
    for (final segment in snakeSegments) {
      canvas.drawRect(
        Rect.fromLTWH(
          segment.x * cellSize,
          segment.y * cellSize,
          cellSize - 1,
          cellSize - 1,
        ),
        snakePaint,
      );
    }

    // Draw food
    final foodPaint = Paint()..color = Colors.red;
    canvas.drawCircle(
      Offset(
        foodPosition.x * cellSize + cellSize / 2,
        foodPosition.y * cellSize + cellSize / 2,
      ),
      cellSize / 2 - 1,
      foodPaint,
    );

    // Draw score
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Score: $score',
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 10));
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {
    if (event is KeyDownEvent) {
      final newDirection = _getDirectionFromKey(event.logicalKey);
      if (newDirection != null && direction.dot(newDirection) != -1) {
        direction = newDirection;
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Vector2? _getDirectionFromKey(LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.arrowUp:
        return Vector2(0, -1);
      case LogicalKeyboardKey.arrowDown:
        return Vector2(0, 1);
      case LogicalKeyboardKey.arrowLeft:
        return Vector2(-1, 0);
      case LogicalKeyboardKey.arrowRight:
        return Vector2(1, 0);
      default:
        return null;
    }
  }
}