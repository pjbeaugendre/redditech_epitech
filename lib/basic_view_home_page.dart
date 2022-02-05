import 'dart:async';

import 'package:flutter/material.dart';
import 'package:redditech/video_items.dart';
import 'package:video_player/video_player.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sr_profile_page.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

Future<BestPost> getBestPosts(String mode, int count, String after) async {
  var token = globals.token;
  final rep = await http.get(
      Uri.parse(
          "https://oauth.reddit.com/$mode?limit=25&count=$count&after=$after"),
      headers: {'Authorization': 'Bearer $token'});

  if (rep.statusCode == 200) {
    return BestPost.fromJson(json.decode(rep.body));
  } else
    throw Exception("Failed to get posts");
}

class Post {
  final sbName;
  final sbImagePath;
  final usernamePoster;
  final timePosted;
  final title;
  final nbUpDown;
  final nbComments;
  final String text;
  final String image;
  final String video;
  final String link;
  //final String picture;

  Post({
    required this.sbName,
    this.sbImagePath,
    required this.usernamePoster,
    required this.timePosted,
    required this.title,
    required this.nbUpDown,
    required this.nbComments,
    this.text = "",
    this.image = "",
    this.video = "",
    this.link = "",
    //this.picture,
  });
}

class BestPost {
  final List<Post> posts;
  final after;

  BestPost({
    required this.posts,
    required this.after,
  });

  int length() {
    return (posts.length.toInt());
  }

  factory BestPost.fromJson(Map<String, dynamic> json) {
    List<Post> bests = [];
    for (var post in json['data']['children']) {
      bests.add(Post(
          sbName: post['data']['subreddit'],
          sbImagePath: post['data']['thumbnail'],
          usernamePoster: post['data']['author'],
          timePosted: DateFormat('yyyy-MM-dd – kk:mm').format(
              DateTime.fromMillisecondsSinceEpoch(
                  post['data']['created'].toInt() * 1000)),
          title: post['data']['title'],
          nbUpDown: post['data']['score'],
          nbComments: post['data']['num_comments'],
          text: post['data']['selftext'],
          image: post['data']['url'] != null
              ? post['data']['url'].startsWith("https://i.redd.it/")
                  ? post['data']['url']
                  : ""
              : "",
          video: post['data']['is_video'] == true
              ? post['data']['media']['reddit_video']['fallback_url'] : "",
          link: post['data']['url'] == null
              ? ""
              : post['data']['url'].startsWith("https://i.redd.it/")
                  ? ""
                  : post['data']['is_true'] == true
                      ? ""
                      : post['data']['url']
                              .startsWith("https://www.reddit.com/")
                          ? ""
                          : post['data']['url']));
    }
    return BestPost(posts: bests, after: json['data']['after']);
  }
}

