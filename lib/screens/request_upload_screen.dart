import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:dropbucket_flutter/utils/request_upload_query.dart';

class RequestUploadScreen extends StatelessWidget {
  final RequestUploadQuery query;
  const RequestUploadScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            query.prefix != '' && query.prefix != null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SOLICITUD CARGA DE ARCHIVOS'),                    
                    Text('Carpeta: ${query.prefix?.split('/').last}'),
                    const SizedBox(height: 20),
                    Text(query.message ?? ''),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        onUploadFiles(context, query);
                      },
                      child: const Text('SELECCIONA ARCHIVOS'),
                    ),
                  ],
                )
                : Text('No se ha recibido el prefijo'),
      ),
    );
  }

  Future<void> onUploadFiles(BuildContext context, RequestUploadQuery query) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Habilitamos la selección múltiple
       withData: true, //Fuerza la carga de los datos en memoria
    );
    if (result != null && result.files.isNotEmpty) {
      // Mostrar el indicador de carga
      // context.loaderOverlay.show();
      try {
        await bucketService.storeFiles(
          files: result.files,
          prefix: query.prefix,
        );
        if (context.mounted) {
          MessageProvider.showSnackBarContext(
            context,
            Message(
              message: '¡Carga múltiple exitosa!',
              statusCode: HttpStatusColor.success200.code,
              messages: ['Carga múltiple exitosa'],
            ),
          );
        }
      } on Exception catch (e) {
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
