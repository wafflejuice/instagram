import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            appBarTheme: AppBarTheme(
              color: Colors.white,
              titleTextStyle: TextStyle(color: Colors.black),
              actionsIconTheme: IconThemeData(color: Colors.black),
            ),
            textTheme: TextTheme(bodyText2: TextStyle(color: Colors.red))),
        home: MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Instagram',
          style: TextStyle(fontSize: 20),
        ),
        actions: [Icon(Icons.add_box_outlined, size: 40,)],
      ),
    );
  }
}
