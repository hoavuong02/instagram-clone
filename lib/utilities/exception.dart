import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String res) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(res),
    duration: Duration(seconds: 3),
  ));
}
