import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/utilities/consts.dart';
import 'package:instagram_clone/utilities/exception.dart';

import '../models/user.dart';
import '../responsive/mobile_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_layout.dart';
import '../utilities/colors.dart';
import '../widgets/my_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool isLoading = false;

  void login(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final authMethod = AuthMedthod();
    String res = await authMethod.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (res == 'Login successful') {
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
              : const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: SvgPicture.asset(
                        'assets/ic_instagram.svg',
                        width: 60,
                        height: 60,
                        color: primaryColor,
                      ),
                    ),
                    MyTextField(
                      controller: _emailController,
                      hintText: 'Phone number, usename or email',
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Color(0xFF555555),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                              print(_obscureText);
                            });
                          },
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                    ),
                  ),
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            login(context);
                          },
                          child: const Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              style: TextStyle(color: primaryColor),
                              "Log In",
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.blue,
                            ),
                          ),
                        ),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.facebook,
                          color: Colors.lightBlue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Log In With Facebook',
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      'OR',
                      style: TextStyle(color: secondaryColor),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have account?",
                          style: TextStyle(color: secondaryColor)),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signUp');
                          },
                          child: Text('Sign Up'))
                    ],
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
