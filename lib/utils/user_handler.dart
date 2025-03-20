import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:dropbucket_flutter/services/user_service.dart';
import 'package:dropbucket_flutter/screens/user_dialog_screen.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart';

class UserHandler {
  static Future<void> createUser(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) => UserDialogScreen(user: null),
    );
  }

  static Future<void> editUser(BuildContext context, UserResponse user) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => UserDialogScreen(user: user),
    ).then((value) {
      return value;
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
    final bucketService = Provider.of<BucketService>(context, listen: false);
    final oldFileName = user.photo != null ? user.photo?.split('/').last : '';
    try {
      await userService.deleteUser(user);

      // Eliminar archivo, en caso de existir
      if (oldFileName != '') {
        await bucketService.deleteFile(
          null,
          file: FileItem(
            name: 'users/$oldFileName',
            extension: '',
            lastModified: DateTime.now(),
            size: 0,
          ),
          fileName: 'users/$oldFileName',
        );
      }

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
