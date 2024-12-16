import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/material.dart';

class Bullet extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Bullet({super.position})
      : super(anchor: Anchor.center, size: Vector2(25, 50));

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
        'bullet.png',
        SpriteAnimationData.sequenced(
            amount: 1, stepTime: 1, textureSize: Vector2(8, 16)));


    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * -500;

    if (position.y < -height) {
      removeFromParent();
    }
  }
}

class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection {
  late Player player;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    final parallax = await loadParallaxComponent([
      ParallaxImageData("stars_0.png"),
      ParallaxImageData("stars_1.png"),
      ParallaxImageData("stars_2.png"),
    ],
        baseVelocity: Vector2(0, -2),
        repeat: ImageRepeat.repeat,
        velocityMultiplierDelta: Vector2(0, 4));

    add(parallax);
    player = Player();

    add(player);

    add(SpawnComponent(
        factory: (index) {
          return Enemy();
        },
        period: 1,
        area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize)));
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.global);
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.startShooting();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.stopShooting();
  }
}

class Player extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  late final SpawnComponent _bulletSpawner;

  Player() : super(size: Vector2(100, 150), anchor: Anchor.center) {}

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
        'player.png',
        SpriteAnimationData.sequenced(
            amount: 4, stepTime: .2, textureSize: Vector2(32, 48)));

    position = gameRef.size / 2;

    _bulletSpawner = SpawnComponent(
        factory: (index) {
          return Bullet(position: position + Vector2(0, -height / 2));
        },
        period: .2,
        selfPositioning: true);

    game.add(_bulletSpawner);
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  void startShooting() {
    _bulletSpawner.timer.start();
  }

  void stopShooting() {
    _bulletSpawner.timer.stop();
  }
}

class Enemy extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  Enemy({super.position})
      : super(size: Vector2.all(enemySize), anchor: Anchor.center);

  static const enemySize = 50.0;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
        'enemy.png',
        SpriteAnimationData.sequenced(
            amount: 4, stepTime: .2, textureSize: Vector2.all(16)));



    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollisionStart
    super.onCollisionStart(intersectionPoints, other);
    if(other is Bullet){
      removeFromParent();
      other.removeFromParent();
      game.add(Explosion(position: position));
    }

  }


  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

    position.y += dt * 250;

    if (position.y > game.size.y) {
      removeFromParent();
    }
  }
}

class Explosion extends SpriteAnimationComponent with HasGameReference<SpaceShooterGame>{
  Explosion({super.position}): super(size: Vector2.all(150),
      anchor: Anchor.center,removeOnFinish: true);


  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    animation = await game.loadSpriteAnimation('explosion.png',
        SpriteAnimationData.sequenced(amount: 6,
            stepTime: .1,
            textureSize: Vector2.all(32),
            loop: false));

  }

}

