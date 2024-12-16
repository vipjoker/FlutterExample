import 'package:flutter/material.dart';

void main() {
  runApp(ButtonApp());
}

class ButtonApp extends StatelessWidget {
  const ButtonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme =
        ThemeData(colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true);

    var body = Scaffold(

        body: const ButtonTypesExample(),
        appBar: AppBar(leading: BackButton(onPressed: (){

        },), title:  Text('Test app')


        )


    );
    final app = MaterialApp(
        theme: theme,
        title: 'Button types',


        routes: {
          '/': (context)=>  body,
          '/settings': (context)=> Settings()

        },


    );

    return app;
  }
}



class Settings extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.blue,

           width: 100.0,
           height: 100.0,

      child: Row(children: [
        Icon(Icons.star),
        ElevatedButton(onPressed: () {


        Navigator.of(context).pop();
      }, child: Text("Back"))])
    );
  }
}
class ButtonTypesExample extends StatelessWidget {
  const ButtonTypesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child:  Container(
          color: Colors.deepOrange,
          child: Column(
            children: [
              ElevatedButton(onPressed: () {


                Navigator.of(context).pushNamed('/settings');
              }, child: Text("Elavated")),
              
              Expanded(child:
              Image.network('https://evmarts.github.io/blog//img/figs/texture-synth/balloon.jpg')),
              OutlinedButton(onPressed: () {}, child: Text("Outlined")),
              TextButton(onPressed: () {}, child: Text("Text button")),
              Container(margin: EdgeInsets.only(top: 10),child: FilledButton(onPressed: () {}, child: Text("Filled buttton"))
              )
            ],
          )),
    );
  }
}
