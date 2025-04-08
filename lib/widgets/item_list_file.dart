import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/providers/state_bool.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/enums/enum_option.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:dropbucket_flutter/utils/file_handler.dart';
import 'package:file_icon/file_icon.dart';

class ItemListFile extends StatelessWidget {
  final FileItem file;

  const ItemListFile({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final bool optionEditFile = EnumOption.hasOption(
      authProvider.user?.options,
      'file_edit',
    );
    final bool optionShareFile = EnumOption.hasOption(
      authProvider.user?.options,
      'file_share',
    );
    final bool optionDeleteFile = EnumOption.hasOption(
      authProvider.user?.options,
      'file_delete',
    );
    final bool optionDownloadFile = EnumOption.hasOption(
      authProvider.user?.options,
      'file_download',
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
                        TitleFile(file: file),
                        Row(
                          children: [
                            if (optionEditFile)
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
                                    () => FileHandler.showEditFileDialog(
                                      context,
                                      file: file,
                                      name: file.name.split('/'),
                                    ).then((_) {
                                      // No necesita el FlipCard, hay un refresh
                                      // _flipCard();
                                    }),
                              ),
                            if (optionDownloadFile)
                              IconButton(
                                color: IndigoTheme.primaryColor,
                                iconSize: 20.0,
                                padding: EdgeInsets.all(0.0),
                                constraints: BoxConstraints(
                                  minWidth: 32.0,
                                  minHeight: 32.0,
                                ),
                                icon: const Icon(Icons.download, size: 20.0),
                                onPressed:
                                    () => FileHandler.onDownloadFile(
                                      context: context,
                                      file: file,
                                      flipCard: () => {},
                                    ),
                              ),
                            if (optionDeleteFile)
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
                                    () => FileHandler.showDeleteDialog(
                                      context,
                                      file,
                                      file.name.split('/'),
                                    ).then((_) {
                                      // No necesita el FlipCard, hay un refresh
                                      // _flipCard();
                                    }), // Regresa al frente
                              ),
                            if (optionShareFile)
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
                                  FileHandler.onShared(
                                    context: context,
                                    file: file,
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

class TitleFile extends StatelessWidget {
  const TitleFile({super.key, required this.file});

  final FileItem file;

  @override
  Widget build(BuildContext context) {
    final stateBoolProvider = Provider.of<StateBoolProvider>(context);

    return GestureDetector(
      onTap: () => FileHandler.tapFile(context, file: file, flipCard: () => {}),
      child: Row(
        children: [
          FileIcon('.${file.extension}', size: 26),
          SizedBox(width: 5),
          Text(
            file.name.split('/').last,
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
