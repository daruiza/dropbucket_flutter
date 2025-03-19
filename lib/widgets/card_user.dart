import 'package:dropbucket_flutter/enums/role_enum.dart';
import 'package:dropbucket_flutter/utils/user_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:convert';
import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';

class CardUser extends StatefulWidget {
  final UserResponse user;

  const CardUser({super.key, required this.user});

  @override
  State<CardUser> createState() => _CardUserState();
}

class _CardUserState extends State<CardUser>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isFlipped = false;
  bool _imageDonload = false;
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

    existPhoto();
  }

  existPhoto() async {
    // Get User Image
    final bucketService = Provider.of<BucketService>(context, listen: false);
    if (widget.user.photo != '') {
      final existFile = await bucketService.existFile(
        widget.user.photo?.split('.com/')[1] ?? '',
      );
      _imageDonload = jsonDecode(existFile.body)['exist'] ?? false;
      setState(() {});
    }
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
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: null,
            onLongPressUp: _flipCard,
            onSecondaryTap: _flipCard,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _imageDonload
                    ? Stack(
                      children: [
                        CircleAvatar(
                          maxRadius: 36,
                          backgroundColor: IndigoTheme.primaryColor,
                          backgroundImage: NetworkImage(
                            widget.user.photo ?? '',
                          ),
                        ),
                        if (!_isHovered)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0x80909090),
                              ),
                            ),
                          ),
                      ],
                    )
                    : SizedBox(
                      width: 72,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          Icons.person,
                          color: IndigoTheme.primaryColor,
                        ),
                      ),
                    ),

                Center(child: Text(widget.user.name)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBack() {
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
              icon: const Icon(Icons.edit, size: 20.0),
              onPressed: () {
                // _editCard();
                UserHandler.editUser(context, widget.user);
              },
            ),
            IconButton(
              color: IndigoTheme.primaryColor,
              iconSize: 20.0,
              padding: EdgeInsets.all(0.0),
              constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
              icon: const Icon(Icons.delete, size: 20.0),
              // onPressed: () => showDeleteDialog(),
              onPressed:
                  widget.user.rolId != Role.superadministrador.id
                      ? () => UserHandler.showDeleteDialog(context, widget.user)
                      : null,
            ),
          ],
        ),
      ],
    );
  }
}
