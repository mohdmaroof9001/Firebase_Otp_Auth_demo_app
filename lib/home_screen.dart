import 'dart:convert';
// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:jobtask/productdetail.dart';
import 'package:jobtask/userdatauplode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List<String> userData = [];
  var userData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdatafromlocalstoreg();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Profile',
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: Colors.green[600],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
            ),
            // Container(
            //   width: 150,
            //   height: 150,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     // color: Colors.blue,
            //   ),
            //   child: Image.network(
            //     userData["photoUrl"]!.toString(),
            //     fit: BoxFit.cover,
            //   ),
            // ),
            if (userData != null) ...[
              userData["photoUrl"].toString().isEmpty
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : CircleAvatar(
                      radius: 70,
                      // backgroundColor: Colors.black,
                      backgroundImage:
                          Image.network(userData["photoUrl"].toString()).image,
                    ),
              SizedBox(height: 15),
              Text(
                "Name: ${userData["firstname"]} ${userData["lastname"]}",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                "Mobile No: ${userData["mobileno"]}",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                "Email: ${userData["email"]}",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                "Address: ${userData["address"]}",
                style: TextStyle(fontSize: 20),
              ),
            ],

            SizedBox(height: 180),

            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: (context) => Product()));
            //     },
            //
            //   child: Text('Upload Product')),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserData()));
                },
                child: Text(
                  'SIGN UP NOW',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ))
          ],
        ),
      ),
    );
  }

  getdatafromlocalstoreg() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.getString("number");
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$data");
    DatabaseEvent event = await ref.once();
    // print(event.snapshot.value);
    setState(() {
      var jsonresp = json.encode(event.snapshot.value);

      userData = jsonDecode(jsonresp);
    });
    // print(userData["email"]);

    // data1 = data as List<String>;
    // print(data);

    // if (data != null) {

    // }
    getdatafromlocalstoreg();
  }
}
