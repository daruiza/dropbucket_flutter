import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../themes/indigo.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:dropbucket_flutter/utils/folder_handler.dart';

class CardFolder extends StatefulWidget {
  final FolderItem folder;

  const CardFolder({super.key, required this.folder});

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
            onTap: () {
              onGo(context);
            },
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

            IconButton(
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.edit, size: 20.0),
              onPressed:
                  () => FolderHandler.showEditFolderDialog(
                    context,
                    flipCard: _flipCard,
                    folder: widget.folder,
                    name: name,
                  ), // Regresa al frente
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.upload, size: 20.0),
              onPressed:
                  () => FolderHandler.showRequestFilesDialog(
                    context,
                    name,
                    _flipCard,
                    widget.folder,
                  ), // Regresa al frente
            ),
            IconButton(
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.delete, size: 20.0),
              onPressed:
                  () => FolderHandler.showDeleteDialog(
                    context,
                    name,
                    _flipCard,
                  ), // Regresa al frente
            ),
          ],
        ),
      ],
    );
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

  Future<void> onGo(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bucketService = Provider.of<BucketService>(context, listen: false);
    List<String> name = widget.folder.name.split('/');
    if (name.isEmpty) return;
    try {
      // context.loaderOverlay.show();
      if (context.mounted) {
        await authProvider.setUserPrefix(context, name.last);
      }
      bucketService.itemsList();
    } finally {
      // if (mounted) context.loaderOverlay.hide();
    }
  }
}
