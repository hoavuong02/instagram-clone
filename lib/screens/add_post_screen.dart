import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utilities/colors.dart';
import 'package:instagram_clone/models/user.dart' as modelUser;
import 'package:provider/provider.dart';
import '../utilities/exception.dart';
import '../utilities/utilities.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final _textEditingController = TextEditingController();
  bool isLoading = false;
  final _textFieldFocusNode = FocusNode();

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Create a post'),
          children: [
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImageFromGallery(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
              child: Text('Take a picture'),
            ),
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file =
                    await pickImageFromGallery(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
              child: Text('Choose from gallery'),
            ),
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void addPostToCloud(String uid) async {
    setState(() {
      isLoading = true;
    });
    _textFieldFocusNode.unfocus();
    final postMethod = FireStoreMethod();
    String res = await postMethod.addPost(
      caption: _textEditingController.text,
      image: _file!,
      uid: uid,
    );
    showSnackBar(context, res);
    clearImage();
    setState(() {
      isLoading = false;
    });
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;
    return _file == null
        ? Center(
            child: IconButton(
              icon: Icon(Icons.upload),
              onPressed: () {
                _selectImage(context);
              },
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text("Post to"),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  clearImage();
                },
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      addPostToCloud(user.uid);
                    },
                    child: const Text(
                      'Post',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ))
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: TextField(
                          focusNode: _textFieldFocusNode,
                          controller: _textEditingController,
                          decoration: const InputDecoration(
                              hintText: 'Write a caption ...',
                              border: InputBorder.none),
                          maxLines: 8,
                        ),
                      ),
                      SizedBox(
                        width: 45,
                        height: 45,
                        child: AspectRatio(
                          aspectRatio: 487 / 451,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: MemoryImage(_file!),
                                  fit: BoxFit.fill,
                                  alignment: FractionalOffset.topCenter),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  isLoading == true
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(),
                ],
              ),
            ),
          );
  }
}
