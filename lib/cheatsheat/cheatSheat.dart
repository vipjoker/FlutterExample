
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:core';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/layout.dart';
import 'package:flame/parallax.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/material.dart';

void main() async{


  runApp( MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.amberAccent),
      child:  Center(

        child:Column(children: [
            Container(
              decoration: BoxDecoration(color: Colors.cyan),
              child: Text(
                'Hello World',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 32, color: Colors.black87),
              ),
            ),

          Text(
            'Hello World',
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: 32, color: Colors.black87),
          ),


          Spacer()
          ,

          Text(
            'Hello World',
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: 32, color: Colors.black87),
          ),


        ])





      ),
    );
    }
}