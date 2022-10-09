import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:instagram/notification.dart';
import 'package:instagram/style.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (c) => Store1()),
      ChangeNotifierProvider(create: (c) => Store2()),
    ], child: MaterialApp(theme: theme, home: MyApp()));
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
    initNotification(context);
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
      floatingActionButton: FloatingActionButton(
        child: Text('+'),
        onPressed: () {
          showNotification();
        },
      ),
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
              GestureDetector(
                child: Text(feeds[index]['user']),
                onTap: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => Profile(),
                          transitionsBuilder: (c, a1, a2, child) =>
                              SlideTransition(
                                position: Tween(
                                        begin: Offset(-1.0, 0.0),
                                        end: Offset(0.0, 0.0))
                                    .animate(a1),
                                child: child,
                              )));
                },
              ),
              Text('favorite ${feeds[index]['likes']}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(feeds[index]['date']),
              Text(feeds[index]['content']),
            ],
          ),
        )
      ],
    );
  }
}

class Store1 extends ChangeNotifier {
  var name = 'peter parker';
  var followerCount = 0;
  var isFollowing = false;
  var profileImages = [];

  fetchProfileImages() async {
    var response = await http
        .get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result = jsonDecode(response.body);
    profileImages = result;
    notifyListeners();
  }

  changeName(name) {
    this.name = name;
    notifyListeners();
  }

  toggleFollowingState() {
    isFollowing ? followerCount-- : followerCount++;
    isFollowing = !isFollowing;
    notifyListeners();
  }
}

class Store2 extends ChangeNotifier {
  var name = 'john smith';
}

class Profile extends StatefulWidget {
  const Profile({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    context.read<Store1>().fetchProfileImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(context.watch<Store2>().name)),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(),
            ),
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                  (c, i) =>
                      Image.network(context.watch<Store1>().profileImages[i]),
                  childCount: context.watch<Store1>().profileImages.length),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            ),
          ],
        ));
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey,
      ),
      title: Text('${context.watch<Store1>().followerCount} followers'),
      trailing: ElevatedButton(
          onPressed: () {
            context.read<Store1>().toggleFollowingState();
          },
          child: Text('Follow')),
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
