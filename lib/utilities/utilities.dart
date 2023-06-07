import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImageFromGallery(ImageSource source) async {
  final picker = ImagePicker();

  // Pick an image from the gallery
  XFile? pickedFile = await picker.pickImage(source: source);

  if (pickedFile != null) {
    return await pickedFile.readAsBytes();
  }
  print("No image selected");
}

Future<String> uploadImage(Uint8List image, String folder, bool isPost) async {
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  DateTime currentTime = DateTime.now();

  String formattedTime =
      '${currentTime.hour}_${currentTime.minute}_${currentTime.second}';
  Reference ref =
      _storage.ref().child(folder).child('${_auth.currentUser!.uid}');
  if (isPost == true) {
    ref = ref.child('${_auth.currentUser!.uid}_$formattedTime');
  }

  UploadTask uploadTask = ref.putData(image);
  TaskSnapshot storageSnapshot = await uploadTask;
  String downloadUrl = await storageSnapshot.ref.getDownloadURL();

  return downloadUrl;
}
