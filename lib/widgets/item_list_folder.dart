import 'package:flutter/material.dart';

import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/providers/state_bool.dart';
import 'package:dropbucket_flutter/utils/folder_handler.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/enums/enum_option.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:provider/provider.dart';

class ItemListFolder extends StatelessWidget {
  final FolderItem folder;
  const ItemListFolder({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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

    return ChangeNotifierProvider(
      create: (_) => StateBoolProvider(),
      child: Builder(
        builder: (context) {
          final stateBoolProvider = Provider.of<StateBoolProvider>(context);
          return MouseRegion(
            onEnter: (_) => stateBoolProvider.stateBool = true,
            onExit: (_) => stateBoolProvider.stateBool = false,
            cursor: SystemMouseCursors.click,

            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 24.0,
                    left: 24.0,
                    top: 6.0,
                  ),
                  child: Container(
                    color:
                        stateBoolProvider.stateBool
                            ? IndigoTheme.hoverColor
                            : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TitleFolder(folder: folder),
                        Row(
                          children: [
                            if (optionEditFolder)
                              IconButton(
                                color: IndigoTheme.primaryColor,
                                iconSize: 20.0,
                                padding: EdgeInsets.all(0.0),
                                constraints: BoxConstraints(
                                  minWidth: 32.0,
                                  minHeight: 32.0,
                                ),
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
                                constraints: BoxConstraints(
                                  minWidth: 32.0,
                                  minHeight: 32.0,
                                ),
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
                                constraints: BoxConstraints(
                                  minWidth: 32.0,
                                  minHeight: 32.0,
                                ),
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
                                FolderHandler.onShared(
                                  context: context,
                                  folder: folder,
                                  flipCard: () => {},
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: IndigoTheme.primaryLowColor,
                  thickness: 1.0,
                  indent: 16.0,
                  endIndent: 16.0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TitleFolder extends StatelessWidget {
  const TitleFolder({super.key, required this.folder});

  final FolderItem folder;

  @override
  Widget build(BuildContext context) {
    final stateBoolProvider = Provider.of<StateBoolProvider>(context);

    return GestureDetector(
      onTap:
          () => FolderHandler.onGo(context, name: folder.name.split('/')).then((
            _,
          ) {
            // No necesita el FlipCard, hay un refresh
            // _flipCard();
          }),
      child: Row(
        children: [
          Icon(
            Icons.folder,
            color:
                stateBoolProvider.stateBool
                    ? IndigoTheme.primaryColor
                    : IndigoTheme.hoverColor,
          ),
          SizedBox(width: 5),
          Text(
            folder.name.split('/').last,
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
