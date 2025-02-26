import 'package:flutter/material.dart';

import 'package:dropbucket_flutter/widgets/card_dialog_edit.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:file_icon/file_icon.dart';


class CardFile extends StatefulWidget {
  final FileItem file;
  final Function fetchItemsList;
  final Function? onGo;
  final Function? onDelete;
  final Function? onDownload;
  final Function? onShared;
  final Function? onEditFile;

  const CardFile({
    super.key,
    required this.file,
    required this.fetchItemsList,
    this.onGo,
    this.onDelete,
    this.onDownload,
    this.onShared,
    this.onEditFile,
  });

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
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
                transform:
                    Matrix4.rotationY(_animation.value * 3.141592653589793),
                alignment: Alignment.center,
                child: isFront
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
            onTap: () => widget.onGo?.call(),
            onLongPressUp: _flipCard,
            // onSecondaryTap: _flipCard,
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
        )
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
              constraints: BoxConstraints(
                minWidth: 32.0,
                minHeight: 32.0,
              ),
              icon: const Icon(Icons.arrow_back, size: 20.0),
              onPressed: _flipCard, // Regresa al frente
            ),
            if (widget.onEditFile != null)
              IconButton(
                  color: IndigoTheme.primaryColor,
                  iconSize: 20.0,
                  padding: EdgeInsets.all(0.0),
                  constraints: BoxConstraints(
                    minWidth: 32.0,
                    minHeight: 32.0,
                  ),
                  icon: const Icon(Icons.edit, size: 20.0),
                  onPressed: () => showEditDialog(
                        context,
                        flipCard: _flipCard,
                        name: name,
                        onEditObject: (rename) {
                          widget.onEditFile?.call(rename);
                        },
                      ) // Regresa al frente
                  ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.onShared != null)
              IconButton(
                  color: IndigoTheme.primaryColor,
                  iconSize: 20.0,
                  padding: EdgeInsets.all(0.0),
                  constraints: BoxConstraints(
                    minWidth: 32.0,
                    minHeight: 32.0,
                  ),
                  icon: const Icon(Icons.share, size: 20.0),
                  onPressed: () {
                    _flipCard(); // Regresa al frente
                    widget.onShared?.call();
                  }),
            if (widget.onDelete != null)
              IconButton(
                color: IndigoTheme.primaryColor,
                iconSize: 20.0,
                padding: EdgeInsets.all(0.0),
                constraints: BoxConstraints(
                  minWidth: 32.0,
                  minHeight: 32.0,
                ),
                icon: const Icon(Icons.delete, size: 20.0),
                onPressed: () => showDeleteDialog(name), // Regresa al frente
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.onDownload != null)
              IconButton(
                  color: IndigoTheme.primaryColor,
                  iconSize: 20.0,
                  padding: EdgeInsets.all(0.0),
                  constraints: BoxConstraints(
                    minWidth: 32.0,
                    minHeight: 32.0,
                  ),
                  icon: const Icon(Icons.download, size: 20.0),
                  onPressed: () {
                    _flipCard();
                    widget.onDownload?.call();
                  }),
          ],
        ),
      ],
    );
  }

  Future<String?> showDeleteDialog(List<String> name) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Confirmación',
          style: TextStyle(fontSize: 17.0),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('¿Seguro que desea borrar el archivo?'),
          Text(name.last),
        ]),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _flipCard();
              widget.onDelete?.call();
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
