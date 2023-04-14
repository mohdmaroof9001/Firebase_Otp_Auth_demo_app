import 'package:flutter/material.dart';
import 'package:jobtask/userdatauplode.dart';

class Splashscreendemo extends StatefulWidget {
  const Splashscreendemo({Key? key}) : super(key: key);

  @override
  _SplashscreendemoState createState() => _SplashscreendemoState();
}

class _SplashscreendemoState extends State<Splashscreendemo> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => UserData()));
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
