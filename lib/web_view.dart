import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'globals.dart' as globals;
import 'home_page.dart';
import 'package:http/http.dart' as http;

class MyWebView extends StatefulWidget {
  const MyWebView({Key? key, required this.name, required this.url})
      : super(key: key);

  final String name;
  final String url;

  @override
  State<MyWebView> createState() => _WebViewState();
}

class _WebViewState extends State<MyWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key("WebView"),
      appBar: AppBar(
        title: const Text('WebView'),
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        navigationDelegate: (action) async {
          if (action.url.startsWith("https://127.0.0.1/")) {
            Uri url = Uri.parse(action.url);
            var code = url.queryParameters['code']!;
            var rep = await http.post(
                Uri.parse("https://www.reddit.com/api/v1/access_token"),
                headers: {
                  'Authorization': 'Basic ' +
                      base64Encode(utf8.encode(
                          "vOsCQLb69Uhu52849CcNHA:R84NH_0JaNTR6Vt49gZUPFXJwMRR6w")),
                },
                encoding: Encoding.getByName('utf-8'),
                body: <String, String>{
                  'grant_type': 'authorization_code',
                  'code': code,
                  'redirect_uri': 'https://127.0.0.1/'
                });
            if (rep.statusCode != 200) throw Exception("Failed to get token");
            globals.token = json.decode(rep.body)['access_token'];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        MyHomePage(title: "Reddit")));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
