import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropbucket_flutter/route.dart';
import 'package:dropbucket_flutter/widgets/breadcrumb.dart';
import 'package:dropbucket_flutter/providers/providers.dart';
import 'package:dropbucket_flutter/services/services.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/enums/enum_option.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:dropbucket_flutter/utils/message.dart';

class AppBarMenu extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double elevation;

  const AppBarMenu({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final bucketService = Provider.of<BucketService>(context, listen: false);

    final tableViewProvider = Provider.of<TableViewProvider>(
      context,
      listen: false,
    );

    final prefix = authProvider.user?.prefix ?? '';
    final prefixcurrent = authProvider.user?.prefixcurrent ?? '';
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    final optionUser = EnumOption.hasOption(
      authProvider.user?.options ?? [],
      'users',
    );

    return AppBar(
      title: Row(
        children: [
          Text(authProvider.user?.name ?? title),
          SizedBox(width: 20),
          Expanded(
            child: Breadcrumb(
              fetchItemsList: () {
                bucketService.itemsList();
              },
              primaryColor: IndigoTheme.texContrastColor ?? Colors.blue,
              hoverColor: IndigoTheme.primaryFullColor ?? Colors.blueAccent,
              iconColor: IndigoTheme.texContrastColor ?? Colors.blueAccent,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
      actions: [
        // FolderReturn
        if (prefixcurrent.length > prefix.length && currentRoute == Routes.home)
          IconButton(
            icon: Icon(Icons.arrow_back, color: IndigoTheme.texContrastColor),
            onPressed:
                () => folderBack(context, prefix, prefixcurrent, () {
                  bucketService.itemsList();
                }),
          ),
        if (authProvider.isAuthenticated &&
            (currentRoute == Routes.profile || currentRoute == Routes.users))
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.home);
            },
            icon: Icon(Icons.home, color: IndigoTheme.texContrastColor),
          ),
        ...actions ?? [],
        if (currentRoute == Routes.home)
          IconButton(
            icon: Icon(
              Icons.format_line_spacing_outlined,
              color: IndigoTheme.texContrastColor,
            ),
            onPressed: () {
              final TableView view =
                  tableViewProvider.view == TableView.grid
                      ? TableView.list
                      : TableView.grid;
              tableViewProvider.view = view;
            },
          ),
        if (currentRoute != Routes.users && optionUser)
          IconButton(
            icon: Icon(
              Icons.workspaces_rounded,
              color: IndigoTheme.texContrastColor,
            ),
            onPressed:
                () => Navigator.pushReplacementNamed(context, Routes.users),
          ),
        if (authProvider.isAuthenticated && currentRoute != Routes.profile)
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.profile);
            },
            icon: Icon(Icons.person, color: IndigoTheme.texContrastColor),
          ),
        if (authProvider.isAuthenticated)
          IconButton(
            icon: Icon(Icons.logout, color: IndigoTheme.texContrastColor),
            onPressed: () => logOut(context, authService, authProvider),
          ),
      ],
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      elevation: elevation,
    );
  }

  Future<void> logOut(
    BuildContext context,
    AuthService authService,
    AuthProvider authProvider,
  ) async {
    await authService.logoutUser();
    await authProvider.checkToken();

    if (context.mounted) {
      MessageProvider.showSnackBarContext(
        context,
        Message(
          message: '¡Hasta pronto!',
          statusCode: HttpStatusColor.success200.code,
          messages: [],
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        'login',
        // arguments: {'goodbay': true},
      );
    }
  }

  Future<void> folderBack(
    BuildContext context,
    String prefix,
    String prefixcurrent,
    Function fetchItemsList,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (prefixcurrent.length > prefix.length) {
      List<String> parts = prefixcurrent.split('/');
      parts.removeWhere((part) => part.isEmpty);
      if (parts.isEmpty) return;

      parts.removeLast();
      String result = '${parts.join('/')}/';
      result = result == '/' ? '' : result;

      // if (!mounted) return;
      // context.loaderOverlay.show();

      try {
        await authProvider.setUserPrefix(context, result, true);
        await fetchItemsList();
      } finally {
        // if (mounted) context.loaderOverlay.hide();
      }
    }

    //
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
