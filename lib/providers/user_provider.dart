import 'package:flutter/foundation.dart';
import 'package:instagram_clone/models/user.dart' as modelUser;
import 'package:instagram_clone/resources/auth_methods.dart';

class UserProvider extends ChangeNotifier {
  modelUser.User? _mdUser;
  final _authMedthod = AuthMedthod();

  modelUser.User get getUser => _mdUser!;

  Future<void> refereshUser() async {
    modelUser.User user = await _authMedthod.getUserDetail();
    _mdUser = user;
    notifyListeners();
  }
}
