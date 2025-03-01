import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';

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
}
