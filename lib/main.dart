import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
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
  bool? _passwordVisible,
      showStudentNo,
      increaseSpace1,
      increaseSpace2,
      isLoading;
  String? _studentNo;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
      increaseSpace1 = false;
      increaseSpace2 = false;
      isLoading = false;
    });
  }

  //this function receives an http response and takes the cookie variable, given
  //and stores it as gift in headers map variable above

  void updateCookie(http.Response response) {
    String rawCookie = response.headers['given'].toString();
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['Gift'] = rawCookie;
    }
  }

  //this is the function that is called when a user clicks- login
  void _incrementCounter() async {
    //try catch is used to catch any unexpected errors, such as cors, or anything else we don't anticipate.
    try {
      //the first request that is made is a post request, to attempt a login to vula
      //using the credentials user has entered via textinputs
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

      //if the response code==201, this means login is successful
      if (response.statusCode == 201) {
        //update cookie is called
        updateCookie(response);

        //the 2nd http request is called, to get profile information of the user who's just signed in
        var response2 = await http.get(
            Uri.parse(
                'https://cors-with-cookies.herokuapp.com/https://vula.uct.ac.za/direct/profile/' +
                    studentNo.text +
                    '.json'),
            headers: headers);

        //if the response code==200, this means the request was successful and the data we asked for is returned
        if (response2.statusCode == 200) {
          //we update the state variables with the display name of signed in user
          setState(() {
            _studentNo = jsonDecode(response2.body)["displayName"];
            showStudentNo = true;
            isLoading = false;
          });
        } else {
          //we we're not able to get the data, strange
          setState(() {
            _studentNo = "server error.";
            showStudentNo = false;
            isLoading = false;
          });
        }
      } else
      //when response code==403 or 401, this either means forbidden or unauthorized. this could either be
      //that credentials are wrong, or we're trying to access data we don't have access to
      if (response.statusCode == 403 || response.statusCode == 401) {
        setState(() {
          _studentNo = "Incorrect Credentials";
          showStudentNo = true;
          isLoading = false;
        });
      } else {
        setState(() {
          _studentNo = "something is down.";
          showStudentNo = true;
          isLoading = false;
        });
      }
    } catch (e) {
      //our response to unexpected error caught
//      print("An error has occured bof");
      //print(e);
      setState(() {
        _studentNo = "service is down.";
        showStudentNo = true;
        isLoading = false;
      });
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
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    child: TextFormField(
                      controller: studentNo,
                      validator: (value) {
                        if (value!.isEmpty) {
                          setState(() {
                            increaseSpace1 = true;
                          });
                          return "Student no. is required.";
                        } else {
                          setState(() {
                            increaseSpace1 = false;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Student No.',
                        hintText: 'Enter your UCT Student number',
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    width: 300,
                    height: increaseSpace1! ? 150 : 100,
                  ),
                  Container(
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: password,
                      validator: (value) {
                        if (value!.isEmpty) {
                          setState(() {
                            increaseSpace2 = true;
                          });
                          return "Password is required.";
                        } else {
                          setState(() {
                            increaseSpace2 = false;
                          });
                        }
                      },
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
                    height: increaseSpace2! ? 150 : 100,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Container(
                width: 200,
                height: 60,
                child: TextButton(
                    onPressed: () {
                      FormState form = formKey.currentState!;
                      form.save();
                      if (form.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        _incrementCounter();
                      }
                    },
                    child: Text("Sign in",
                        style: TextStyle(color: Colors.white, fontSize: 20))),
                decoration: BoxDecoration(color: Colors.green),
              ),
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
            else if (isLoading!)
              Container(
                width: 100,
                height: 50,
                child: Center(
                    child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotate,
                  color: Colors.green,
                )),
              )
          ],
        ),
      ),
    );
  }
}
