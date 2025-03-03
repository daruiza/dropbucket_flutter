import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';

class FileHandler {
  static Future<void> onUploadFiles(BuildContext context) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Habilitamos la selección múltiple
    );
    if (result != null && result.files.isNotEmpty) {
      // Mostrar el indicador de carga
      // context.loaderOverlay.show();
      try {
        await bucketService.storeFiles(files: result.files);

        if (context.mounted) {
          MessageProvider.showSnackBarContext(
            context,
            Message(
              message: 'Carga Existoa',
              statusCode: HttpStatusColor.success200.code,
              messages: ['Los archivos se cargaron exitosamente!'],
            ),
          );
        }

        bucketService.itemsList();
      } on Exception catch (e) {
        // Manejo de errores
        if (context.mounted) {
          MessageProvider.showSnackBarContext(
            context,
            Message.fromJson({"error": e.toString(), "statusCode": 400}),
          );
        }
      } finally {
        // Aseguramos que el indicador de carga se oculte
        // context.loaderOverlay.hide();
      }
    }
  }

  // FOLDER FILE NAME
  static Future<String?> showEditFileDialog(
    BuildContext context, {
    required Function flipCard,
    required FileItem file,
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
        r'^[a-zA-Z0-9][-_a-zA-Z0-9áéíóúÁÉÍÓÚüÜñÑ\s]{0,63}(?<![-_. ])\.?[a-zA-Z0-9]{0,8}$',
      ).hasMatch(input);
      // Actualizar el estado local
      isButtonEnabled = isValid && input.isNotEmpty;
    }

    onEdit(FileItem file, String rename) async {
      await onEditPrefix(context, file, rename);
      if (context.mounted) {
        Navigator.pop(context, 'rename');
      }
      flipCard();
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
                        hintText: "Nombre de archivo",
                        errorText:
                            textFieldController.text.isEmpty
                                ? null
                                : RegExp(
                                  r'^[a-zA-Z0-9][-_a-zA-Z0-9áéíóúÁÉÍÓÚüÜñÑ\s]{0,63}(?<![-_. ])\.?[a-zA-Z0-9]{0,8}$',
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
                              onEdit(file, textFieldController.text);
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
    FileItem file,
    String rename,
  ) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    final String oldname = file.name;
    String directory = oldname.substring(0, oldname.lastIndexOf('/') + 1);

    try {
      // context.loaderOverlay.show();
      await bucketService.renameFile(
        name: oldname,
        rename: '$directory$rename',
      );

      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message(
            message: 'Archivo editado correctamente',
            statusCode: HttpStatusColor.success200.code,
            messages: ['Archivo editado correctamente: $oldname!'],
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

  static Future<String?> showDeleteDialog(
    BuildContext context,
    FileItem file,
    List<String> name,
    Function flipCard,
  ) {
    return showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Confirmación', style: TextStyle(fontSize: 17.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¿Seguro que desea borrar el archivo?'),
                Text(name.last),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  flipCard();
                  onDeleteFile(context, file);
                  Navigator.pop(context, 'OK');
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  static onDeleteFile(BuildContext context, FileItem file) async {
    List<String> name = file.name.split('/');
    final bucketService = Provider.of<BucketService>(context, listen: false);
    try {
      // context.loaderOverlay.show();
      await bucketService.deleteFile(context, file: file);
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message(
            message: 'Borrado exitoso',
            statusCode: HttpStatusColor.success200.code,
            messages: ['Archivo: $name!'],
          ),
        );
      }
      bucketService.itemsList();
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
}
