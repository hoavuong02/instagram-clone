import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/models/chat_message.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/utilities/exception.dart';
import 'package:uuid/uuid.dart';
import '../utilities/utilities.dart';

class FireStoreMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserDataByUid(String uid, String userData) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      final userdata = data[userData] as String;
      return userdata;
    }

    return '';
  }

  Future<Post> getPostDetail() async {
    DocumentSnapshot snap =
        await _firestore.collection('posts').doc(_auth.currentUser!.uid).get();
    return Post.fromSnap(snap);
  }

  Future<String> addPost({
    required String caption,
    required Uint8List image,
    required String uid,
  }) async {
    String res = '';
    if (caption.isEmpty) {
      res = 'Enter caption';
      return res;
    }
    if (caption.isNotEmpty) {
      try {
        String photoUrl = await uploadImage(image, 'posts', true);
        String postId = Uuid().v1();
        final post = Post(
          caption: caption,
          uid: uid,
          photoUrl: photoUrl,
          postId: postId,
          datePublished: DateTime.now(),
          likes: [],
          marked: [],
        );
        await _firestore.collection('posts').doc(postId).set(post.toJson());
        res = 'Post added successfully';
      } catch (e) {
        // Display an error message to the user
        res = ('Error occurred during add post: $e');
      }
    }
    return res;
  }

  Future<void> toggleLikePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid) == false) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> commentPost(String postId, String uid, String comment) async {
    try {
      if (comment.isNotEmpty) {
        String commentId = Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'uid': uid,
          'comment': comment,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          "likes": [],
        });
      } else {
        print('comment is empty');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> toggleLikeComment(
      String postId, String uid, List likes, String commentId) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> follow(String currentUid, String uid, List followers) async {
    try {
      if (followers.contains(currentUid) == false) {
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayUnion([currentUid]),
        });

        await _firestore.collection('users').doc(currentUid).update({
          'following': FieldValue.arrayUnion([uid]),
        });
      } else {
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayRemove([currentUid]),
        });

        await _firestore.collection('users').doc(currentUid).update({
          'following': FieldValue.arrayRemove([uid]),
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> favoritePost(
      String currentUid, String postId, List marked) async {
    try {
      if (marked.contains(currentUid) == false) {
        await _firestore.collection('posts').doc(postId).update({
          'marked': FieldValue.arrayUnion([currentUid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'marked': FieldValue.arrayRemove([currentUid]),
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> createChatRoom({
    required String idMember1,
    required String idMember2,
  }) async {
    String chatRoomId = const Uuid().v1();
    await _firestore.collection('chats').doc(chatRoomId).set({
      'chatRoomId': chatRoomId,
      'idMember1': idMember1,
      'idMember2': idMember2,
      'latestUpdate': DateTime.now(),
    });
    return chatRoomId;
  }

  Future<String> addMessage({
    required String? content,
    required Uint8List? image,
    required String idFrom,
    required String idTo,
    required String chatRoomId,
  }) async {
    String messageId = const Uuid().v1();
    String res = '';
    if (content == '' && image == null) {
      res = 'no content and image';
      return res;
    } else if (content == '' && image != null) {
      try {
        String photoUrl = await uploadImage(image, 'chat_posts', true);
        final message = ChatMessages(
          content: content,
          photoUrl: photoUrl,
          timestamp: DateTime.now(),
          idFrom: idFrom,
          idTo: idTo,
        );
        await _firestore
            .collection('chats')
            .doc(chatRoomId)
            .collection('messages')
            .doc(messageId)
            .set(message.toJson());
        res = 'succes';
      } catch (e) {
        // Display an error message to the user
        res = ('Error occurred during add post: $e');
      }
    } else if (content != '' && image == null) {
      try {
        String photoUrl = '';
        final message = ChatMessages(
          content: content,
          photoUrl: photoUrl,
          timestamp: DateTime.now(),
          idFrom: idFrom,
          idTo: idTo,
        );
        await _firestore
            .collection('chats')
            .doc(chatRoomId)
            .collection('messages')
            .doc(messageId)
            .set(message.toJson());
        res = 'succes';
      } catch (e) {
        // Display an error message to the user
        res = ('Error occurred during add post: $e');
      }
    }
    return res;
  }

  Future<bool> doesChatRoomExist(String idMember1, String idMember2) async {
    final snapshot1 = await FirebaseFirestore.instance
        .collection('chats')
        .where('idMember1', whereIn: [idMember1, idMember2]).get();
    final snapshot2 = await FirebaseFirestore.instance
        .collection('chats')
        .where('idMember1', whereIn: [idMember1, idMember2]).get();
    if (snapshot1.docs.isNotEmpty && snapshot2.docs.isNotEmpty) {
      return true;
    }
    return false;
  }
}
