import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum BlockType { empty, fixed, movable }

class BlockPuzzleGame2 extends Flame with TickerProviderStateMixin {
  // Game settings
  static const double blockSize = 40.0;
  static const int gridWidth = 8;
  static const int gridHeight = 8;

  // Block types

  // Game state
  List<List<BlockType>> grid = [];
  Vector2 playerPos = Vector2(0, 0);

  // Random number generator
  Random random = Random();

  // Constructor
  BlockPuzzleGame2() {
    // Initialize the grid with random blocks
    for (int i = 0; i < gridHeight; i++) {
      grid.add(List.filled(gridWidth, BlockType.empty));
      for (int j = 0; j < gridWidth; j++) {
        if (random.nextDouble() < 0.2) {
          grid[i][j] = BlockType.fixed;
        }
      }
    }

    // Add a movable block as the player
    grid[1][1] = BlockType.movable;
  }

  @override
  void onKey(KeyData data) {
    // Handle movement
    if (data.isPressed) {
      Vector2 newPos = playerPos;

      if (data.key == Key.arrowUp) {
        newPos.y -= 1;
      } else if (data.key == Key.arrowDown) {
        newPos.y += 1;
      } else if (data.key == Key.arrowLeft) {
        newPos.x -= 1;
      } else if (data.key == Key.arrowRight) {
        newPos.x += 1;
      }

      // Check if the new position is valid
      if (isValidMove(newPos)) {
        // Move the player with animation
        animateMove(newPos);
      }
    }
  }

  // Check if a move is valid
  bool isValidMove(Vector2 pos) {
    // Check boundaries
    if (pos.x < 0 || pos.x >= gridWidth || pos.y < 0 || pos.y >= gridHeight) {
      return false;
    }

    // Check if the target position is empty
    if (grid[pos.toInt().y][pos.toInt().x] != BlockType.empty) {
      return false;
    }

    return true;
  }

  // Animate the movement
  Future animateMove(Vector2 targetPos) async {
    // Create an animation controller
    AnimationController controller = AnimationController.unbounded(
      duration: Duration(milliseconds: 300),
    );

    // Create a tween for the position
    Animation<Vector2> animation = Tween<Vector2>(
      begin: playerPos,
      end: targetPos,
    ).animate(controller);

    // Add listeners to update the player position
    animation.addListener((value) {
      playerPos = value;
    });

    // Start the animation
    controller.forward();

    // When the animation is complete, update the grid
    await controller.future;

    // Update the grid with the new position
    grid[playerPos.toInt().y][playerPos.toInt().x] = BlockType.empty;
    grid[targetPos.toInt().y][targetPos.toInt().x] = BlockType.movable;
  }

  @override
  Widget buildView(Size size) {
    // Create a grid of blocks
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridWidth,
      ),
      itemCount: gridWidth * gridHeight,
      itemBuilder: (context, index) {
        int row = index ~/ gridWidth;
        int col = index % gridWidth;

        // Determine the color based on the block type
        Color color = Colors.white;
        if (grid[row][col] == BlockType.fixed) {
          color = Colors.grey;
        } else if (grid[row][col] == BlockType.movable) {
          color = Colors.blue;
        }

        return Container(
          width: blockSize,
          height: blockSize,
          color: color,
          child: Center(
            child: Text(
              '$row, $col',
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      },
    );
  }
}
