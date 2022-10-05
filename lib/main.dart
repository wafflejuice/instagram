import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  var fetchedResult = [];
  var isBottomBarVisible = false;

  fetchData() async {
    var response = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));

    var result = [];
    if (response.statusCode == HttpStatus.ok) {
      result = jsonDecode(response.body);
    }

    setState(() {
      fetchedResult = result;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  setBottomBarStatus(isVisible) {
    setState(() {
      isBottomBarVisible = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Upload();
              }));
            },
          )
        ],
      ),
      body: [
        Home(feeds: fetchedResult, setBottomBarVisible: setBottomBarStatus),
        Text('Shop page')
      ][tab],
      bottomNavigationBar: SizedBox(
        child: isBottomBarVisible
            ? BottomNavigationBar(
                onTap: (i) {
                  setState(() {
                    tab = i;
                  });
                },
                items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined), label: 'home'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_bag_outlined),
                        label: 'shopping_bag'),
                  ])
            : null,
      ),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key, this.feeds, this.setBottomBarVisible}) : super(key: key);

  var feeds;
  final setBottomBarVisible;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scrollController = ScrollController();

  fetchResponse(url) async {
    var response = await http.get(Uri.parse(url));
    var result = jsonDecode(response.body);
    setState(() {
      widget.feeds.add(result);
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        fetchResponse('https://codingapple1.github.io/app/more1.json');
      }
    });
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        widget.setBottomBarVisible(false);
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.setBottomBarVisible(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: widget.feeds.length,
      itemBuilder: (context, index) {
        if (widget.feeds.isNotEmpty) {
          return Post(result: widget.feeds, index: index);
        }

        return CircularProgressIndicator();
      },
    );
  }
}

class Post extends StatelessWidget {
  const Post({Key? key, required this.result, required this.index})
      : super(key: key);

  final List result;
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

class Upload extends StatelessWidget {
  const Upload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('image upload scene'),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close))
          ],
        ));
  }
}
