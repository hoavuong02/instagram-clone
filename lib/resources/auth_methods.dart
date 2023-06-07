import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/models/user.dart' as modelUser;
import '../utilities/utilities.dart';
import 'notification_services.dart';

class AuthMedthod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<modelUser.User> getUserDetail() async {
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    return modelUser.User.fromSnap(snap);
  }

  Future<String> signUp({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List image,
  }) async {
    String res = '';
    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        bio.isEmpty ||
        image.isEmpty) {
      res = 'Enter all the field';
      return res;
    }
    if (email.isNotEmpty ||
        password.isNotEmpty ||
        username.isNotEmpty ||
        bio.isNotEmpty) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String photoUrl = await uploadImage(image, 'images', false);
        final user = modelUser.User(
          username: username,
          email: email,
          bio: bio,
          uid: userCredential.user!.uid,
          followers: [],
          following: [],
          photoUrl: photoUrl,
        );
        _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toJson());

        // get toKen and add to db

        NotificationServices().getDeviceToken().then(
              (value) => _firestore
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .update({'token': value}),
            );
        // User registration successful, you can navigate to another screen or do something else
        res = 'succes';
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          res = ('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          res = ('The account already exists for that email.');
        } else if (e.code == 'invalid-email') {
          res = ('Invalid email format.');
        } else {
          res = ('Signup failed. Error: ${e.message}');
        }
      } catch (e) {
        // Display an error message to the user
        res = ('Error occurred during sign up: $e');
      }
    }
    return res;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String res = 'An error have occurred';
    if (email.isEmpty || password.isEmpty) {
      // Display an error message to the user
      return res = 'Enter your email or password';
    }

    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Login successful, navigate to home screen or perform any other desired action
      await NotificationServices()
          .updateToken(await NotificationServices().getDeviceToken());
      res = 'Login successful';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found with that email.';
      } else if (e.code == 'wrong-password') {
        res = 'Wrong password provided.';
      } else {
        res = 'Login failed. Error: ${e.message}';
      }
    } catch (e) {
      // Display an error message to the user
      res = ('Error occurred during login: $e');
    }
    return res;
  }

  Future<void> logout() async {
    await NotificationServices().updateToken('');
    await FirebaseAuth.instance.signOut();
  }

  Future<String> updateProfile(
    String username,
    String bio,
    Uint8List? image,
  ) async {
    String res = '';
    if (username.isEmpty || bio.isEmpty) {
      res = 'Enter all the field';
      return res;
    }
    if (username.isNotEmpty || bio.isNotEmpty) {
      try {
        if (image != null) {
          String photoUrl = await uploadImage(image, 'images', false);
          _firestore.collection('users').doc(_auth.currentUser!.uid).set({
            'username': username,
            'bio': bio,
            'photoUrl': photoUrl,
          });
        }

        _firestore.collection('users').doc(_auth.currentUser!.uid).update({
          'username': username,
          'bio': bio,
        });

        // User registration successful, you can navigate to another screen or do something else
        res = 'succes';
      } catch (e) {
        // Display an error message to the user
        res = ('Error occurred during sign up: $e');
      }
    }
    return res;
  }
}
