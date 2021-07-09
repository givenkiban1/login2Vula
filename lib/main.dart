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
        primarySwatch: Colors.green,
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

  final studentNo = TextEditingController(), password = TextEditingController();

  Map<String, String> headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Methods": "*"
  };

  void updateCookie(http.Response response) {
    print("Response headers: ${response.headers}");
    print(response.headers['given'].toString());

    String rawCookie = response.headers['given'].toString();
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['Gift'] = rawCookie;
      //(index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
    print("Cookie is : ${headers['Gift']}");
  }

  void _incrementCounter() async {
    try {
      var response = await http.post(
          Uri.parse(
              'https://cors-with-cookies.herokuapp.com/https://vula.uct.ac.za/direct/session?_username=' +
                  studentNo.text +
                  '&_password=' +
                  password.text),
          headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Methods": "*",
          });

      if (response.statusCode == 201) {
        print(response.body);
        print("Headers are : ${response.headers}");
        updateCookie(response);
        print("2nd request");

        var response2 = await http.get(
            Uri.parse(
                'https://cors-with-cookies.herokuapp.com/https://vula.uct.ac.za/direct/profile' +
                    studentNo.text +
                    '.json'),
            headers: headers);

        if (response2.statusCode == 200) {
          print(jsonDecode(response2.body));
        } else {
          print(response2.statusCode);
          print(response2.reasonPhrase);
        }
      }
    } catch (e) {
      print("An error has occured bof");
      print(e);
    }
  }

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
