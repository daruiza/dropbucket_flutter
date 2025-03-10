import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:flutter/material.dart';

class CardUser extends StatelessWidget {
  final UserResponse user;

  const CardUser({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Text(user.name);
  }
}
