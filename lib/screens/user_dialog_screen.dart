import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:dropbucket_flutter/providers/user_form_provider.dart';

class UserDialogScreen extends StatelessWidget {
  final UserResponse? user;

  const UserDialogScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth =
              constraints.maxWidth > 600
                  ? constraints.maxWidth * 0.6
                  : constraints.maxWidth * 0.8;
          return SingleChildScrollView(
            child: Container(
              width: maxWidth,
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ChangeNotifierProvider(
                create: (_) => UserFormProvider(),
                child: _UserForm(maxWidth: maxWidth, user: user),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserForm extends StatelessWidget {
  final double maxWidth;
  final UserResponse? user;
  const _UserForm({required this.maxWidth, required this.user});
  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userForm = Provider.of<UserFormProvider>(context);
    return FutureBuilder(
      future: _photoExist(context),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Indicador de carga
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data.'));
        }

        userForm.photoExists.text = snapshot.data ? 'true' : 'false';

        return Form(
          key: userForm.userFormKey,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Row()
              ]
            ),
          ),
        );
      },
    );
  }

  Future<bool> _photoExist(BuildContext context) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    try {
      if (user?.photo != null && user?.photo != '') {
        final existFile = await bucketService.existFile(
          user?.photo?.split('.com/')[1] ?? '',
        );
        return jsonDecode(existFile.body)['exist'] ?? false;
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message.fromJson({"error": e.toString(), "statusCode": 400}),
        );
      }
      return false;
    }
  }
}
