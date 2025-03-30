import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
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
      body: GameWidget<SnakeGame>(
        game: SnakeGame(),
        overlayBuilderMap: {
          'restart_button': (context, game) {
            return Center(
              child: GestureDetector(
                onTap: game.restart,
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Restart Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        },
      ),
    );
  }
}





enum Direction { up, down, left, right }

class SnakeGame extends FlameGame with KeyboardEvents {
  // Grid dimensions
  static const int columns = 20;
  static const int rows = 20;
  late double cellSize;

  // Game elements
  final List<Position> snake = [];
  Direction direction = Direction.right;
  Direction pendingDirection = Direction.right;
  late Position food;

  // Game state
  bool isGameOver = false;
  int score = 0;
  double elapsedTime = 0;
  double gameSpeed = 0.2; // seconds per move

  // Text components
  late TextComponent scoreText;
  late TextComponent gameOverText;

  @override
  Future<void> onLoad() async {
    // Calculate cell size based on screen dimensions
    cellSize = min(size.x / columns, size.y / rows);

    // Initialize the snake with 3 segments
    const initialX = columns ~/ 2;
    const initialY = rows ~/ 2;
    snake.add(Position(initialX.toDouble(), initialY.toDouble()));
    snake.add(Position((initialX - 1).toDouble(), initialY.toDouble()));
    snake.add(Position((initialX - 2).toDouble(), initialY.toDouble()));

    // Place initial food
    spawnFood();

    // Add score text
    scoreText = TextComponent(
      text: 'Score: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      position: Vector2(10, 10),
    );
    add(scoreText);

    // Create game over text (initially hidden)
    gameOverText = TextComponent(
      text: 'Game Over!\nTap to Restart',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 36.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    )..removeFromParent();







    final controlSize = min(size.x, size.y) / 5;

    final upButton = DirectionButton(
      direction: Direction.up,
      position: Vector2(size.x / 2, size.y - controlSize * 2),
      size: Vector2(controlSize, controlSize),
      game: this,
    );

    final downButton = DirectionButton(
      direction: Direction.down,
      position: Vector2(size.x / 2, size.y - controlSize / 2),
      size: Vector2(controlSize, controlSize),
      game: this,
    );

    final leftButton = DirectionButton(
      direction: Direction.left,
      position: Vector2(size.x / 2 - controlSize * 0.75, size.y - controlSize * 1.25),
      size: Vector2(controlSize, controlSize),
      game: this,
    );

    final rightButton = DirectionButton(
      direction: Direction.right,
      position: Vector2(size.x / 2 + controlSize * 0.75, size.y - controlSize * 1.25),
      size: Vector2(controlSize, controlSize),
      game: this,
    );

    add(upButton);
    add(downButton);
    add(leftButton);
    add(rightButton);


    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isGameOver) return;

