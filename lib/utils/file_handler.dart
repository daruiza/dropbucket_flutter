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
import 'package:desktop_drop/desktop_drop.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:io' show Platform, Directory, File;
import 'dart:ui_web' as ui;

// import 'package:web/web.dart' as web;
// import 'package:js/js_util.dart' as js_util;

class FileHandler {
  // UPLOAD FILE
  static Future<void> onUploadFiles(BuildContext context) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Habilitamos la selección múltiple
      withData: true, //Fuerza la carga de los datos en memoria
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

        await bucketService.itemsList();
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

  // UPLOAD FILE
  static Future<void> onUploadBlobFiles(
    BuildContext context, {
    required List<DropItem> files,
  }) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);

    // Mostrar el indicador de carga
    // context.loaderOverlay.show();
    try {
      await bucketService.storeBlobFiles(files: files);
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

      await bucketService.itemsList();
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

  // SHOW FILE DIALOG
  static Future<String?> showFileDialog(
    BuildContext context, {
    required FileItem file,
    required List<String> name,
  }) async {
    String iframeViewType =
        'iframeElement-${DateTime.now().millisecondsSinceEpoch}';
    late html.IFrameElement iframe;
    try {
      final bucketService = Provider.of<BucketService>(context, listen: false);
      final response = await bucketService.sharedFile(file: file);
      final String fileUrl = jsonDecode(response.body)['url'];
      // final String viewerUrl = "https://docs.google.com/gview?embedded=true&url=$fileUrl";
      final String viewerUrl =
          "https://view.officeapps.live.com/op/view.aspx?src=$fileUrl";

      ui.platformViewRegistry.registerViewFactory(iframeViewType, (int viewId) {
        iframe =
            html.IFrameElement()
              ..src = viewerUrl
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%';
        return iframe;
      });

      if (context.mounted) {
        return showDialog<String>(
          context: context,
          builder:
              (BuildContext context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  final width = MediaQuery.of(context).size.width * 0.95;
                  final height = MediaQuery.of(context).size.height * 0.95;
                  return AlertDialog(
                    // title: Align(
                    //   alignment: Alignment.topRight,
                    //   child: IconButton(
                    //     icon: Icon(Icons.close),
                    //     onPressed: () => Navigator.pop(context),
                    //   ),
                    // ),
                    content: SizedBox(
                      width: width,
                      height: height,
                      child: HtmlElementView(viewType: iframeViewType),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          iframe.remove();
                          Navigator.pop(context);
                        },
                        child: Text('Cerrar'),
                      ),
                      // TODO: Descargar y DescargarPDF
                    ],
                  );
                },
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
    return null;
  }

  static Future<String?> showPDFViewer(
    BuildContext context, {
    required FileItem file,
    required List<String> name,
  }) async {
    final String iframeViewType =
        'iframeElement-${DateTime.now().millisecondsSinceEpoch}';
    late html.IFrameElement iframe;

    try {
      final bucketService = Provider.of<BucketService>(context, listen: false);
      final response = await bucketService.sharedFile(file: file);
      // Registrar el IFrame en Flutter Web
      ui.platformViewRegistry.registerViewFactory(iframeViewType, (int viewId) {
        iframe =
            html.IFrameElement()
              ..src = jsonDecode(response.body)['url']
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%'
              ..allowFullscreen = true;
        return iframe;
      });

      // Mostrar el visor dentro de un AlertDialog
      if (context.mounted) {
        return showDialog(
          context: context,
          builder:
              (BuildContext context) => AlertDialog(
                titlePadding: EdgeInsets.zero,
                // title: Align(
                //   alignment: Alignment.topRight,
                //   child: IconButton(
                //     icon: Icon(Icons.close),
                //     onPressed: () {
                //       iframe.remove();
                //       Navigator.pop(context);
                //     },
                //   ),
                // ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: HtmlElementView(viewType: iframeViewType),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      iframe.remove();
                      Navigator.pop(context);
                    },
                    child: Text('Cerrar'),
                  ),
                  // TODO: Descargar y DescargarPDF
                ],
              ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message.fromJson({"error": e.toString(), "statusCode": 400}),
        );
      }
    }
    return null;
  }

  static Future<String?> showImageViewer(
    BuildContext context, {
    required FileItem file,
    required List<String> name,
  }) async {
    try {
      final bucketService = Provider.of<BucketService>(context, listen: false);
      final response = await bucketService.sharedFile(file: file);

      // Mostrar el visor dentro de un AlertDialog
      if (context.mounted) {
        return showDialog(
          context: context,
          builder:
              (BuildContext context) => AlertDialog(
                titlePadding: EdgeInsets.zero,
                // title: Align(
                //   alignment: Alignment.topRight,
                //   child: IconButton(
                //     icon: Icon(Icons.close),
                //     onPressed: () {
                //       iframe.remove();
                //       Navigator.pop(context);
                //     },
                //   ),
                // ),
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.95,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(jsonDecode(response.body)['url']),
                      fit:
                          BoxFit
                              .contain, // BoxFit.cover para llenar, contain para mantener relación
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cerrar'),
                  ),
                  // TODO: Descargar y DescargarPDF
                ],
              ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message.fromJson({"error": e.toString(), "statusCode": 400}),
        );
      }
    }

    return null;
  }

  static Future<String?> showTxtDialog(
    BuildContext context, {
    required FileItem file,
    required List<String> name,
  }) async {
    try {
      if (context.mounted) {
        return showDialog(
          context: context,
          builder:
              (BuildContext context) => AlertDialog(
                titlePadding: EdgeInsets.zero,
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: Text('hello'),
                ),
              ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message.fromJson({"error": e.toString(), "statusCode": 400}),
        );
      }
    }

    return null;
  }

  // FILE SHOW VIEW
  static Future<void> tapFile(
    BuildContext context, {
    required FileItem file,
    required Function flipCard,
  }) async {
    // Nativo Android y Windowa
    if (!kIsWeb) {
      if (context.mounted) {
        await FileHandler.onOpenFile(
          context: context,
          fileItem: file,
          flipCard: flipCard,
        );
      }
    }

    if (kIsWeb) {
      bool isImage = [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'bmp',
      ].contains(file.extension);

      bool isWord = [
        // Word
        'doc', 'docx', 'docm', 'dot', 'dotx', 'dotm', 'rtf', 'odt',
        // Excel
        'xls', 'xlsx', 'xlsm', 'xlt', 'xltx', 'xltm', 'xlsb', 'csv', 'ods',
        // PowerPoint
        'ppt',
        'pptx',
        'pptm',
        'pot',
        'potx',
        'potm',
        'pps',
        'ppsx',
        'ppsm',
        'odp',
        // Otros formatos de Office
        'one', 'pub', 'vsd', 'vsdx', 'mpp',
      ].contains(file.extension);

      if (isWord) {
        if (context.mounted) {
          await FileHandler.showFileDialog(
            context,
            file: file,
            name: file.name.split('/'),
          );
        }
      }
      if (file.extension == 'pdf') {
        if (context.mounted) {
          await FileHandler.showPDFViewer(
            context,
            file: file,
            name: file.name.split('/'),
          );
        }
      }

      if (isImage) {
        if (context.mounted) {
          await FileHandler.showImageViewer(
            context,
            file: file,
            name: file.name.split('/'),
          );
        }
      }

      if (file.extension == 'txt') {
        if (context.mounted) {
          await FileHandler.showTxtDialog(
            context,
            file: file,
            name: file.name.split('/'),
          );
        }
      }
    }
  }

  // FOLDER FILE RENAME
  static Future<String?> showEditFileDialog(
    BuildContext context, {
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

    onEdit(BuildContext context, FileItem file, String rename) async {
      await onEditPrefix(context, file, rename);
      if (context.mounted) {
        Navigator.pop(context, 'done');
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
                              onEdit(context, file, textFieldController.text);
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
    String rename, {
    String arrdirectory = '',
  }) async {
    if (context.mounted) {
      final bucketService = Provider.of<BucketService>(context, listen: false);
      // context.loaderOverlay.show();
      // Validamos la extención en el nombre
      // 1, si ya la tiene
      // 1.1 - verificar que sea la misma
      // 1.2 - no colocarla nuevamente
      // 2. si no la tiene, colocarla
      final String oldname = file.name;
      String directory =
          arrdirectory != ''
              ? arrdirectory
              : oldname.contains('/')
              ? oldname.substring(0, oldname.lastIndexOf('/') + 1)
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
          await bucketService.itemsList();
        }
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
  }

  // SHARE FILE
  static void onShared({
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

  // GET FILE
  static onGetFile({
    required BuildContext context,
    required FileItem file,
    required Function flipCard,
  }) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    try {
      final response = await bucketService.downloadFile(file: file);
      return response;
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

  static onGetFilePDF({
    required BuildContext context,
    required FileItem file,
    required Function flipCard,
  }) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    try {
      final response = await bucketService.downloadFilePDF(file: file);
      await downloadFile(response.bodyBytes, 'name.pdf');
      // return response;
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

  static onOpenFile({
    required BuildContext context,
    required FileItem fileItem,
    required Function flipCard,
  }) async {
    final fileResponse = await FileHandler.onGetFile(
      context: context,
      file: fileItem,
      flipCard: flipCard,
    );

    if (fileResponse != null && fileResponse.bodyBytes != null) {
      final fileName = fileItem.name.split('/').last;
      final String filePath =
          Platform.isAndroid
              ? '/storage/emulated/0/Download/$fileName'
              : '${Directory.systemTemp.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(fileResponse.bodyBytes);

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          MessageProvider.showSnackBarContext(
            context,
            Message.fromJson({
              "error": 'No se pudo abrir el archivo: ${result.message}',
              "statusCode": 400,
            }),
          );
        }
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
      await bucketService.itemsList();
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
