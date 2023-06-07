import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/utilities/exception.dart';

import '../responsive/mobile_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_layout.dart';
import '../utilities/colors.dart';
import '../utilities/consts.dart';
import '../utilities/utilities.dart';
import '../widgets/my_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _useNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _useNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _bioController.dispose();
  }

  void pickImage() async {
    Uint8List im = await pickImageFromGallery(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void singUp() async {
    setState(() {
      isLoading = true;
    });
    final authMedthod = AuthMedthod();
    String res = await authMedthod.signUp(
        email: _emailController.text,
        username: _useNameController.text,
        password: _passwordController.text,
        bio: _bioController.text,
        image: _image!);
    if (res == 'succes') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResponsiveLayout(
            webLayout: WebLayout(),
            mobileLayout: MobileLayout(),
          ),
        ),
      );
    } else {
      showSnackBar(context, res);
    }
    setState(() {
      isLoading = false;
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                          'https://thumbs.dreamstime.com/b/default-avatar-profile-vector-user-profile-default-avatar-profile-vector-user-profile-profile-179376714.jpg'),
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
                          MyTextField(
                            controller: _useNameController,
                            hintText: 'Enter your usename',
                          ),
                          MyTextField(
                            controller: _emailController,
                            hintText: 'Enter your email',
                          ),
                          MyTextField(
                            controller: _passwordController,
                            hintText: 'Enter your password',
                          ),
                          MyTextField(
                            controller: _bioController,
                            hintText: 'Enter your bio',
                          ),
                          GestureDetector(
                            onTap: () {
                              singUp();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                style: TextStyle(
                                  color: primaryColor,
                                ),
                                "Sign Up",
                              ),
                              color: Colors.blue,
                              width: double.infinity,
                              alignment: Alignment.center,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have account?",
                                  style: TextStyle(color: secondaryColor)),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/login');
                                  },
                                  child: Text('Log In'))
                            ],
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
