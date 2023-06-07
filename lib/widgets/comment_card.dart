import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';

class CommentCard extends StatefulWidget {
  final snap;
  final String postId;
  const CommentCard({super.key, required this.snap, required this.postId});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final firestoreMethod = FireStoreMethod();
  String userName = '';
  String userPhoto = '';

  void getDataUser(String uid) async {
    final newUserName = await firestoreMethod.getUserDataByUid(uid, 'username');
    final newUserPhoto =
        await firestoreMethod.getUserDataByUid(uid, 'photoUrl');
    setState(() {
      userName = newUserName;
      userPhoto = newUserPhoto;
    });
  }

  @override
  void initState() {
    getDataUser(widget.snap['uid']);

    super.initState();
  }
//FireStoreMethod().deleteComment(widget.postId, widget.snap['commentId'])

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;
    return InkWell(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text('Do you want to delete this comment'),
              actions: [
                TextButton(
                  onPressed: () async {
                    await FireStoreMethod()
                        .deleteComment(widget.postId, widget.snap['commentId']);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(userPhoto),
              radius: 18,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 18),
                        children: [
                          TextSpan(
                              text: userName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: '  ${widget.snap['comment']}',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('d MMM y')
                            .format(widget.snap['datePublished'].toDate()),
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: GestureDetector(
                onTap: () async {
                  await FireStoreMethod().toggleLikeComment(widget.postId,
                      user.uid, widget.snap['likes'], widget.snap['commentId']);
                },
                child: widget.snap['likes'].contains(user.uid)
                    ? const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 30,
                      )
                    : const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
