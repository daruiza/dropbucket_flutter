import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';

class FolderHandler {
  static Future<void> showNewFolderDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final textFieldController = TextEditingController();
        var isButtonEnabled = false;

        void validateInput(String input) {
          final isValid = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(input);
          isButtonEnabled = isValid && input.isNotEmpty;
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                'Nuevo directorio',
                style: TextStyle(fontSize: 16.0),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    controller: textFieldController,
                    decoration: InputDecoration(
                      hintText: "Nombre de directorio",
                      errorText:
                          textFieldController.text.isEmpty
                              ? null
                              : RegExp(
                                r'^[a-zA-Z0-9]+$',
                              ).hasMatch(textFieldController.text)
                              ? null
                              : 'Solo letras y números',
                    ),
                    onChanged: (text) {
                      setState(() {
                        validateInput(text);
                      });
                    },
                    onSubmitted: (value) async {
                      await onCreateFolder(context, textFieldController.text);
                      if (context.mounted) {
                        Navigator.pop(context, textFieldController.text);
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed:
                      isButtonEnabled
                          ? () async {
                            await onCreateFolder(
                              context,
                              textFieldController.text,
                            );
                            if (context.mounted) {
                              Navigator.pop(context, textFieldController.text);
                            }
                          }
                          : null,
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<void> onCreateFolder(
    BuildContext context,
    String? folder,
  ) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    try {
      // context.loaderOverlay.show();
      if (folder != null) {
        await bucketService.createFolder(folder);
        if (context.mounted) {
          MessageProvider.showSnackBarContext(
            context,
            Message(
              message: 'Creado con exito',
              statusCode: HttpStatusColor.success200.code,
              messages: ['Directorio: $folder!'],
            ),
          );
        }
        bucketService.itemsList();
        // await bucketService.itemsListFuture();
        // context.loaderOverlay.hide();
      }
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

  static Future<void> onDeleteFolder(
    BuildContext context,
    String? folder,
  ) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    try {
      if (folder != null) {
        await bucketService.deleteFolder(folder);
        if (context.mounted) {
          MessageProvider.showSnackBarContext(
            context,
            Message(
              message: 'Directorio eliminado con exito',
              statusCode: HttpStatusColor.success200.code,
              messages: ['Directorio: $folder!'],
            ),
          );
        }
        bucketService.itemsList();
        // await bucketService.itemsListFuture();
        // context.loaderOverlay.hide();
      }
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
