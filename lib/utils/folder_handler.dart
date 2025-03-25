import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/utils/request_upload_query.dart';
import 'package:dropbucket_flutter/widgets/dialog_input.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/constants.dart';

class FolderHandler {
  // NEW FOLDER
  static Future<void> showNewFolderDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final textFieldController = TextEditingController();
        var isButtonEnabled = false;

        void validateInput(String input) {
          final isValid = RegExp(r'^[a-zA-Z0-9_-\s]+$').hasMatch(input);
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
                                r'^[a-zA-Z0-9_-\s]+$',
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

  // FOLDER EDIT NAME
  static Future<String?> showEditFolderDialog(
    BuildContext context, {
    required FolderItem folder,
    required List<String> name,
  }) {
    final String coreName = name.last.split('.')[0];

    TextEditingController textFieldController = TextEditingController(
      text: coreName,
    );
    bool isButtonEnabled = false;

    void validateInput(String input) {
      isButtonEnabled = false;
      if (input == coreName) {
        return;
      }

      // Validar que el texto contenga solo letras y números
      final isValid = RegExp(
        r'^[a-zA-Z0-9_-\s]+$',
        // r'^[a-zA-Z0-9][-_a-zA-Z0-9áéíóúÁÉÍÓÚüÜñÑ\s]{0,63}(?<![-_. ])\.?[a-zA-Z0-9]{0,8}$',
      ).hasMatch(input);
      // Actualizar el estado local
      isButtonEnabled = isValid && input.isNotEmpty;
    }

    onEdit(FolderItem folder, String rename) async {
      await onEditPrefix(context, folder, rename);
      if (context.mounted) {
        Navigator.pop(context, 'rename');
      }
    }

    return showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text(
                  'Editar ${name.last}',
                  style: TextStyle(fontSize: 17.0),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textFieldController,
                      decoration: InputDecoration(
                        hintText: "Nombre de carpeta",
                        errorText:
                            textFieldController.text.isEmpty
                                ? null
                                : RegExp(
                                  r'^[a-zA-Z0-9_-\s]+$',
                                  // r'^[a-zA-Z0-9][-_a-zA-Z0-9áéíóúÁÉÍÓÚüÜñÑ\s]{0,63}(?<![-_. ])\.?[a-zA-Z0-9]{0,8}$',
                                ).hasMatch(textFieldController.text)
                                ? null
                                : 'Solo letras y números',
                      ),
                      onChanged: (text) {
                        setState(() {
                          validateInput(text);
                        });
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
                            ? () {
                              onEdit(folder, textFieldController.text.trim());
                            }
                            : null,
                    child: const Text('Editar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  static onEditPrefix(
    BuildContext context,
    FolderItem folder,
    String rename,
  ) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    final String oldname = folder.name;
    String directory = oldname.substring(0, oldname.lastIndexOf('/') + 1);

    try {
      // context.loaderOverlay.show();
      await bucketService.renamePrefix(
        name: oldname,
        rename: '$directory$rename',
      );

      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message(
            message: 'Carpeta editada correctamente',
            statusCode: HttpStatusColor.success200.code,
            messages: ['Carpeta editada correctamente: $oldname!'],
          ),
        );
      }
      bucketService.itemsList();
      // await fileState.loadFileList(context);
      // context.loaderOverlay.hide();
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

  // CREATE FOLDER
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

  // DELETE FOLDER
  static Future<String?> showDeleteDialog(
    BuildContext context,
    List<String> name,
  ) {
    return showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Confirmación', style: TextStyle(fontSize: 17.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¿Seguro que desea borrar el directorio?'),
                Text(name.last),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await onDeleteFolder(context, name.last);
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

  // REQUEST FILES TO FOLDER
  static Future<String?> showRequestFilesDialog(
    BuildContext context,
    List<String> name,
    Function flipCard,
    FolderItem folder,
  ) {
    return showDialog(
      context: context,
      builder:
          (BuildContext context) => DialogInput(
            title: 'Solicitud de archivos para ${name.last}',
            label: 'Mensaje de solicitud',
          ),
    ).then((option) {
      flipCard();
      if (option['option'] == 'done') {
        if (context.mounted) {
          onRequestFilesPrefix(context, folder, option['value']);
        }
      }
      return null;
    });
  }

  static Future<void> onRequestFilesPrefix(
    BuildContext context,
    FolderItem folder,
    String message,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String uri =
        '${Constants.apiBaseUrl}/#request_upload_uri/${RequestUploadQuery.simpleEncryptValue('{"prefix":"${folder.name}","message":"$message","user":"${authProvider.user?.name}"}')}';
    await Clipboard.setData(ClipboardData(text: uri));

    if (context.mounted) {
      MessageProvider.showSnackBarContext(
        context,
        Message(
          message: 'Solicitud de subida de archivos',
          statusCode: HttpStatusColor.success200.code,
          messages: ['Url copiado: $uri!'],
        ),
      );
    }
  }

  static void onShared({
    required BuildContext context,
    required FolderItem folder,
    required Function flipCard,
  }) async {
    List<String> name = folder.name.split('/');
    final bucketService = Provider.of<BucketService>(context, listen: false);
    try {
      final response = await bucketService.sharedPrefix(folder: folder);
      await Clipboard.setData(
        ClipboardData(text: jsonDecode(response.body)['url'] ?? ''),
      );
      flipCard();
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message(
            message: 'Copiado con exito',
            statusCode: HttpStatusColor.success200.code,
            messages: ['Archivo: $name!'],
          ),
        );
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
