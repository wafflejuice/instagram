import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:instagram/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  var feeds = [];
  var isBottomBarVisible = false;
  var userImage;
  var userContent;

  setUserContent(userContent) {
    setState(() {
      this.userContent = userContent;
    });
  }

  pushFeed() {
    print("userContent = $userContent}");

    var newFeed = {
      "id": feeds.length,
      "image": userImage,
      "likes": 0,
      "date": "July 25",
      "content": userContent,
      "liked": false,
      "user": "Me"
    };

    setState(() {
      feeds.insert(0, newFeed);
    });
  }

  saveData() async {
    var storage = await SharedPreferences.getInstance();
    storage.setString('key', 'value');
    var data = storage.getString('key');
    print(data);
  }

  fetchData() async {
    var response = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));

    var result = [];
    if (response.statusCode == HttpStatus.ok) {
      result = jsonDecode(response.body);
    }

    setState(() {
      feeds = result;
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
            onPressed: () async {
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }

              if (!mounted) {
                return;
              }

              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Upload(
                    userImage: userImage,
                    setUserContent: setUserContent,
                    pushFeed: pushFeed);
              }));
            },
          )
        ],
      ),
      body: [
        Home(feeds: feeds, setBottomBarVisible: setBottomBarStatus),
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
          return Post(feeds: widget.feeds, index: index);
        }

        return CircularProgressIndicator();
      },
    );
  }
}

class Post extends StatelessWidget {
  Post({Key? key, required this.feeds, required this.index}) : super(key: key);

  List feeds;
  int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        feeds[index]['image'].runtimeType == String
            ? Image.network(feeds[index]['image'])
            : Image.file(feeds[index]['image']),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('favorite ${feeds[index]['likes']}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(feeds[index]['user']),
              Text(feeds[index]['content']),
            ],
          ),
        )
      ],
    );
  }
}

class Upload extends StatelessWidget {
  Upload({Key? key, this.userImage, this.setUserContent, this.pushFeed})
      : super(key: key);
  var userImage;
  final setUserContent;
  final pushFeed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(userImage),
            TextField(
              onChanged: (text) {
                setUserContent(text);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      pushFeed();
                    },
                    icon: Icon(Icons.send)),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close))
              ],
            )
          ],
        ));
  }
}
