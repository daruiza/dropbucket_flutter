import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dropbucket_flutter/utils/file_handler.dart';

import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:file_icon/file_icon.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:dropbucket_flutter/utils/message.dart';

class CardFile extends StatefulWidget {
  final FileItem file;

  const CardFile({super.key, required this.file});

  @override
  State<CardFile> createState() => _CardFileState();
}

class _CardFileState extends State<CardFile>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  bool _isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
      if (_isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Future<void> _tapFile(BuildContext context) async {
    final fileResponse = await FileHandler.onGetFile(
      context: context,
      file: widget.file,
      flipCard: _flipCard,
    );

    if (fileResponse != null && fileResponse.bodyBytes != null) {
      // Obtener el directorio temporal para guardar el archivo
      final directory = await getTemporaryDirectory();
      final fileName = widget.file.name.split('/').last;
      final filePath = '${directory.path}/$fileName';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final isFront = _animation.value < 0.5;
            return GestureDetector(
              onLongPressUp: () {
                if (!isFront) _flipCard(); // Permite regresar al frente
              },
              child: Transform(
                transform: Matrix4.rotationY(
                  _animation.value * 3.141592653589793,
                ),
                alignment: Alignment.center,
                child:
                    isFront
                        ? _buildFront()
                        : Transform(
                          transform: Matrix4.rotationY(3.141592653589793),
                          alignment: Alignment.center,
                          child: _buildBack(),
                        ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront() {
    List<String> name = widget.file.name.split('/');
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _tapFile(context),
            onLongPressUp: _flipCard,
            onSecondaryTap: _flipCard,
            child: FileIcon('.${widget.file.extension}', size: 65),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6.0, right: 6.0),
          child: Text(
            name.last,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(fontSize: 10.0),
          ),
        ),
      ],
    );
  }

  Widget _buildBack() {
    List<String> name = widget.file.name.split('/');
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              color: IndigoTheme.primaryColor,
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.arrow_back, size: 20.0),
              onPressed: _flipCard, // Regresa al frente
            ),

            IconButton(
              color: IndigoTheme.primaryColor,
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.edit, size: 20.0),
              onPressed:
                  () => FileHandler.showEditFileDialog(
                    context,
                    file: widget.file,
                    name: name,
                  ).then((_) {
                    // No necesita el FlipCard, hay un refresh
                    // _flipCard();
                  }),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              color: IndigoTheme.primaryColor,
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.share, size: 20.0),
              onPressed: () {
                FileHandler.onShared(
                  context: context,
                  file: widget.file,
                  flipCard: _flipCard,
                );
              },
            ),

            IconButton(
              color: IndigoTheme.primaryColor,
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.delete, size: 20.0),
              onPressed:
                  () => FileHandler.showDeleteDialog(
                    context,
                    widget.file,
                    name,
                  ).then((_) {
                    // No necesita el FlipCard, hay un refresh
                    // _flipCard();
                  }), // Regresa al frente
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              color: IndigoTheme.primaryColor,
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.download, size: 20.0),
              onPressed:
                  () => FileHandler.onDownloadFile(
                    context: context,
                    file: widget.file,
                    flipCard: _flipCard,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
