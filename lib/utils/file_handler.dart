import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:io' show Platform, Directory, File;

// import 'package:web/web.dart' as web;
// import 'package:js/js_util.dart' as js_util;

class FileHandler {
  // UPLOAD FILE
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

  // FOLDER FILE RENAME
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

    // context.loaderOverlay.show();
    // Validamos la extención en el nombre
    // 1, si ya la tiene
    // 1.1 - verificar que sea la misma
    // 1.2 - no colocarla nuevamente
    // 2. si no la tiene, colocarla
    final String oldname = file.name;
    String directory =
        oldname.contains('/')
            ? '${oldname.substring(0, oldname.lastIndexOf('/') + 1)}/'
            : oldname.substring(0, oldname.lastIndexOf('/') + 1);
    final String extension = oldname.split('.').last;

    try {
      await bucketService.renameFile(
        name: oldname,
        rename: '$directory$rename.$extension',
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

  // SHARE FILE
  static onShared({
    required BuildContext context,
    required FileItem file,
    required Function flipCard,
  }) async {
    List<String> name = file.name.split('/');
    final bucketService = Provider.of<BucketService>(context, listen: false);
    try {
      final response = await bucketService.sharedFile(file: file);
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

  // DOWNLOAD FILE
  static onDownloadFile({
    required BuildContext context,
    required FileItem file,
    required Function flipCard,
  }) async {
    List<String> name = file.name.split('/');
    final bucketService = Provider.of<BucketService>(context, listen: false);
    try {
      final response = await bucketService.downloadFile(file: file);
      Directory directory;
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          directory =
              await getDownloadsDirectory() ?? await getTemporaryDirectory();
        }
        final filePath = '${directory.path}/${name.last}';
        final responseFile = File(filePath);
        await responseFile.writeAsBytes(response.bodyBytes);
        // TODO: si funciona, pero se neceista que guarde las repetidas_0x
      }
      if (kIsWeb) {
        await downloadFile(response.bodyBytes, name.last);
      }
      flipCard();
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message(
            message: 'Descarga exitosa!',
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

  static Future<void> downloadFile(List<int> bytes, String fileName) async {
    // Lógica de descarga para web
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrl(blob);

      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE FILE
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
