import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<User> getUserProfile() async {
  var token = globals.token;
  final rep = await http.get(Uri.parse("https://oauth.reddit.com/api/v1/me"),
      headers: {'Authorization': 'Bearer $token'});

  if (rep.statusCode == 200)
    return User.fromJson(json.decode(rep.body));
  else
    throw Exception("Failed to get profile");
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
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

class User {
  final String imagePath;
  final String name;
  final String about;
  final int karma;
  final int followers;
  final bool isDarkMode;

  User({
    required this.imagePath,
    required this.name,
    required this.about,
    required this.isDarkMode,
    required this.karma,
    required this.followers,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        imagePath: json['subreddit']['icon_img'],
        name: json['subreddit']['display_name'],
        about: json['subreddit']['public_description'],
        isDarkMode: true,
        karma: json['total_karma'],
        followers: json['num_friends'],
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

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final bool isEdit;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    this.isEdit = false,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          buildImage(),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = NetworkImage(imagePath);

    return ClipOval(
      key: Key("ProfilePicture"),
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

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> user;

  @override
  void initState() {
    super.initState();
    user = getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Center(
        child: FutureBuilder<User>(
          future: user,
          builder: (context, user) {
            if (user.hasData) {
              return buildProfile(user.data);
            } else if (user.hasError) {
              return Text("Error");
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget buildProfile(user) => ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            key: Key("ProfileImage"),
            imagePath: user.imagePath,
            onClicked: () async {},
          ),
          const SizedBox(height: 20),
          buildName(user),
          Text(
            user.about,
            style: TextStyle(
                fontSize: 16, height: 1.4, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          /*const SizedBox(height: 20),
          Center(child: buildEditButton(user)),*/
        ],
      );

  Widget buildName(User user) => Container(
        child: Container(
          key: Key("ProfileName"),
          child: Column(
            children: [
              Text(
                user.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Text(
                      user.name,
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    Icon(
                      Icons.lens_rounded,
                      size: 5,
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    Text(
                      user.karma == 1
                          ? user.karma.toString() + " karma"
                          : user.karma.toString() + " karmas",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                     Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    Icon(
                      Icons.lens_rounded,
                      size: 5,
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    Text(
                      user.followers.toString() + " followers",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 40)),
                  ]),
            ],
          ),
        ),
      );

  Widget buildEditButton(User user) => ButtonWidget(
    key: Key("ProfileEditButton"),
    text: 'Edit Profile',
    onClicked: () {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => EditProfilePage(user: user)),
      );
    },
  );
}
