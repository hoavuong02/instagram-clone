import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utilities/exception.dart';

import '../responsive/mobile_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_layout.dart';
import '../utilities/colors.dart';
import '../utilities/consts.dart';
import '../utilities/utilities.dart';
import '../widgets/my_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  final userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _useNameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _useNameController.dispose();
    _bioController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _useNameController =
        TextEditingController(text: widget.userData['username']);
    _bioController = TextEditingController(text: widget.userData['bio']);
  }

  void pickImage() async {
    Uint8List im = await pickImageFromGallery(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: SvgPicture.asset(
                    'assets/ic_instagram.svg',
                    width: 60,
                    height: 60,
                    color: primaryColor,
                  ),
                ),
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              _image != null
                                  ? CircleAvatar(
                                      radius: 64,
                                      backgroundImage: MemoryImage(_image!),
                                    )
                                  : CircleAvatar(
                                      radius: 64,
                                      backgroundImage: NetworkImage(
                                          widget.userData['photoUrl']),
                                    ),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: SizedBox(
                                    child: IconButton(
                                      color: Colors.blue,
                                      icon: Icon(Icons.add_a_photo),
                                      onPressed: () {
                                        pickImage();
                                      },
                                    ),
                                  ))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyTextField(
                            controller: _useNameController,
                            hintText: 'Enter your usename',
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MyTextField(
                            controller: _bioController,
                            hintText: 'Enter your bio',
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              String res = await AuthMedthod().updateProfile(
                                  _useNameController.text,
                                  _bioController.text,
                                  _image);
                              showSnackBar(context, res);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid),
                                  ));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                style: TextStyle(
                                  color: primaryColor,
                                ),
                                "Save",
                              ),
                              color: Colors.blue,
                              width: double.infinity,
                              alignment: Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
