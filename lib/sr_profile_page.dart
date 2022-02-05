import 'package:flutter/material.dart';
import 'package:redditech/video_items.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'globals.dart' as globals;
import 'basic_view_home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<SrInfos, String>> getSrProfile(String name) async {
  var token = globals.token;
  String text = "Join";
  final rep = await http.get(
      Uri.parse("https://oauth.reddit.com/r/$name/about"),
      headers: {'Authorization': 'Bearer $token'});

  final repi = await http.get(
      Uri.parse("https://oauth.reddit.com/subreddits/mine/subscriber"),
      headers: {'Authorization': 'Bearer $token'});

  if (rep.statusCode == 200 && repi.statusCode == 200) {
    var obj = jsonDecode(repi.body);
    for (var sr in obj['data']['children']) {
      if (sr['data']['display_name'] == name) text = "Joined";
    }
    return {SrInfos.fromJson(json.decode(rep.body)): text};
  } else {
    throw Exception("Failed to Sr infos");
  }
}

Future<http.Response> subtoSr(String name, String mode) async {
  var token = globals.token;

  final rep = await http
      .post(Uri.parse("https://oauth.reddit.com/api/subscribe/"), headers: {
    'Authorization': 'Bearer $token'
  }, body: {
    'action': '$mode',
    'sr_name': '$name',
  });

  if (rep.statusCode == 200)
    return rep;
  else
    throw Exception("Failed to sub to $name");
}

Future<BestPost> getSrBestPosts(String mode, String name) async {
  var token = globals.token;
  final rep = await http.get(
      Uri.parse("https://oauth.reddit.com/$name/$mode?limit=100"),
      headers: {'Authorization': 'Bearer $token'});

  if (rep.statusCode == 200)
    return BestPost.fromJson(json.decode(rep.body));
  else
    throw Exception("Failed to get profile");
}

class SrProfilePage extends StatefulWidget {
  const SrProfilePage({Key? key, required this.name}) : super(key: key);

  final String name;
  @override
  _SrProfilePageState createState() => _SrProfilePageState();
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    leading: BackButton(),
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

class SrInfos {
  final String bannerImage;
  final String profileImage;
  final String name;
  final int online;
  final String about;
  final int followers;

  SrInfos({
    required this.bannerImage,
    required this.profileImage,
    required this.name,
    required this.online,
    required this.followers,
    required this.about,
  });

  factory SrInfos.fromJson(Map<String, dynamic> json) {
    return SrInfos(
      bannerImage: json['data']['mobile_banner_image'],
      profileImage: json['data']['icon_img'],
      name: json['data']['display_name_prefixed'],
      online: json['data']['accounts_active'],
      followers: json['data']['subscribers'],
      about: json['data']['public_description'],
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          onPrimary: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: Text(text),
        onPressed: onClicked,
      );
}

class SrProfileWidget extends StatelessWidget {
  final String imagePath;
  final bool isEdit;
  final VoidCallback onClicked;
  final String backgroundImagePath;

  const SrProfileWidget({
    Key? key,
    required this.imagePath,
    this.isEdit = false,
    required this.onClicked,
    required this.backgroundImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {  
    return backgroundImagePath == ""
    ? Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/sky.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
        children: [
          buildImage(),
        ],
      ),
    )
    : Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(backgroundImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
        children: [
          buildImage(),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = NetworkImage(imagePath);
    final noImage = NetworkImage("https://picsum.photos/250?image=9");

    return imagePath == ""
    ? ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: noImage,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: onClicked),
        ),
      ),
    )
    : ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }
}

class _SrProfilePageState extends State<SrProfilePage> {
  late Future<Map<SrInfos, String>> sr;
  late Future<BestPost> posts;
  late String text;
  String dropdownValue = 'Hot';

