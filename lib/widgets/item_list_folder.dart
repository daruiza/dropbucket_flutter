import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/providers/state_bool.dart';
import 'package:dropbucket_flutter/utils/folder_handler.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/enums/enum_option.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';

class ItemListFolder extends StatelessWidget {
  final FolderItem folder;
  const ItemListFolder({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // TODO: Se repite en el Widget: TitleFolder - la idea seria pasarcelo como parametro
    bool isProcessingTap = false;
    final bool optionEditFolder = EnumOption.hasOption(
      authProvider.user?.options,
      'folder_edit',
    );
    final bool optionDeleteFolder = EnumOption.hasOption(
      authProvider.user?.options,
      'folder_delete',
    );
    final bool optionRequestUpload = EnumOption.hasOption(
      authProvider.user?.options,
      'folder_request_upload',
    );

    final bool optionShareFolder = EnumOption.hasOption(
      authProvider.user?.options,
      'folder_share',
    );

    return ChangeNotifierProvider(
      create: (_) => StateBoolProvider(),
      child: Builder(
        builder: (context) {
          final stateBoolProvider = Provider.of<StateBoolProvider>(context);
          return DragTarget(
            onAcceptWithDetails: onAcceptWithDetailsFolder,
            builder: (
              BuildContext context,
              List<dynamic> accepted,
              List<dynamic> rejected,
            ) {
              return Draggable(
                data: folder,
                feedback: DraggableFolderFeedback(folder: folder),
                child: MouseRegion(
                  onEnter: (_) => stateBoolProvider.stateBool = true,
                  onExit: (_) => stateBoolProvider.stateBool = false,
                  cursor: SystemMouseCursors.click,

                  child: GestureDetector(
                    onTap: () async {
                      if (isProcessingTap) {
                        return; // Evita la ejecución si ya se está procesando un tap
                      }
                      isProcessingTap = true;
                      await FolderHandler.onGo(
                        context,
                        name: folder.name.split('/'),
                      ).then((_) {
                        // _isProcessingTap = false;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                            right: 16.0,
                            left: 16.0,
                            top: 6.0,
                            bottom: 6.0,
                          ),
                          color:
                              stateBoolProvider.stateBool
                                  ? IndigoTheme.hoverColor
                                  : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TitleFolder(folder: folder),
                              OptionsFolder(
                                optionEditFolder: optionEditFolder,
                                folder: folder,
                                optionRequestUpload: optionRequestUpload,
                                optionDeleteFolder: optionDeleteFolder,
                                optionShareFolder: optionShareFolder,
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: IndigoTheme.primaryLowColor,
                          thickness: 0.5,
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void onAcceptWithDetailsFolder(DragTargetDetails<dynamic> details) {
    print(details.data.name);
    print(folder.name);
  }
}

class DraggableFolderFeedback extends StatelessWidget {
  const DraggableFolderFeedback({super.key, required this.folder});

  final FolderItem folder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: IndigoTheme.primaryColor ?? Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(
          5.0,
        ), // Opcional: para bordes redondeados
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(Icons.folder, color: IndigoTheme.primaryFullColor),
          const SizedBox(width: 5),
          Text(
            folder.name.split('/').last,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
              color: IndigoTheme.primaryColor,
              fontStyle: FontStyle.normal,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class OptionsFolder extends StatelessWidget {
  const OptionsFolder({
    super.key,
    required this.optionEditFolder,
    required this.folder,
    required this.optionRequestUpload,
    required this.optionDeleteFolder,
    required this.optionShareFolder,
  });

  final bool optionEditFolder;
  final FolderItem folder;
  final bool optionRequestUpload;
  final bool optionDeleteFolder;
  final bool optionShareFolder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (optionEditFolder)
          IconButton(
            color: IndigoTheme.primaryColor,
            iconSize: 20.0,
            padding: EdgeInsets.all(0.0),
            constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
            icon: const Icon(Icons.edit, size: 20.0),
            onPressed:
                () => FolderHandler.showEditFolderDialog(
                  context,
                  folder: folder,
                  name: folder.name.split('/'),
                ).then((_) {
                  // No necesita el FlipCard, hay un refresh
                  // _flipCard();
                }), // Regresa al frente
          ),
        if (optionRequestUpload)
          IconButton(
            color: IndigoTheme.primaryColor,
            iconSize: 20.0,
            padding: EdgeInsets.all(0.0),
            constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
            icon: const Icon(Icons.upload, size: 20.0),
            onPressed:
                () => FolderHandler.showRequestFilesDialog(
                  context,
                  folder.name.split('/'),
                  () => {},
                  folder,
                ),
          ),
        if (optionDeleteFolder)
          IconButton(
            color: IndigoTheme.primaryColor,
            iconSize: 20.0,
            padding: EdgeInsets.all(0.0),
            constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
            icon: const Icon(Icons.delete, size: 20.0),
            onPressed:
                () => FolderHandler.showDeleteDialog(
                  context,
                  folder.name.split('/'),
                ).then((_) {
                  // No necesita el FlipCard, hay un refresh
                  // _flipCard();
                }), // Regresa al frente
          ),
        if (optionShareFolder)
          IconButton(
            color: IndigoTheme.primaryColor,
            iconSize: 20.0,
            padding: EdgeInsets.all(0.0),
            constraints: BoxConstraints(minWidth: 32.0, minHeight: 32.0),
            icon: const Icon(Icons.share, size: 20.0),
            onPressed: () {
              FolderHandler.onShared(
                context: context,
                folder: folder,
                flipCard: () => {},
              );
            },
          ),
      ],
    );
  }
}

class TitleFolder extends StatefulWidget {
  const TitleFolder({super.key, required this.folder});

  final FolderItem folder;

  @override
  State<TitleFolder> createState() => _TitleFolderState();
}

class _TitleFolderState extends State<TitleFolder> {
  bool _isProcessingTap = false;

  @override
  Widget build(BuildContext context) {
    final stateBoolProvider = Provider.of<StateBoolProvider>(context);

    return GestureDetector(
      onTap: () async {
        if (_isProcessingTap) {
          return; // Evita la ejecución si ya se está procesando un tap
        }
        _isProcessingTap = true;
        await FolderHandler.onGo(
          context,
          name: widget.folder.name.split('/'),
        ).then((_) {
          // _isProcessingTap = false;
        });
      },
      child: Row(
        children: [
          Icon(
            Icons.folder,
            color:
                stateBoolProvider.stateBool
                    ? IndigoTheme.primaryColor
                    : IndigoTheme.hoverColor,
          ),
          const SizedBox(width: 5),
          Text(
            widget.folder.name.split('/').last,
            style: TextStyle(
              color:
                  stateBoolProvider.stateBool
                      ? IndigoTheme.primaryFullColor
                      : IndigoTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
