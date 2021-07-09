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
      title: 'Vula Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Vula Login Demo'),
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
  bool? _passwordVisible, showStudentNo;
  String? _studentNo;

  Map<String, String> headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Methods": "*"
  };

  @override
  void initState() {
    super.initState();
    setState(() {
      _passwordVisible = false;
      _studentNo = "";
      showStudentNo = false;
    });
  }

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
                'https://cors-with-cookies.herokuapp.com/https://vula.uct.ac.za/direct/profile/' +
                    studentNo.text +
                    '.json'),
            headers: headers);

        if (response2.statusCode == 200) {
          setState(() {
            _studentNo = jsonDecode(response2.body)["displayName"];
            showStudentNo = true;
          });
        } else {
          setState(() {
            _studentNo = "";
            showStudentNo = false;
          });
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
              child: TextFormField(
                controller: studentNo,
                decoration: InputDecoration(
                  labelText: 'Student No.',
                  hintText: 'Enter your UCT Student number',
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
              width: 300,
              height: 100,
            ),
            Container(
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: password,
                obscureText:
                    !_passwordVisible!, //This will obscure text dynamically
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  // Here is key idea
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _passwordVisible!
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        _passwordVisible = !_passwordVisible!;
                      });
                    },
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
              width: 300,
              height: 100,
            ),
            Container(
              width: 200,
              height: 60,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: TextButton(
                  onPressed: _incrementCounter,
                  child: Text(
                    "Sign in",
                    style: TextStyle(color: Colors.white),
                  )),
              decoration: BoxDecoration(color: Colors.green),
            ),
            if (showStudentNo!)
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: EdgeInsets.symmetric(vertical: 30),
                height: 130,
                child: Text(
                  _studentNo!.isNotEmpty ? _studentNo.toString() : "Error",
                  style: TextStyle(fontFamily: "Tahoma", fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              )
          ],
        ),
      ),
    );
  }
}
