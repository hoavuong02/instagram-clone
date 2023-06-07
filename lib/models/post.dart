import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String caption;
  final String uid;
  final String photoUrl;
  final String postId;
  final datePublished;
  final likes;
  final marked;
  const Post({
    required this.caption,
    required this.uid,
    required this.photoUrl,
    required this.postId,
    required this.datePublished,
    required this.likes,
    required this.marked,
  });
  Map<String, dynamic> toJson() => {
        "caption": caption,
        "uid": uid,
        "photoUrl": photoUrl,
        "postId": postId,
        "datePublished": datePublished,
        "likes": likes,
        "marked": marked,
      };
  static Post fromSnap(DocumentSnapshot snap) {
    final snapshot = (snap.data() as Map<String, dynamic>);
    return Post(
      caption: snapshot['caption'],
      uid: snapshot['uid'],
      photoUrl: snapshot['photoUrl'],
      postId: snapshot['postId'],
      datePublished: snapshot['datePublished'],
      likes: snapshot['likes'],
      marked: snapshot['marked'],
    );
  }
}
