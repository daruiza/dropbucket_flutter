import 'package:dropbucket_flutter/route.dart';
import 'package:dropbucket_flutter/services/services.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() => runApp(const AppState());

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => AuthService()),
        //ChangeNotifierProvider(create: (context) => AuthService(context)),
        ChangeNotifierProvider(create: (context) => BucketService(context)),
        ChangeNotifierProvider(create: (context) => UserService(context)),
        ChangeNotifierProvider(create: (context) => TableViewProvider()),
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: MessageProvider.scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'DropBucket',
      theme: IndigoTheme.lightTheme,
      initialRoute: Routes.initialRoute,
      onGenerateRoute: Routes.onGenerateRoute,
      routes: Routes.getRoutes(context),
    );
  }
}
