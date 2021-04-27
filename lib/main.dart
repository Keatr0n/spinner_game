import 'package:flutter/material.dart';
import 'package:spinner_game/spinnerGame.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Container(
          color: Colors.grey.shade900,
          child: Center(
            child: SpinnerGame(
              spinnerBackgroundColor: Colors.white,
              gamePrimaryColor: Colors.indigo,
              gameBackgroundColor: Colors.grey.shade900,
            ),
          ),
        ),
      ),
    );
  }
}
