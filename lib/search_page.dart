import 'package:flutter/material.dart';
import 'package:redditech/sr_profile_page.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Search> getSrNames(String name) async {
  var token = globals.token;
  var rep = await http.get(
      Uri.parse("https://oauth.reddit.com/api/search_reddit_names?query=$name"),
      headers: {'Authorization': 'Bearer $token'});

  if (rep.statusCode == 200) {
    var otherrep = await http.get(
        Uri.parse("https://oauth.reddit.com/users/search?q=$name&limit=7"),
        headers: {'Authorization': 'Bearer $token'});
    if (otherrep.statusCode == 200) {
      if (otherrep.body == "\"{}\"") {
        Map<String, dynamic> test = {
          'data': {'children': []}
        };
        return Search.fromJsonSearch(json.decode(rep.body), test);
      }
      return Search.fromJsonSearch(
          json.decode(rep.body), json.decode(otherrep.body));
    } else {
      throw Exception("Failed to search users");
    }
  } else {
    throw Exception("Failed to search subreddits");
  }
}

class Search {
  final List<String> subreddits;

  Search({required this.subreddits});
  factory Search.fromJsonSearch(
      Map<String, dynamic> json, Map<String, dynamic> json2) {
    late List<String> subreddits = [];
    for (var sr in json['names']) subreddits.add("r/" + sr);
    for (var users in json2['data']['children']) {
      if (users['data']['subreddit'] != null)
        subreddits.add(users['data']['subreddit']['display_name_prefixed']);
    }
    return (Search(subreddits: subreddits));
  }
}

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<Search> search = getSrNames("hsbkjhqejkbgssjhbgeh");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: FutureBuilder<Search>(
                future: search,
                builder: (context, search) {
                  if (search.hasData) {
                    return buildsearch(search.data);
                  } else if (search.hasError) {
                    return (Text("Error"));
                  }
                  return const CircularProgressIndicator();
                })));
  }

  Widget buildsearch(_foundUsers) => Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: (value) => setState(() {
                search = getSrNames(value);
              }),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _foundUsers.subreddits.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundUsers.subreddits.length,
                      itemBuilder: (context, index) => Card(
                        color: Colors.grey[200],
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                            title: TextButton(
                          child: Text(_foundUsers.subreddits[index]),
                          onPressed: () {
                            if (_foundUsers.subreddits[index][0] == "r")
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => SrProfilePage(name: _foundUsers.subreddits[index].substring(2, _foundUsers.subreddits[index].length))),
                              );
                            print(_foundUsers.subreddits[index]);
                          },
                        )),
                      ),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      );
}
