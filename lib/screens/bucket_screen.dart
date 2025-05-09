import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dropbucket_flutter/widgets/card_file.dart';
import 'package:dropbucket_flutter/widgets/card_folder.dart';
import 'package:dropbucket_flutter/widgets/item_list_file.dart';
import 'package:dropbucket_flutter/widgets/item_list_folder.dart';

import '../services/services.dart' show BucketService;
import 'package:dropbucket_flutter/providers/providers.dart';

class BucketScreen extends StatelessWidget {
  const BucketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bucketService = Provider.of<BucketService>(context);
    final tableViewProvider = Provider.of<TableViewProvider>(context);

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
        

        return Stack(
          children: [
            Column(
              children: [
                // Breadcrumb(
                //   fetchItemsList: () {
                //     bucketService.itemsList();
                //   },
                //   primaryColor: IndigoTheme.primaryColor ?? Colors.blue,
                //   hoverColor: IndigoTheme.primaryFullColor ?? Colors.blueAccent,
                //   iconColor: IndigoTheme.primaryFullColor ?? Colors.blue,
                //   fontSize: 12.0
                // ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child:
                        // buildDropzone(
                        //   context: context,
                        //   child:
                        tableViewProvider.view == TableView.grid
                            ? GridView.builder(
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
                                  );
                                }
                              },
                            )
                            : tableViewProvider.view == TableView.list
                            ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 160),
                              itemCount: folders.length + files.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (index < folders.length) {
                                  return ItemListFolder(folder: folders[index]);
                                } else {
                                  return ItemListFile(
                                    file: files[index - folders.length],
                                  );
                                }
                              },
                            )
                            : Container(),
                    // ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
