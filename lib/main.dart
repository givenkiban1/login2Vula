import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Map<String, String> headers = {
    "Set-Cookie": "HttpOnly;SameSite=lax;Secure; Path=/",
    "Access-Control-Allow-Origin": "*", // Required for CORS support to work
    "Access-Control-Allow-Headers": "Origin,Content-Type,Set-Cookie",
    "Access-Control-Allow-Methods": "GET,POST"
  };

  void updateCookie(http.Response response) {
    print("Response headers: ${response.headers}");
    String rawCookie = response.headers['set-cookie'].toString();
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] = rawCookie;
//      (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
    print("Cookie is : ${headers['cookie']}");
  }

  final studentNo = TextEditingController(), password = TextEditingController();

  void _incrementCounter() async {
    var client = http.Client();

    var response = await client.post(Uri.parse(
        'https://vula.uct.ac.za/direct/session?_username=' +
            studentNo.text +
            '&_password=' +
            password.text));

    if (response.statusCode == 201) {
      print(response.body);
      print("Headers are : ${response.headers}");

      // setState(() {
      //   cookieVal = response.headers.toString();
      // });

      var response2 = await client.get(
          Uri.parse('https://vula.uct.ac.za/direct/session'),
          headers: response.headers);

      if (response2.statusCode == 200) {
        print(response2.body);
        print("Headers are : ${response2.headers}");
      } else {
        print(response2.reasonPhrase);
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  /*
    def is_active_session(self):
        r = requests.get(self.url + '/session.json', cookies=self._cookiejar)
        data = r.json()
        session = data['session_collection'][0]
        if session['active'] == True and session['userId']:
            return True
        return False
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: TextField(
                controller: studentNo,
              ),
              width: 200,
              height: 50,
            ),
            Container(
              child: TextField(
                controller: password,
              ),
              width: 200,
              height: 50,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
