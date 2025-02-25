import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/widgets/card_dialog_edit.dart';
import 'package:dropbucket_flutter/widgets/dialog_input.dart';
import 'package:provider/provider.dart';

import '../../../themes/indigo.dart';

import 'package:flutter/material.dart';

class CardFolder extends StatefulWidget {
  final FolderItem folder;
  final Function fetchItemsList;
  final Function? onDelete;
  final Function? onEditPrefix;
  final Function? onRequestUpload;

  const CardFolder({
    super.key,
    required this.folder,
    required this.fetchItemsList,
    this.onDelete,
    this.onEditPrefix,
    this.onRequestUpload,
  });

  @override
  State<CardFolder> createState() => _CardFolderState();
}

class _CardFolderState extends State<CardFolder>
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

  Widget _buildFront() {
    List<String> name = widget.folder.name.split('/');
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onGo,
            onLongPressUp: _flipCard,
            // onSecondaryTap: _flipCard,
            child: Icon(
              Icons.folder,
              size: 80,
              color:
                  _isHovering
                      ? IndigoTheme.primaryColor
                      : IndigoTheme.hoverColor,
            ),
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

  Future<void> onGo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    List<String> name = widget.folder.name.split('/');
    if (name.isEmpty) return;
    try {
      // context.loaderOverlay.show();
      await authProvider.setUserPrefix(name.last);
      await widget.fetchItemsList.call();
    } finally {
      // if (mounted) context.loaderOverlay.hide();
    }
  }

  Widget _buildBack() {
    List<String> name = widget.folder.name.split('/');
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.arrow_back, size: 20.0),
              onPressed: _flipCard, // Regresa al frente
            ),
            if (widget.onEditPrefix != null)
              IconButton(
                iconSize: 20.0,
                padding: EdgeInsets.all(0.0),
                constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
                icon: const Icon(Icons.edit, size: 20.0),
                onPressed:
                    () => showEditDialog(
                      context,
                      flipCard: _flipCard,
                      name: name,
                      onEditObject: (rename) {
                        widget.onEditPrefix?.call(rename);
                      },
                    ), // Regresa al frente
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.onRequestUpload != null)
              IconButton(
                iconSize: 20.0,
                padding: EdgeInsets.all(0.0),
                constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
                icon: const Icon(Icons.upload, size: 20.0),
                onPressed:
                    () => showRequestFilesDialog(name), // Regresa al frente
              ),
            IconButton(
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.delete, size: 20.0),
              onPressed: () => showDeleteDialog(name), // Regresa al frente
            ),
          ],
        ),
      ],
    );
  }

  Future<String?> showDeleteDialog(List<String> name) {
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

  Future<String?> showRequestFilesDialog(List<String> name) {
    return showDialog(
      context: context,
      builder:
          (BuildContext context) => DialogInput(
            title: 'Solicitud de archivos para ${name.last}',
            label: 'Mensaje de solicitud',
          ),
    ).then((option) {
      _flipCard();
      if (option['option'] == 'done') {
        widget.onRequestUpload?.call(option['value'] ?? '');
      }
      return null;
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
}
