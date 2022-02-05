import 'package:flutter/material.dart';
import 'package:redditech/settings_page.dart';
import 'carousel_page.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'basic_view_home_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PageController _pageController = PageController();
  List<Widget> _screens = [
    BasicViewHomePage(type: "best"),
    SearchPage(),
    CarouselPage(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int selectedIndex) {
    _pageController.jumpToPage(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Redditech'),
        leading: IconButton(
          key: Key("DrawerButton"),
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(), //New
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Divider(
                    color: Colors.white,
                    height: 50,
                  ),
                  DrawerHeader(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/boy_reddit3.png"),
                            fit: BoxFit.cover)),
                    child: Text(""),
                  ),
                  ListTile(
                    key: Key("MyProfileButton"),
                    leading: Icon(Icons.account_box),
                    title: const Text('My Profile'),
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                  /*ListTile(
                    key: Key("CreateCommunityButton"),
                    leading: Icon(Icons.fiber_new_outlined),
                    title: const Text('Create a community'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    key: Key("SavedButton"),
                    leading: Icon(Icons.bookmark),
                    title: const Text('Saved'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    key: Key("HistoryButton"),
                    leading: Icon(Icons.history),
                    title: const Text('History'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),*/
                ],
              ),
            ),
            // This container holds the align
            Container(
                // This align moves the children to the bottom
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    // This container holds all the children that will be aligned
                    // on the bottom and should not scroll with the above ListView
                    child: Container(
                        child: Column(
                      children: <Widget>[
                        Divider(),
                        ListTile(
                            leading: Icon(Icons.settings),
                            title: Text('Settings'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => SettingsPage()),
                              );
                            }),
                      ],
                    ))))
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        selectedIconTheme: IconThemeData(size: 40),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Search',
            icon: Icon(Icons.search),
          ),
          /*BottomNavigationBarItem(
            label: 'New',
            icon: Icon(Icons.add_sharp),
          ),*/
          BottomNavigationBarItem(
            label: 'How it Works',
            icon: Icon(Icons.quiz_outlined),
          ),
        ],
        currentIndex: _selectedIndex, //New
        onTap: _onItemTapped,
      ),
    );
  }
}