class BasicViewHomePage extends StatefulWidget {
  BasicViewHomePage({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  State<BasicViewHomePage> createState() => _BasicViewHomePageState(type: type);
}

class _BasicViewHomePageState extends State<BasicViewHomePage> {
  _BasicViewHomePageState({required this.type});
  final String type;
  late ScrollController _controller;
  var postsController = StreamController<BestPost>();
  var offset = 25;
  var after = "";

  String dropdownValue = 'best';
  int condition = 0;

  // Attend d'atteindre le bas
  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        if (this.after != "stop")
          getBestPosts(dropdownValue, offset, after)
              .then((newposts) => this.postsController.add(newposts));
          offset += 25;
      });
    }
    // if (_controller.offset <= _controller.position.minScrollExtent &&
    //     !_controller.position.outOfRange) {
    //   setState(() {
    //     ;
    //   });
    // }
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    getBestPosts(dropdownValue, 0, "")
        .then((newposts) => postsController.add(newposts));
  }

  @override
  void dispose() {
    super.dispose();
    postsController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: StreamBuilder<BestPost>(
      stream: postsController.stream,
      builder: (context, posts) {
        if (posts.hasData) {
          if (posts.data!.after != null)
            this.after = posts.data!.after;
          else
            this.after = "stop";
          return buildPosts(posts.data!);
        } else if (posts.hasError) {
          return Text(posts.error.toString());
        }
        return const CircularProgressIndicator();
      },
    ));
  }

  Widget buildPosts(BestPost posts) => Container(
      color: Colors.grey[300],
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 20,
            elevation: 10,
            style: const TextStyle(color: Colors.black),
            underline: Container(
              height: 2,
              color: Colors.orange,
            ),
            onChanged: (String? newValue) {
              if (newValue == "best") {
                setState(() {
                  dropdownValue = newValue!;
                  getBestPosts(dropdownValue, 0, '')
                      .then((newposts) => postsController.add(newposts));
                });
              } else if (newValue == "hot") {
                setState(() {
                  dropdownValue = newValue!;
                  getBestPosts(dropdownValue, 0, '')
                      .then((newposts) => postsController.add(newposts));
                });
              } else if (newValue == "new") {
                setState(() {
                  dropdownValue = newValue!;
                  getBestPosts(dropdownValue, 0, '')
                      .then((newposts) => postsController.add(newposts));
                });
              } else if (newValue == "top") {
                setState(() {
                  dropdownValue = newValue!;
                  getBestPosts(dropdownValue, 0, '')
                      .then((newposts) => postsController.add(newposts));
                });
              }
            },
            items: <String>['best', 'hot', 'new', 'top']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _controller,
            primary: false,
            itemCount: posts.posts.length,
            itemBuilder: (BuildContext context, int index) =>
                buildPostCard(context, index, posts),
          ),
        ),
      ]));

  Widget buildPostCard(BuildContext context, int index, BestPost posts) {
    final post = posts.posts[index];
    return Container(
        child: Card(
            child: Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <
            Widget>[
          Padding(padding: EdgeInsets.only(left: 10)),
          Container(
              width: 50,
              height: 50,
              child: Image.asset("images/logo_reddit.png"),
              decoration: BoxDecoration(shape: BoxShape.circle)),
          Padding(padding: EdgeInsets.only(left: 18)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextButton(
                  child: Text(
                    "r/" + post.sbName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  onPressed: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SrProfilePage(name: post.sbName),
                    ));
                  }),
              Row(
                children: <Widget>[
                  Text(
                    "u/" + post.usernamePoster,
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                  Icon(
                    Icons.lens_rounded,
                    size: 5,
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                  Text(
                    post.timePosted,
                  )
                ],
              )
            ],
          ),
        ]),
      ),
      Padding(padding: EdgeInsets.only(top: 5)),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 10)),
          Flexible(
              child: Text(post.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  overflow: TextOverflow.fade)),
        ],
      ),
      Padding(
          padding: const EdgeInsets.only(top: 7.0, left: 10),
          child: post.text == ""
              ? Container()
              : Text(post.text,
                  style: TextStyle(color: Colors.grey[600], fontSize: 15))),
      Padding(
          padding: const EdgeInsets.only(top: 7.0, bottom: 7.0, left: 0.0),
          child: post.image == "" ? Container() : Image.network(post.image)),
      Padding(
        padding: const EdgeInsets.only(top: 5.0, left: 0.0),
        child: post.link == ""
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 5.0, left: 10),
                child: InkWell(
                    child: Text(
                        post
                            .link, //.substring(post.link.indexOf("//") + 2, 20),
                        style: TextStyle(
                            color: Colors.yellow[800],
                            decoration: TextDecoration.underline)),
                    onTap: () => launch(post.link))),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: post.video == ""
            ? Container()
            : Container(
                child: VideoItems(
                  videoPlayerController:
                      VideoPlayerController.network(post.video),
                  looping: false,
                  autoplay: true,
                ),
              ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 4, left: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(children: [
              Icon(Icons.arrow_upward_rounded),
              Text(
                post.nbUpDown.toString(),
              ),
              Icon(Icons.arrow_downward_rounded),
            ]),
            Padding(padding: EdgeInsets.only(left: 60)),
            Row(children: [
              Text(post.nbComments.toString()),
              Padding(padding: EdgeInsets.only(left: 5)),
              Icon(Icons.mode_comment_outlined),
            ]),
          ],
        ),
      ),
    ])));
  }
}
