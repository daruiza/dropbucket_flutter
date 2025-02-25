import 'package:dropbucket_flutter/app_bar_menu.dart';
import 'package:dropbucket_flutter/providers/providers.dart';
import 'package:dropbucket_flutter/services/services.dart';
import 'package:dropbucket_flutter/widgets/breadcrumb.dart';
import 'package:dropbucket_flutter/widgets/card_file.dart';
import 'package:dropbucket_flutter/widgets/card_folder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bucketService = Provider.of<BucketService>(context);

    return FutureBuilder(
      // future: Provider.of<BucketService>(context, listen: false).fetchItemsList(),
      future: null,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (bucketService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        // Variables iniciales
        final files = bucketService.items.files;
        final folders = bucketService.items.folders;
        final isDesktop = MediaQuery.of(context).size.width >= 600;
        final crossAxisCount = isDesktop ? 12 : 3;

        return Scaffold(
          appBar: AppBarMenu(
            // TODO: colocar el Breadcrumb aqui en el medio
            title: Text(authProvider.user?.name ?? 'Home'),
            actions: [],
          ),
          body: Column(
            children: [
              Breadcrumb(
                fetchItemsList: () {
                  bucketService.itemsList();
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 120,
                    ),
                    itemCount: folders.length + files.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < folders.length) {
                        return CardFolder(
                          folder: folders[index],
                          fetchItemsList: () {
                            bucketService.itemsList();
                          },
                        );
                      } else {
                        return CardFile(file: files[index - folders.length]);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          // floatingActionButton: Column(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     FloatingActionButton(
          //       child: Icon(Icons.upload_file, color: IndigoTheme.texContrastColor),
          //       onPressed: () => {},
          //     ),
          //     const SizedBox(height: 16), // Espacio entre los botones
          //     FloatingActionButton(
          //       child: Icon(Icons.create_new_folder, color: IndigoTheme.texContrastColor),
          //       onPressed: () => {},
          //     ),
          //   ],
          // ),
        );
      },
    );
  }
}
