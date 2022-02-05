import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Settings> getSettings() async {
  var token = globals.token;
  final rep = await http.get(
      Uri.parse("https://oauth.reddit.com/api/v1/me/prefs"),
      headers: {'Authorization': 'Bearer $token'});

  if (rep.statusCode == 200)
    return Settings.fromJson(json.decode(rep.body));
  else
    throw Exception("Failed to get profile");
}

Future<http.Response> updateSettings(Map<String, dynamic> data) async {
  var token = globals.token;
  final rep = await http.patch(
      Uri.parse("https://oauth.reddit.com/api/v1/me/prefs"),
      body: json.encode(data),
      headers: {'Authorization': 'Bearer $token'});

  if (rep.statusCode == 200)
    return rep;
  else
    throw Exception("Failed to update settings");
}

class Settings {
  bool allowFollowYou = false;
  bool allowDirectDM = false;
  bool enableNextGen = false;
  bool persoAdsActivity = false;
  bool mailChatReq = false;
  bool mailNewUserWelcome = false;
  bool mailUpvotePost = false;
  bool mailUpvoteComment = false;
  Map<String, dynamic> json;

  Settings(
      {
      required this.allowFollowYou,
      required this.persoAdsActivity,
      required this.allowDirectDM,
      required this.enableNextGen,
      required this.mailNewUserWelcome,
      required this.mailUpvotePost,
      required this.mailUpvoteComment,
      required this.json});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
        allowFollowYou: json['enable_followers'],
        allowDirectDM: json['accept_pms'] == 'everyone' ? true : false, //
        persoAdsActivity: json['activity_relevant_ads'],
        enableNextGen: json['feed_recommendations_enabled'],
        mailNewUserWelcome: json["email_new_user_welcome"],
        mailUpvotePost: json["email_upvote_post"],
        mailUpvoteComment: json["email_upvote_comment"],
        json: json);
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    leading: BackButton(),
    backgroundColor: Colors.orange[900],
    elevation: 0,
    title: Text('Account settings', style: TextStyle(color: Colors.white)),
  );
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<Settings> settings;

  @override
  void initState() {
    super.initState();
    settings = getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Center(
        child: FutureBuilder<Settings>(
          future: settings,
          builder: (context, settings) {
            if (settings.hasData) {
              return buildSettings(settings.data);
            } else if (settings.hasError) {
              return Text("Error");
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget buildSettings(settings) => ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            Row(children: <Widget>[
              Container(height: 50, color: Colors.transparent),
              Text('  BLOCKING AND PERMISSIONS',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
            ]),
            SwitchListTile(
              secondary: Icon(Icons.people_alt_rounded),
              title: Text(
                "Allow people to follow you",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  'Followers will be notified about posts you make to your profile and see them in their home feed.',
                  style: TextStyle(color: Colors.grey)),
              value: settings.allowFollowYou,
              onChanged: (bool value) {
                setState(
                  () {
                    settings.allowFollowYou = value;
                    settings.json['enable_followers'] = value;
                    updateSettings(settings.json);
                  },
                );
              },
            ),
            SwitchListTile(
              secondary: Icon(Icons.mail_rounded),
              title: Text(
                "Allow direct messages",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  'Heads up-This setting does not apply to Reddit admins and moderators of communities you have joined.',
                  style: TextStyle(color: Colors.grey)),
              value: settings.allowDirectDM,
              onChanged: (bool value) {
                setState(
                  () {
                    settings.allowDirectDM = value;
                    settings.json['accept_pms'] = value == true ? 'everyone' : 'whitelist';
                    updateSettings(settings.json);
                  },
                );
              },
            ),
            Row(children: <Widget>[
              Container(height: 50, color: Colors.transparent),
              Text('  PERSONALIZED RECOMMENDATIONS',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
            ]),
            SwitchListTile(
              secondary: Icon(Icons.settings),
              title: Text(
                "Enable next-generation recommendations",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  'Allow us to include next-generation recommended posts in your home feed.',
                  style: TextStyle(color: Colors.grey)),
              value: settings.enableNextGen,
              onChanged: (bool value) {
                setState(
                  () {
                    settings.enableNextGen = value;
                    settings.json['feed_recommendations_enabled'] = value;
                    updateSettings(settings.json);
                  },
                );
              },
            ),
            SwitchListTile(
              secondary: Icon(Icons.settings),
              title: Text(
                "Personalize ads based on your Reddit activity",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  'Allow us to use your interations on Reddit to show you better ads.',
                  style: TextStyle(color: Colors.grey)),
              value: settings.persoAdsActivity,
              onChanged: (bool value) {
                setState(
                  () {
                    settings.persoAdsActivity = value;
                    settings.json['allow_clicktracking'] = value;
                    updateSettings(settings.json);
                  },
                );
              },
            ),
            Row(children: <Widget>[
              Container(height: 50, color: Colors.transparent),
              Text('  MANAGE EMAILS',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
            ]),
            SwitchListTile(
              secondary: Icon(Icons.notifications),
              title: Text(
                "New user Welcome",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: settings.mailNewUserWelcome,
              onChanged: (bool value) {
                setState(
                  () {
                    settings.mailNewUserWelcome = value;
                    settings.json['email_new_user_welcome'] = value;
                    updateSettings(settings.json);
                  },
                );
              },
            ),
            SwitchListTile(
              secondary: Icon(Icons.arrow_upward_rounded),
              title: Text(
                "Upvotes on your posts",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: settings.mailUpvotePost,
              onChanged: (bool value) {
                setState(
                  () {
                    settings.mailUpvotePost = value;
                    settings.json['email_upvote_post'] = value;
                    updateSettings(settings.json);
                  },
                );
              },
            ),
            SwitchListTile(
              secondary: Icon(Icons.arrow_upward_rounded),
              title: Text(
                "Upvotes on your comments",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: settings.mailUpvoteComment,
              onChanged: (bool value) {
                setState(
                  () {
                    settings.mailUpvoteComment = value;
                    settings.json['email_upvote_comment'] = value;
                    updateSettings(settings.json);
                  },
                );
              },
            ),
          ],
        ).toList(),
      );
}
