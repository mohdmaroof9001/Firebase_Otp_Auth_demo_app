import 'dart:convert';
// import 'dart:js';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jobtask/home_screen.dart';
import 'package:jobtask/productdetail.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';

class ProductShow extends StatefulWidget {
  const ProductShow({Key? key}) : super(key: key);

  @override
  _ProductShowState createState() => _ProductShowState();
}

class _ProductShowState extends State<ProductShow> {
  var userData;
  late Razorpay _razorpay;

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  initRazorPay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Sucessfull");
    print(
        "${response.orderId} \n${response.paymentId} \n${response.signature}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Failed");
    print("${response.code} \n${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("Payment Failed");
  }

  launchRazorPay() async {
    int amounts = int.parse(userData["price"].toString()) * 100;
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': "$amounts",

      // 'prefill': {'contact': phone.text, 'email': email.text},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdatafromlocalstoreg();
    initRazorPay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        backgroundColor: Colors.green[600],
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              icon: Icon(Icons.person)),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Product()));
              },
              icon: Icon(Icons.upload))
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (userData != null) ...[
              SizedBox(height: 100),
              CircleAvatar(
                radius: 70,
                // backgroundColor: Colors.black,
                backgroundImage:
                    Image.network(userData["photoUrl"].toString()).image,
              ),
              SizedBox(height: 25),
              Text(
                "Product Name: ${userData["productname"]}",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                "Description: ${userData["description"]}",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                "Price: ${userData["price"]}",
                style: TextStyle(fontSize: 20),
              ),
              IconButton(
                  onPressed: () {
                    Share.share(
                        "${userData["photoUrl"]}\n ${userData["productname"]}\n ${userData["description"]}");
                  },
                  icon: Icon(
                    Icons.share,
                    color: Colors.green,
                  )),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.green[600]),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))),
                  onPressed: () {
                    launchRazorPay();
                  },
                  child: Text("Pay Now"))
            ],
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: (context) => Product()));
            //     },
            //     child: Text('Upload Product')),
          ],
        ),
      ),
    );
  }

  getdatafromlocalstoreg() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.getString("pro");
    print(data);
    DatabaseReference ref = FirebaseDatabase.instance.ref("products/$data");
    DatabaseEvent event = await ref.once();
    // print(event.snapshot.value);
    setState(() {
      var jsonresp = json.encode(event.snapshot.value);

      userData = jsonDecode(jsonresp);
      print(userData);
    });
    getdatafromlocalstoreg();
  }
}
