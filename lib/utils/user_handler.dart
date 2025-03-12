import 'package:flutter/material.dart';
import 'package:dropbucket_flutter/screens/user_dialog_screen.dart';

class UserHandler {
  static Future<void> createUser(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => UserDialogScreen(user: null),
    ).then((value) {
      print('UserDialogScreen Closse');
    });
  }
}
