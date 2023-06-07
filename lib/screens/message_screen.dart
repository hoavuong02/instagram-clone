/* 
Tìm kiếm theo user, bấm chọn user => gọi hàm tạo chatRoom push sang ChatRoomScreen và truyền vào chatRoomId vừa tạo 
Loại bỏ phần thừa bên phía chatroomscreen
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utilities/colors.dart';
import 'package:instagram_clone/utilities/exception.dart';

import 'chat_room_screen.dart';
import 'profile_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _textcontroller = TextEditingController();
  bool isFindUser = false;
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;

  Future<String> getData(String id, String typeData) async {
    String data = await FireStoreMethod().getUserDataByUid(id, typeData);
    return data;
  }

  @override
  void dispose() {
    _textcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          children: [
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  const Icon(
                    Icons.person_search,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _textcontroller,
                      style: TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search here...',
                        hintStyle: TextStyle(color: secondaryColor),
                      ),
                      onFieldSubmitted: (value) {
                        setState(() {
                          isFindUser = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            isFindUser
                //get user that is looking for
                ? FindUserFutureBuider(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .where('username',
                            isGreaterThanOrEqualTo: _textcontroller.text)
                        .get(),
                  )
                : Expanded(
                    child: FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('chats')
                          .orderBy('latestUpdate')
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(
                                  snap: snapshot.data!.docs[index],
                                  chatRoomId: snapshot.data!.docs[index]
                                      ['chatRoomId'],
                                ),
                              )),
                              child: ListTile(
                                leading: FutureBuilder<String>(
                                  future: currentUser ==
                                          snapshot.data!.docs[index]
                                              ['idMember1']
                                      ? getData(
                                          snapshot.data!.docs[index]
                                              ['idMember2'],
                                          'photoUrl')
                                      : getData(
                                          snapshot.data!.docs[index]
                                              ['idMember1'],
                                          'photoUrl'),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return Icon(Icons.error);
                                    }
                                    return CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(snapshot.data!),
                                    );
                                  },
                                ),
                                title: FutureBuilder<String>(
                                  future: currentUser ==
                                          snapshot.data!.docs[index]
                                              ['idMember1']
                                      ? getData(
                                          snapshot.data!.docs[index]
                                              ['idMember2'],
                                          'username')
                                      : getData(
                                          snapshot.data!.docs[index]
                                              ['idMember1'],
                                          'username'),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    return Text(snapshot.data!);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class FindUserFutureBuider extends StatelessWidget {
  final Future future;
  const FindUserFutureBuider({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        //dữ liệu future là của user
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  //tìm kiếm theo bạn bè rồi tạo chatroom
                  //ktra chatroom đã tồn tại chưa
                  bool doesChatRoomExist = await FireStoreMethod()
                      .doesChatRoomExist(snapshot.data!.docs[index]['uid'],
                          FirebaseAuth.instance.currentUser!.uid);
                  if (doesChatRoomExist == true) {
                    showSnackBar(context, 'ChatRoom này đã tồn tại');
                  } else {
                    String chatRoomId = await FireStoreMethod().createChatRoom(
                        idMember1: snapshot.data!.docs[index]['uid'],
                        idMember2: FirebaseAuth.instance.currentUser!.uid);
                    //tạo dữ liệu cho chatroom vừa khởi tạo để truyền cho ChatRoomScreen
                    Map<String, dynamic> snapChatRoom = {
                      'chatRoomId': chatRoomId,
                      'idMember1': snapshot.data!.docs[index]['uid'],
                      'idMember2': FirebaseAuth.instance.currentUser!.uid,
                      'latestUpdate': DateTime.now(),
                    };
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(
                        //snap này là user k phải chatroom
                        snap: snapChatRoom,
                        chatRoomId: chatRoomId,
                      ),
                    ));
                  }
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(snapshot.data!.docs[index]['photoUrl']),
                  ),
                  title: Text(snapshot.data!.docs[index]['username']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
