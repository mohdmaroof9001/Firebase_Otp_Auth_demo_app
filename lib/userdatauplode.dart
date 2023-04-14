import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UserData extends StatefulWidget {
  const UserData({Key? key}) : super(key: key);

  @override
  _UserDataState createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController mobileno = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();

  Position? currentPosition;
  String? currentAddress;
  bool isloading = false;
  final ImagePicker _picker = ImagePicker();
  String? imagePath;
  String profileUrl = '';

  bool isUploading = false;

  Future<Position> getPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('location not Available');
      }
    } else {
      print("Location not Fined");
    }
    return await Geolocator.getCurrentPosition();
  }

  void getAddress(latitude, longitude) async {
    try {
      List<Placemark> placemark = await GeocodingPlatform.instance
          .placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemark[0];
      setState(() {
        currentAddress =
            '${place.subLocality}, ${place.locality}, ${place.street}, ${place.postalCode}, ${place.country}';
        address.text = currentAddress!;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Your Profile"),
        backgroundColor: Colors.green[600],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 15),

              textfielddemo('First Name', firstname),
              SizedBox(height: 5),
              textfielddemo('Last Name', lastname),
              SizedBox(height: 5),

              textfielddemo('Mobile No', mobileno),
              SizedBox(height: 5),

              textfielddemo('Email Id', email),
              SizedBox(height: 5),

              Container(
                width: 250,
                height: 60,
                child: TextField(
                  controller: address,
                  // controller: controller
                  decoration: InputDecoration(
                    hintText: 'Address',
                    fillColor: Colors.grey[200],
                    filled: true,
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
                height: 5,
              ),
              isloading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isloading = true;
                        });
                        currentPosition = await getPosition();
                        getAddress(currentPosition!.latitude,
                            currentPosition!.longitude);
                        setState(() {
                          isloading = false;
                        });
                      },
                      child: Text(
                        'Get Location',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.transparent, elevation: 0)),

              // Container(
              //   child: ,
              // ),
              if (imagePath != null) ...[
                Image.file(
                  File(imagePath!),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ],
              SizedBox(height: 10),
              Text(
                "Choose Your Profile Photo",
                style: TextStyle(color: Colors.grey[500]),
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        selectImage(ImageSource.gallery);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Text(
                        "Gallery",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      )),
                  SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        selectImage(ImageSource.camera);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Text(
                        "Camera",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isUploading = true;
                      });
                      bool a = await uploadImageFile();
                      if (a) {
                        await uplodeuserdata();
                      } else {
                        setState(() {
                          isUploading = false;
                        });
                        print('some error occured');
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green[600]),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))),
                    child: Text("Submit")),
              ),
              if (isUploading) ...[CircularProgressIndicator()]
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> uploadImageFile() async {
    try {
      final fileName = imagePath!.split("/").last;
      File file = File(imagePath!);
      final ref = firebase_storage.FirebaseStorage.instance
          .ref('userphoto')
          .child(fileName);
      firebase_storage.UploadTask a = ref.putFile(file);

      final b = await a.whenComplete(() {});

      final urlDownload = await b.ref.getDownloadURL();
      profileUrl = urlDownload;
      return true;
    } catch (e) {
      return false;
      print(e);
    }
  }

  Future<void> uplodeuserdata() async {
    try {
      Map<String, dynamic> userdata = {
        "lastname": lastname.text,
        "firstname": firstname.text,
        "mobileno": mobileno.text,
        "email": email.text,
        "address": address.text,
        "photoUrl": profileUrl
      };
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("users/${mobileno.text}");

      await ref.set(userdata);
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  textfielddemo(String text, TextEditingController controller) {
    return Container(
      width: 250,
      height: 60,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: text,
          fillColor: Colors.grey[200],
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: const BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
        ),
      ),
    );
  }

  selectImage(ImageSource src) async {
    final XFile? image = await _picker.pickImage(source: src);
    if (image != null) {
      print("Path ${image.path}");
      setState(() {
        imagePath = image.path;
      });
    }
  }
}
