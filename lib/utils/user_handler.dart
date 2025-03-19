import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:dropbucket_flutter/services/user_service.dart';
import 'package:dropbucket_flutter/screens/user_dialog_screen.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';

class UserHandler {
  static Future<void> createUser(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => UserDialogScreen(user: null),
    ).then((value) {
      print('UserDialogScreen Closse');
    });
  }

  static Future<void> editUser(BuildContext context, UserResponse user) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => UserDialogScreen(user: user),
    ).then((value) {
      print('UserDialogScreen Closse');
    });
  }

  static Future<String?> showDeleteDialog(
    BuildContext context,
    UserResponse user,
  ) {
    return showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Confirmación', style: TextStyle(fontSize: 17.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¿Seguro que desea borrar el usuario?'),
                Text(user.names ?? ''),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await onDeleteUser(context, user);
                  if (context.mounted) {
                    Navigator.pop(context, 'OK');
                  }
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  static Future<void> onDeleteUser(
    BuildContext context,
    UserResponse user,
  ) async {
    final userService = Provider.of<UserService>(context, listen: false);
    try {
      await userService.deleteUser(user);
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message(
            message: 'Eliminado con exito',
            statusCode: HttpStatusColor.success200.code,
            messages: ['Usuario: ${user.names}!'],
          ),
        );
      }
      userService.itemsList();
    } catch (e) {
      // context.loaderOverlay.hide();
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message.fromJson({"error": e.toString(), "statusCode": 400}),
        );
      }
    }
  }
}
