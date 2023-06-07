import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageBuble extends StatefulWidget {
  final snap;
  const MessageBuble({super.key, required this.snap});

  @override
  State<MessageBuble> createState() => _MessageBubleState();
}

class _MessageBubleState extends State<MessageBuble> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          widget.snap['idFrom'] == FirebaseAuth.instance.currentUser!.uid
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color:
                widget.snap['idFrom'] == FirebaseAuth.instance.currentUser!.uid
                    ? Colors.blue
                    : Colors.white,
          ),
          child: Column(
            children: [
              if (widget.snap['content'] != '' && widget.snap['photoUrl'] == '')
                Text(
                  widget.snap['content'],
                  style: TextStyle(
                    color: widget.snap['idFrom'] ==
                            FirebaseAuth.instance.currentUser!.uid
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              if (widget.snap['content'] == '' && widget.snap['photoUrl'] != '')
                Image.network(
                  widget.snap['photoUrl'],
                  width: 200,
                  height: 200,
                )
            ],
          ),
        ),
      ],
    );
  }
}
