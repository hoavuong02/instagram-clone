import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/resources/notification_services.dart';
import 'package:instagram_clone/widgets/message_buble.dart';

import '../utilities/exception.dart';
import '../utilities/utilities.dart';

class ChatRoomScreen extends StatefulWidget {
  final snap;
  final String chatRoomId;
  const ChatRoomScreen(
      {super.key, required this.snap, required this.chatRoomId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final _controller = TextEditingController();
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController _scrollController = ScrollController();

  Future<String> getData(String id, String typeData) async {
    String data = await FireStoreMethod().getUserDataByUid(id, typeData);
    return data;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
          child: Column(
            children: [
              Row(
                children: [
                  FutureBuilder<String>(
                    future: currentUser == widget.snap['idMember1']
                        ? getData(widget.snap['idMember2'], 'photoUrl')
                        : getData(widget.snap['idMember1'], 'photoUrl'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Icon(Icons.error);
                      }
                      return CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!),
                      );
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  FutureBuilder<String>(
                    future: currentUser == widget.snap['idMember1']
                        ? getData(widget.snap['idMember2'], 'username')
                        : getData(widget.snap['idMember1'], 'username'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Icon(Icons.error);
                      }
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(fontSize: 20),
                      );
                    },
                  ),
                ],
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatRoomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) => MessageBuble(
                        snap: snapshot.data!.docs[index],
                      ),
                    );
                  },
                ),
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        Uint8List file =
                            await pickImageFromGallery(ImageSource.gallery);
                        setState(() {
                          _file = file;
                        });
                      },
                      icon: const Icon(Icons.image_outlined)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          hintText: 'Write your mesage here',
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        String idFrom = FirebaseAuth.instance.currentUser!.uid;
                        String idTo = FirebaseAuth.instance.currentUser!.uid ==
                                widget.snap['idMember1']
                            ? widget.snap['idMember2']
                            : widget.snap['idMember1'];

                        String nameFrom = await FireStoreMethod()
                            .getUserDataByUid(idFrom, 'username');
                        String toKenTo = await FireStoreMethod()
                            .getUserDataByUid(idTo, 'token');
                        String res = await FireStoreMethod().addMessage(
                            content: _controller.text,
                            idFrom: idFrom,
                            idTo: idTo,
                            image: _file,
                            chatRoomId: widget.chatRoomId);
                        FirebaseFirestore.instance
                            .collection('chats')
                            .doc(widget.snap['chatRoomId'])
                            .update({
                          'latestUpdate': DateTime.now(),
                        });
                        if (res == 'succes') {
                          _controller.clear();
                          _scrollToBottom();
                        }

                        NotificationServices().sendNotification(
                            title: 'You have a new message from $nameFrom',
                            body: _controller.text,
                            type: 'msj',
                            to: toKenTo,
                            id: widget.chatRoomId);
                      },
                      icon: const Icon(Icons.send)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
