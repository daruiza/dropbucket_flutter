import 'package:dropbucket_flutter/providers/providers.dart';
import 'package:dropbucket_flutter/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthMiddleware extends StatelessWidget {
  final Widget child;
  final Widget Function() onUnauthorized;

  const AuthMiddleware({
    super.key,
    required this.child,
    required this.onUnauthorized,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthProvider>(context, listen: false).checkToken(),
      // future: null,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        final String currentRoute =
            ModalRoute.of(context)?.settings.name ?? '/';

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data auth middeware.'));
        }

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isAuthenticated) {
          return onUnauthorized();
        }

        // Intento de ir al login estado ya logueado
        if (authProvider.isAuthenticated && currentRoute == 'login') {
          return HomeScreen();
        }
        return child;
      },
    );
  }
}