  @override
  void initState() {
    super.initState();
    sr = getSrProfile(widget.name);
    posts = getSrBestPosts("hot", "r/" + widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Center(
          child: FutureBuilder<BestPost>(
              future: this.posts,
              builder: (context, posts) {
                if (posts.hasData &&
                    posts.connectionState == ConnectionState.done) {
                  return buildProfile(posts.data);
                } else if (posts.hasError) {
                  return Text(posts.error.toString());
                }
                return const CircularProgressIndicator();
              })),
    );
  }

  Widget buildProfile(var posts) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: posts.length(),
      itemBuilder: (BuildContext context, int index) =>
          srBuildPostCard(context, index, posts),
    );
  }

  Widget buildName(sr) => Container(
        child: Container(
          child: Column(
            children: [
              Text(
                sr.keys.elementAt(0).name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Text(
                      sr.keys.elementAt(0).name,
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    Icon(
                      Icons.lens_rounded,
                      size: 5,
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    Text(
                      sr.keys.elementAt(0).followers.toString() + " followers",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    Icon(
                      Icons.lens_rounded,
                      size: 5,
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    TextButton(
                        child: Text(text),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.orange[900],
                        ),
                        onPressed: () {
                          sr.values.elementAt(0) == "Join"
                              ? subtoSr(sr.keys.elementAt(0).name, "sub")
                              : subtoSr(sr.keys.elementAt(0).name, "unsub");
                          setState(() {
                            this.sr = getSrProfile(sr.keys
                                .elementAt(0)
                                .name
                                .substring(
                                    2, sr.keys.elementAt(0).name.length));
                            //true == true ?
                          });
                        }),
                    Padding(padding: EdgeInsets.only(bottom: 40)),
                  ]),
            ],
          ),
        ),
      );

  Widget profileHeader(var sr) => Column(
        children: <Widget>[
          SrProfileWidget(
            imagePath: sr.keys.elementAt(0).profileImage,
            backgroundImagePath: sr.keys.elementAt(0).bannerImage,
            onClicked: () async {},
          ),
          const SizedBox(height: 20),
          buildName(sr),
          Text(
            sr.keys.elementAt(0).about,
            style: TextStyle(
                fontSize: 16, height: 1.4, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      );

  Widget srBuildPostCard(BuildContext context, int index, var posts) {
    final post = posts.posts[index];

    return index == 0
        ? Center(
            child: FutureBuilder<Map<SrInfos, String>>(
                future: this.sr,
                builder: (context, sr) {
                  if (sr.hasData) {
                    text = sr.data!.values.elementAt(0);
                    return profileHeader(sr.data);
                  } else if (sr.hasError) {
                    print(sr.error);
                    return Text("Error");
                  }
                  return const CircularProgressIndicator();
                }),
          )
        : index == 1 ?
        Center ( 
          child :Padding(
          padding: EdgeInsets.only(top: 100, bottom: 5),
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
              if (newValue == "Hot") {
                setState(() {
                  dropdownValue = newValue!;
                  this.posts = getSrBestPosts("hot", "r/" + widget.name);
                });
              } else if (newValue == "Rising") {
                setState(() {
                  dropdownValue = newValue!;
                  this.posts = getSrBestPosts("rising", "r/" + widget.name);
                });
              } else if (newValue == "New") {
                setState(() {
                  dropdownValue = newValue!;
                  this.posts = getSrBestPosts("new", "r/" + widget.name);
                });
              } else if (newValue == "Top") {
                setState(() {
                  dropdownValue = newValue!;
                  this.posts = getSrBestPosts("top", "r/" + widget.name);
                });
              }
            },
            items: <String>['Hot', 'Rising', 'New', 'Top']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ))
        : Container(
            child: Card(
                child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: <
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
                    Text(
                      "r/" + post.sbName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        overflow: TextOverflow.fade)),
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(top: 7.0, left: 10),
                child: post.text == ""
                    ? Container()
                    : Text(post.text,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 15))),
            Padding(
                padding:
                    const EdgeInsets.only(top: 7.0, bottom: 7.0, left: 0.0),
                child:
                    post.image == "" ? Container() : Image.network(post.image)),
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
              padding: const EdgeInsets.only(top: 5.0),
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
