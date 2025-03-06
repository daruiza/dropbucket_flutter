import 'package:flutter/material.dart';
import 'package:dropbucket_flutter/app_bar_menu.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: null,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data.'));
        }

        return Scaffold(appBar: AppBarMenu(title: 'Usuarios'));
      },
    );
  }
}
