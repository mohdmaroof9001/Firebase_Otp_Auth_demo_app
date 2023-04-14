import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jobtask/home_screen.dart';
import 'package:jobtask/loginpage.dart';
import 'package:jobtask/productdetail.dart';
import 'package:jobtask/productshow.dart';
import 'package:jobtask/splasscreen.dart';
import 'package:jobtask/userdatauplode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}
