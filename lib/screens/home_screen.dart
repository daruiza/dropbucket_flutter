import 'package:dropbucket_flutter/screens/bucket_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dropbucket_flutter/app_bar_menu.dart';
import 'package:dropbucket_flutter/utils/file_handler.dart';
import 'package:dropbucket_flutter/providers/providers.dart';
import 'package:dropbucket_flutter/utils/folder_handler.dart';
import 'package:dropbucket_flutter/enums/enum_option.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:desktop_drop/desktop_drop.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final optionCreateFolder = EnumOption.hasOption(
      authProvider.user?.options ?? [],
      'folder_create',
    );
    final optionUploadFile = EnumOption.hasOption(
      authProvider.user?.options ?? [],
      'file_upload',
    );

    return Scaffold(
      appBar: AppBarMenu(
        // TODO: colocar el Breadcrumb aqui en el medio
        title: 'Home',
        actions: [],
      ),
      body: BucketScreen(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (optionUploadFile)
            FloatingActionButton(
              heroTag: 'upload_file_button', // Tag único
              child: Icon(
                Icons.upload_file,
                color: IndigoTheme.texContrastColor,
              ),
              onPressed: () => FileHandler.onUploadFiles(context),
            ),
          const SizedBox(height: 16),
          if (optionCreateFolder) // Espacio entre los botones
            FloatingActionButton(
              heroTag: 'create_folder_button',
              child: Icon(
                Icons.create_new_folder,
                color: IndigoTheme.texContrastColor,
              ),
              onPressed: () => FolderHandler.showNewFolderDialog(context),
            ),
        ],
      ),
    );
  }

  Widget buildDropzone({required BuildContext context, required Widget child}) {
    return Stack(
      children: [
        Positioned.fill(
          child: DropTarget(
            onDragDone: (DropDoneDetails detail) {
              List<DropItem> files = detail.files;
              FileHandler.onUploadBlobFiles(context, files: files);
            },
            onDragEntered: (detail) {
              print('onDragEntered');
            },
            onDragExited: (detail) {
              print('Goodbay');
            },
            child: child,
          ),
        ),
        // child,
      ],
    );
  }
}
