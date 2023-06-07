import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comments_screen.dart';
import 'package:instagram_clone/utilities/colors.dart';
import 'package:instagram_clone/utilities/consts.dart';
import 'package:instagram_clone/utilities/exception.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;

  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final firestoreMethod = FireStoreMethod();
  bool isLikeAnimating = false;
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      userPhoto,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    userName,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      child: Text('Delete'),
                      onTap: () async {
                        //FireStoreMethod().deleteComment(widget.postId, widget.snap['commentId']);
                        final commentData = await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.snap['postId'])
                            .collection('comments')
                            .get();
                        //có comment trong post => xóa hết comment
                        if (commentData.docs.isNotEmpty) {
              

                          final List<Future<void>> deleteFutures = [];

                          commentData.docs.forEach((doc) {
                            final Future<void> deleteFuture =
                                doc.reference.delete();
                            deleteFutures.add(deleteFuture);
                          });

                          await Future.wait(deleteFutures);
                        }
                        await FireStoreMethod()
                            .deletePost(widget.snap['postId']);
                      },
                    ),
                  ];
                },
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          //image section
          GestureDetector(
            onDoubleTap: () async {
              await FireStoreMethod().likePost(
                  widget.snap['postId'], user.uid, widget.snap['likes']);
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['photoUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    child: Icon(
                      Icons.favorite,
                      size: 100,
                      color: Colors.white,
                    ),
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          //like comment share section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                LikeAnimation(
                  isAnimating: widget.snap['likes'].contains(user.uid),
                  smallLike: true,
                  child: IconButton(
                    onPressed: () async {
                      await FireStoreMethod().toggleLikePost(
                          widget.snap['postId'],
                          user.uid,
                          widget.snap['likes']);
                    },
                    icon: widget.snap['likes'].contains(user.uid)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 35,
                          )
                        : const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentScreen(snap: widget.snap),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.messenger_outline_rounded,
                    size: 35,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.send_outlined,
                    size: 35,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () async {
                        await FireStoreMethod().favoritePost(user.uid,
                            widget.snap['postId'], widget.snap['marked']);
                      },
                      icon: widget.snap['marked'].contains(user.uid)
                          ? const Icon(
                              Icons.bookmark,
                              size: 35,
                              color: Colors.blue,
                            )
                          : const Icon(
                              Icons.bookmark_border,
                              size: 35,
                            ),
                    ),
                  ),
                )
              ],
            ),
          ),
          //the number of likes, description, ...
          Text(
            '${widget.snap['likes'].length} likes',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: primaryColor),
                children: [
                  TextSpan(
                    text: userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '  ${widget.snap['caption']}',
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentScreen(snap: widget.snap),
                  ),
                );
              },
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.snap['postId'])
                      .collection('comments')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('view all comments');
                    }
                    return Text(
                      'view all ${snapshot.data!.docs.length} comments',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                      ),
                    );
                  }),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              DateFormat('d MMM y')
                  .format(widget.snap['datePublished'].toDate()),
              style: TextStyle(
                color: secondaryColor,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}