    elapsedTime += dt;
    if (elapsedTime >= gameSpeed) {
      elapsedTime = 0;
      moveSnake();
    }

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // Draw grid background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.black,
    );

    // Draw snake
    for (var i = 0; i < snake.length; i++) {
      final position = snake[i];
      final color = i == 0 ? Colors.green.shade300 : Colors.green.shade600;

      canvas.drawRect(
        Rect.fromLTWH(
          position.x * cellSize,
          position.y * cellSize,
          cellSize,
          cellSize,
        ),
        Paint()..color = color,
      );
    }

    // Draw food
    canvas.drawRect(
      Rect.fromLTWH(
        food.x * cellSize,
        food.y * cellSize,
        cellSize,
        cellSize,
      ),
      Paint()..color = Colors.red,
    );

    super.render(canvas);
  }

  void moveSnake() {
    // Update direction
    direction = pendingDirection;

    // Calculate new head position
    final head = snake.first;
    late Position newHead;

    switch (direction) {
      case Direction.up:
        newHead = Position(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Position(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Position(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Position(head.x + 1, head.y);
        break;
    }

    // Check for collision with walls
    if (newHead.x < 0 || newHead.x >= columns || newHead.y < 0 || newHead.y >= rows) {
      gameOver();
      return;
    }

    // Check for collision with self
    for (final segment in snake) {
      if (newHead.x == segment.x && newHead.y == segment.y) {
        gameOver();
        return;
      }
    }

    // Add new head
    snake.insert(0, newHead);

    // Check for food
    if (newHead.x == food.x && newHead.y == food.y) {
      score++;
      scoreText.text = 'Score: $score';

      // Increase speed slightly
      if (gameSpeed > 0.05) {
        gameSpeed *= 0.95;
      }

      spawnFood();
    } else {
      // Remove tail if no food was eaten
      snake.removeLast();
    }
  }

  void spawnFood() {
    final random = Random();

    // Find a position that's not occupied by the snake
    while (true) {
      final x = random.nextInt(columns).toDouble();
      final y = random.nextInt(rows).toDouble();

      bool isOccupied = false;
      for (final segment in snake) {
        if (segment.x == x && segment.y == y) {
          isOccupied = true;
          break;
        }
      }

      if (!isOccupied) {
        food = Position(x, y);
        break;
      }
    }
  }

  void gameOver() {
    isGameOver = true;
    // add(gameOverText);

    // Enable restart by tapping
    overlays.add('restart_button');
  }

  void restart() {
    snake.clear();

    // Reset snake position
    const initialX = columns ~/ 2;
    const initialY = rows ~/ 2;
    snake.add(Position(initialX.toDouble(), initialY.toDouble()));
    snake.add(Position((initialX - 1).toDouble(), initialY.toDouble()));
    snake.add(Position((initialX - 2).toDouble(), initialY.toDouble()));

    // Reset game state
    direction = Direction.right;
    pendingDirection = Direction.right;
    spawnFood();
    score = 0;
    scoreText.text = 'Score: 0';
    gameSpeed = 0.2;
    isGameOver = false;

    // Remove game over text
    gameOverText.removeFromParent();

    // Remove restart button
    overlays.remove('restart_button');
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
      if (isGameOver) return KeyEventResult.ignored;

      if (event is KeyDownEvent) {
        if (keysPressed.contains(LogicalKeyboardKey.arrowUp) && direction != Direction.down) {
          pendingDirection = Direction.up;
        } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown) && direction != Direction.up) {
          pendingDirection = Direction.down;
        } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) && direction != Direction.right) {
          pendingDirection = Direction.left;
        } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) && direction != Direction.left) {
          pendingDirection = Direction.right;
        }
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }
  }



class Position {
  final double x;
  final double y;

  Position(this.x, this.y);
}
class DirectionButton extends PositionComponent with TapCallbacks {
  final Direction direction;
  final SnakeGame game;
  late Paint paint;
  late Paint paintPressed;
  bool isPressed = false;

  DirectionButton({
    required this.direction,
    required Vector2 position,
    required Vector2 size,
    required this.game,
  }) : super(position: position, size: size, anchor: Anchor.center) {
    paint = Paint()..color = Colors.white.withOpacity(0.3);
    paintPressed = Paint()..color = Colors.white.withOpacity(0.5);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(10),
      ),
      isPressed ? paintPressed : paint,
    );

    final labelPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    );

    String label;
    switch (direction) {
      case Direction.up:
        label = '↑';
        break;
      case Direction.down:
        label = '↓';
        break;
      case Direction.left:
        label = '←';
        break;
      case Direction.right:
        label = '→';
        break;
    }

    labelPaint.render(
      canvas,
      label,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    isPressed = true;

    // Change direction only if it's a valid move
    switch (direction) {
      case Direction.up:
        if (game.direction != Direction.down) {
          game.pendingDirection = Direction.up;
        }
        break;
      case Direction.down:
        if (game.direction != Direction.up) {
          game.pendingDirection = Direction.down;
        }
        break;
      case Direction.left:
        if (game.direction != Direction.right) {
          game.pendingDirection = Direction.left;
        }
        break;
      case Direction.right:
        if (game.direction != Direction.left) {
          game.pendingDirection = Direction.right;
        }
        break;
    }

  }

  @override
  void onTapUp(TapUpEvent even) {
    isPressed = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
  }
}