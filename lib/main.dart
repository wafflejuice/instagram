import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var fetchedResult;

  fetchData() async {
    var response = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    var result = jsonDecode(response.body);
    setState(() {
      fetchedResult = result;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

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
      body: [Home(result: fetchedResult), Text('Shop page')][tab],
      bottomNavigationBar: BottomNavigationBar(
          onTap: (i) {
            setState(() {
              tab = i;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined), label: 'shopping_bag'),
          ]),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key, this.result}) : super(key: key);

  final result;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: result.length,
      itemBuilder: (context, index) {
        return Post(result: result, index: index);
      },
    );
  }
}

class Post extends StatelessWidget {
  const Post({Key? key, this.result, required this.index}) : super(key: key);

  final result;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(result[index]['image']),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('favorite ${result[index]['likes']}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(result[index]['user']),
              Text(result[index]['content']),
            ],
          ),
        )
      ],
    );
  }
}
