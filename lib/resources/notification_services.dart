import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:instagram_clone/screens/chat_room_screen.dart';

class NotificationServices {
  final messaging = FirebaseMessaging.instance;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void RequestNotificationPermision() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permision');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user granted provisional permision');
    } else {
      print('user denied permision');
    }
  }

  void initLocalNotification(RemoteMessage message) async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {},
    );
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'Hight Importance Notification',
        importance: Importance.max);
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: 'your channel description',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker');
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    Future.delayed(Duration.zero, (() {
      flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    }));
  }

  void onForeGroundNotification() {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
      }
      initLocalNotification(message);
      showNotification(message);
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  Future<void> updateToken(String newToken) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Retrieve the reference to the 'user' document
    var userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Update the 'token' field with the new token value
    userRef.update({
      'token': newToken,
    }).then((value) {
      print('Token field successfully updated!');
    }).catchError((error) {
      print('Error updating token field: $error');
    });
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((newToken) {
      updateToken(newToken);
    });
  }

  void sendNotification(
      {required String title,
      required String body,
      required String type,
      required String to,
      required String id}) async {
    var data = {
      'to': to,
      'priority': 'high',
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {
        'type': type,
        'id': id,
      }
    };
    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAvDe5RuA:APA91bEiHRGCIAr1naWQ60uzgYPnEoW0gsbvgNfSP_DbVsZIPSHjgR0bRD0aEXLun66q0cHwtM886ks097zBRxM368IdKBXzGLd--M6wb1uum4F6Ef9E6qoTZDtTsBFXDxt_gIBkN-3j'
        });
  }
}
