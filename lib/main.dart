import 'package:flutter/material.dart';
import 'web_view.dart';

void main() {
  runApp(MyApp());
}

String url =
    "https://www.reddit.com/api/v1/authorize.compact?client_id=vOsCQLb69Uhu52849CcNHA&response_type=code&state=RANDOM_STRING&redirect_uri=https://127.0.0.1/&duration=temporary&scope=read,identity,account,mysubreddits,subscribe";
const MaterialColor orange = const MaterialColor(
  0xFFE65100,
  const <int, Color>{
    50: const Color(0xFFF3E0),
    100: const Color(0xFFE0B2),
    200: const Color(0xFFCC80),
    300: const Color(0xFFB74D),
    400: const Color(0xFFB74D),
    500: const Color(0xFFA726),
    600: const Color(0xFB8C00),
    700: const Color(0xF57C00),
    800: const Color(0xEF6C00),
    900: const Color(0xE65100),
  },
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redditech',
      theme: ThemeData(primarySwatch: orange),
      debugShowCheckedModeBanner: false,
      home: LoginDemo(),
    );
  }
}

class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Center(
                child: Container(
                    width: 200,
                    height: 150,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    child: Image.asset('images/logo_reddit3.png')),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: orange, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                key: Key("LoginButton"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              MyWebView(name: 'Login', url: url)));
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            SizedBox(
              height: 130,
            ),
          ],
        ),
      ),
    );
  }
}
