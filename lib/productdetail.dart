import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:shared_preferences/shared_preferences.dart';

class Product extends StatefulWidget {
  const Product({Key? key}) : super(key: key);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController price = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? imagePath;
  String profileUrl = '';
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
        backgroundColor: Colors.green[600],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imagePath != null) ...[
                Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey[200],
                  child: Image.file(
                    File(imagePath!),
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              SizedBox(height: 25),

              textfielddemo('Product Name', name),
              SizedBox(height: 10),
              textfielddemo('Description', description),
              SizedBox(height: 10),

              textfielddemo('Price', price),

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
              ElevatedButton(
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
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    preferences.setBool("r", true);
                    SharedPreferences preferences1 =
                        await SharedPreferences.getInstance();
                    preferences1.setString("pro", name.text);
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.green[600]),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))),
                  child: Text("Submit")),
              if (isUploading) ...[CircularProgressIndicator()]
              // textfielddemo('Product Na', name),
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
        "productname": name.text,
        "description": description.text,
        "price": price.text,
        "photoUrl": profileUrl
      };
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("products/${name.text}");

      await ref.set(userdata);
      Navigator.pop(context);
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
          hintStyle: TextStyle(color: Colors.green),
          fillColor: Colors.grey[200],
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: const BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
          hintText: text,
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
