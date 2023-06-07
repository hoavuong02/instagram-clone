import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessages {
  final String idFrom;
  final String idTo;
  final timestamp;
  final String? content;
  final String? photoUrl;

  ChatMessages(
      {required this.idFrom,
      required this.idTo,
      required this.timestamp,
      required this.content,
      required this.photoUrl});

  Map<String, dynamic> toJson() {
    return {
      'idFrom': idFrom,
      'idTo': idTo,
      'timestamp': timestamp,
      'content': content,
      'photoUrl': photoUrl,
    };
  }

  static ChatMessages fromSnap(DocumentSnapshot snap) {
    final snapshot = (snap.data() as Map<String, dynamic>);
    return ChatMessages(
        idFrom: snapshot['idFrom'],
        idTo: snapshot['idTo'],
        timestamp: snapshot['timestamp'],
        content: snapshot['content'],
        photoUrl: snapshot['photoUrl']);
  }
}
