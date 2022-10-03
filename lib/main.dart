import 'package:flutter/material.dart';
import 'package:instagram/style.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: theme, home: MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: TextButton(
        child: Text('Hi'),
        onPressed: () {},
      ),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined), label: 'shopping_bag'),
      ]),
    );
  }
}
