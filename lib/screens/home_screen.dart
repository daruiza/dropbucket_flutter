import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropbucket_flutter/app_bar_menu.dart';
import 'package:dropbucket_flutter/services/services.dart';
import 'package:dropbucket_flutter/widgets/breadcrumb.dart';
import 'package:dropbucket_flutter/widgets/card_file.dart';
import 'package:dropbucket_flutter/widgets/card_folder.dart';
import 'package:dropbucket_flutter/utils/file_handler.dart';
import 'package:dropbucket_flutter/utils/folder_handler.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:desktop_drop/desktop_drop.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bucketService = Provider.of<BucketService>(context);

    return FutureBuilder(
      future:
          Provider.of<BucketService>(context, listen: false).itemsListFuture(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (bucketService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data.'));
        }
        // Variables iniciales
        final files = bucketService.items.files;
        final folders = bucketService.items.folders;
        final isDesktop = MediaQuery.of(context).size.width >= 600;
        final crossAxisCount = isDesktop ? 12 : 3;

        return Scaffold(
          appBar: AppBarMenu(
            // TODO: colocar el Breadcrumb aqui en el medio
            title: 'Home',
            actions: [],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Breadcrumb(
                    fetchItemsList: () {
                      bucketService.itemsList();
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: buildDropzone(
                        context: context,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                mainAxisExtent: 120,
                              ),
                          itemCount: folders.length + files.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (index < folders.length) {
                              return CardFolder(folder: folders[index]);
                            } else {
                              return CardFile(
                                file: files[index - folders.length],
                                fetchItemsList: () {
                                  bucketService.itemsList();
                                },
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'upload_file_button', // Tag único
                child: Icon(
                  Icons.upload_file,
                  color: IndigoTheme.texContrastColor,
                ),
                onPressed: () => FileHandler.onUploadFiles(context),
              ),
              const SizedBox(height: 16), // Espacio entre los botones
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
      },
    );
  }

  Widget buildDropzone({required BuildContext context, required Widget child}) {
    return Stack(
      children: [
        Positioned.fill(
          child: DropTarget(
            onDragDone: (DropDoneDetails detail) {
              List<DropItem> files = detail.files;
              // print('onDragDone');
              // print(files.length);
              // files.forEach((DropItem file) {
              //   print(file.name);
              //   print(file.path);
              //   print(file.readAsBytes());
              // });

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
