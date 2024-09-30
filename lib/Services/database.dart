import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _uid;

  String? get uid => _uid;

  // Method to set the user's UID
  void setUserId(String uid) {
    _uid = uid;
    notifyListeners();  // Notify listeners that the UID has changed
  }
}
