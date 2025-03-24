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

import 'SpaceShipGame.dart';
import 'ui/MyButton.dart';

void main() {
  final game = BlockGame();
  final gamewidget = GameWidget(game: game);
  const app = MaterialApp(
    debugShowCheckedModeBanner: true,
    onGenerateRoute: Routes.routes,
  );
  runApp(app);
}







class BlockGame extends FlameGame{
  @override
  FutureOr<void> onLoad() async {

    add(Background());




    final sprite = await loadSprite('game/logo.png');

    final playSprinte = await loadSprite('game/play.png');
    add(

      AlignComponent(
        child:  SpriteComponent(
          sprite: sprite,
          size: sprite.srcSize/2,
          anchor: Anchor.center,
        ),
        alignment: Anchor.topCenter,
      )


    );


  }
}

class Background extends SpriteComponent with HasGameRef<BlockGame> {
  Background();

  @override
  Future<void> onLoad() async {


    final background = await Flame.images.load("game/bg.jpg");

    size = gameRef.size;
    sprite = Sprite(background);
  }
}

enum Routes {
  main('/'),
  game('/game'),
  leaderboard('/leaderboard');

  final String route;

  const Routes(this.route);

  static MaterialPageRoute routes(RouteSettings settings) {
    MaterialPageRoute buildRoute(Widget widget) {
      return MaterialPageRoute(builder: (_) => widget, settings: settings);

    }

    final routeName = Routes.values.firstWhere((e) => e.route == settings.name);

    switch (routeName) {
      case Routes.main:
        return buildRoute(const SettingsScreen());
      case Routes.game:
        return buildRoute(const MainMenuScreen());
      // case Routes.leaderboard:
      //   return buildRoute(const LeaderboardScreen());
      default:
        throw Exception('Route does not exists');
    }
  }
}

extension BuildContextExtension on BuildContext {
  void pushAndRemoveUntil(Routes route) {
    Navigator.pushNamedAndRemoveUntil(this, route.route, (route) => false);
  }

  void push(Routes route) {
    Navigator.pushNamed(this, route.route);
  }
}



class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: AspectRatio(
          aspectRatio: 9 / 19.5,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('/game/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(builder: (context, constrains) {
                return Stack(
                  children: [
                    Positioned(
                      top:10,
                      left: 10,
                      right: 10,
                      child: Image.asset(
                        'game/logo.png',

                        width: 400,
                        scale: 1.0,
                      ),
                    ),
                    Positioned(
                      bottom: 200,
                      left: 10,
                      right: 10,
                      child: Image.asset(
                        'game/play.png',
                        scale: 1.25,
                        height: 50,



                      ),
                    ),
                    Positioned(
                      bottom: 100,
                      left: 10,
                      right: 10,
                      child: Image.asset(
                        'game/settings.png',
                        scale: 1.0,
                        height: 50,
                      ),
                    ),

                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}


class SettingsScreen extends StatelessWidget {


  const SettingsScreen(


      {
    super.key,
  });
  @override
  Widget build(BuildContext context) {


    final ButtonStyle style =
    ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return Material(
      child: Center(
        child: AspectRatio(
          aspectRatio: 9 / 19.5,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('/game/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(builder: (context, constrains) {
                return Stack(
                  children: [
                    Positioned(
                      top:10,
                      left: 10,
                      right: 10,
                      child: Image.asset(
                        'game/logo.png',

                        width: 400,
                        scale: 1.0,
                      ),
                    ),
                    Positioned(
                      bottom: 200,
                      left: 10,
                      right: 10,
                      child: Image.asset(
                        'game/play.png',
                        scale: 1.25,
                        height: 50,



                      ),
                    ),
                     Positioned(
                      bottom: 100,
                      left: 10,
                      right: 10,
                      child: ElevatedButton(

                          style: style,
                          onPressed: () {
                            context.pushAndRemoveUntil(Routes.game);

                          },
                          child: const Text('Enabled')

                      ),
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Image.asset('assets/ui/title.png'),
                        // MyText(
                        //   'Best Score: ${HighScores.highScores[0]}',
                        //   fontSize: 26,
                        // ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyButton(
                                'Play',


                                onPressed: () =>
                                    context.pushAndRemoveUntil(Routes.game),
                              ),
                              const SizedBox(height: 40),
                              MyButton('Rate',
                                onPressed: () {},
                              ),
                              const SizedBox(height: 40),
                              MyButton(
                                'Leaderboard',

                                onPressed: () =>
                                    context.push(Routes.leaderboard),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}







class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter DemoOleh',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Test '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Card(
                child: Padding(
                    padding: EdgeInsets.all(10), child: Text("SImple text")))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.ac_unit_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
