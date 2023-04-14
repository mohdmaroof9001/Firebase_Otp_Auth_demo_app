// import 'dart:html';

// import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jobtask/home_screen.dart';
import 'package:jobtask/productshow.dart';
import 'package:jobtask/userdatauplode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController number = TextEditingController();
  TextEditingController otp = TextEditingController();

  late Future<FirebaseApp> _firebaseapp;
  bool isLogedin = false;
  late String uid;
  bool otpsent = false;
  late String _verification;

  String verificationId = '';
  String smsCode = '';

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseapp = Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    // String text, bool isNumerical,

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Sign In",
          style: TextStyle(fontSize: 25),
        )),
        backgroundColor: Colors.green[600],
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          // color: Colors.black,
          child: show()),
    );
  }

  Widget show() {
    return FutureBuilder(
      future: _firebaseapp,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator();
        return isLogedin
            ? Center(
                child: Text("user id $uid"),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 180,
                    ),
                    textfieldDemo('Enter Your 10 Digit Phone No', true, number),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Enter your 6 digit otp',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 200,
                      height: 50,
                      child: TextField(
                        controller: otp,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(50.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 300,
                      height: 35,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green[600]),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ))),
                        onPressed: () async {
                          PhoneAuthCredential phoneAuthCredential =
                              PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: otp.text.toString());
                          signInWithPhoneAuthCredential(phoneAuthCredential);
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          preferences.setBool("r", true);
                          SharedPreferences preferences1 =
                              await SharedPreferences.getInstance();
                          preferences.setString("number", number.text);
                        },
                        child: Text("Login"),
                      ),
                    ),
                    SizedBox(
                      height: 170,
                    ),
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserData()));
                        },
                        child: Text(
                          "SIGN UP NOW",
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
              );
      },
    );
  }

  textfieldDemo(String text, bool isNumerical, TextEditingController a) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 350,
        height: 50,
        child: TextField(
          controller: a,
          keyboardType: isNumerical ? TextInputType.number : null,
          decoration: InputDecoration(
            hintText: text,
            hintStyle: TextStyle(color: Colors.green),
            fillColor: Colors.grey[200],
            filled: true,

            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: const BorderRadius.all(
                Radius.circular(50.0),
              ),
            ),
            suffixIcon: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: '+91 ${number.text}',
                    verificationCompleted: (phoneAuthCredential) {
                      // PhoneAuthCredential phoneAuthCredential = phoneAuthCredential.
                    },
                    verificationFailed: (error) {
                      print(error);
                    },
                    codeSent: (verificationId, [forceResendingToken]) {
                      this.verificationId = verificationId;
                      ScaffoldMessenger.maybeOf(context)!
                          .showSnackBar(SnackBar(content: Text("sms sent")));
                    },
                    codeAutoRetrievalTimeout: (verificationId) {
                      print('time out maroof');
                    },
                  );
                },
                child: Text(
                  "Send Otp",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0,
                )),

            // suffixText: 'Send',
            // prefixText: '(+91)   ',
            // prefixStyle: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    final authCredential =
        await _auth.signInWithCredential(phoneAuthCredential);

    if (authCredential.user != null) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => ProductShow()));
    }
  }
}
