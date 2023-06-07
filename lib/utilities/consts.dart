import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/screens/add_post_screen.dart';
import 'package:instagram_clone/screens/favorite_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';

import '../screens/home_screen.dart';
import '../screens/search_screen.dart';

int webScreenSize = 600;
List<Widget> kbottomBarScreens = [
  const HomeScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const FavoriteScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
