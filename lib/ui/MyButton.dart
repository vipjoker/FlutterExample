import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';

import 'MyText.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  // late Sprite pressed;
  // late Sprite unpressed;

  const MyButton(
      this.text,
      {
        super.key,
        required this.onPressed,
      });

  @override
  Widget build(BuildContext context) {
    return SpriteButton.future(
      sprite: Future.value(Sprite.load("game/play.png")),
      pressedSprite: Future.value(Sprite.load("game/play.png")),
      onPressed: onPressed,
      height: 50,
      width: 120,
      label: MyText(
        text,
        fontSize: 26,
      ),
    );
  }
}
