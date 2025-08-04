import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart'; // Asegúrate que esta ruta es correcta
import 'package:dropbucket_flutter/services/bucket_service.dart'; // Asegúrate que esta ruta es correcta
import 'package:webview_flutter/webview_flutter.dart';
// Si estás en Flutter web, podrías necesitar importar webview_flutter_web.dart
// import 'package:webview_flutter_web/webview_flutter_web.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _webViewController;
  late Future _fileContentFuture;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController();

    // Inicializa el Future en initState
    final bucketService = Provider.of<BucketService>(context, listen: false);
    _fileContentFuture = bucketService.contentFile(
      file: FileItem(
        name: widget.url,
        extension: widget.url.split('.').last,
        lastModified: DateTime.now(), // Considera pasar la fecha real si es relevante
        size: 0, // Considera pasar el tamaño real si es relevante
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _fileContentFuture, // Usa el Future inicializado
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras esperamos los datos
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Si ocurre un error
            print('Error al cargar el archivo: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final file = snapshot.data!;
            final String htmlContent = file.body ?? ''; // Asumiendo que file.body es String

            // Una vez que tenemos los datos, cargamos el HTML en el WebView.
            // Es importante que esto se haga solo cuando los datos están disponibles.
            // Para asegurar que se carga una sola vez o solo cuando el contenido cambie,
            // idealmente esto se haría en initState o en una lógica que evite recargas innecesarias.
            // Sin embargo, dentro del builder de FutureBuilder es el punto más sencillo.
            // Si el FutureBuilder se reconstruye, el loadHtmlString se llamará de nuevo.
            _webViewController.loadHtmlString(htmlContent);

            return WebViewWidget(controller: _webViewController);
          } else {
            // Estado por defecto
            return const Center(child: Text('No hay datos disponibles.'));
          }
        },
      ),
    );
  }
}