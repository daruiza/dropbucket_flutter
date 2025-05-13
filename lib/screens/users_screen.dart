import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/user_service.dart';
import 'package:dropbucket_flutter/app_bar_menu.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:dropbucket_flutter/utils/user_handler.dart';
import 'package:dropbucket_flutter/widgets/card_user.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    return FutureBuilder(
      future: userService.itemsListFuture(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data users.'));
        }

        final users = userService.items;
        final isDesktop = MediaQuery.of(context).size.width >= 600;
        final crossAxisCount = isDesktop ? 12 : 3;

        return Scaffold(
          appBar: AppBarMenu(
            title: 'Usuarios',
            actions: [
              // IconButton(
              //   icon: Icon(
              //     Icons.person_add,
              //     color: IndigoTheme.texContrastColor,
              //   ),
              //   onPressed: onUserCreate,
              // ),
            ],
          ),
          body: Column(
            children: [
              Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 120,
                    ),
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CardUser(user: users[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'handler_user_button', // Tag único
                child: Icon(
                  Icons.person_add,
                  color: IndigoTheme.texContrastColor,
                ),
                onPressed:
                    () => UserHandler.createUser(context).then((value) {
                      // print('Close createUser');
                    }),
              ),
            ],
          ),
        );
      },
    );
  }
}
