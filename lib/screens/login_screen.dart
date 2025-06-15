import 'package:dio/dio.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dropbucket_flutter/services/auth_service.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:dropbucket_flutter/providers/login_form_provider.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/utils/validators.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    // Este código se ejecutará después de que el build se complete
    Future.microtask(() {
      if (context.mounted) {
        _showGoodbyeMessageIfNeeded(context, args);
      }
    });

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth > 600
                          ? 400
                          : constraints.maxWidth * 0.8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth > 600
                              ? constraints.maxWidth * 0.16
                              : constraints.maxWidth * 0.6,
                          child: Image.network(
                            'https://dropbucket-asistir-aws.s3.amazonaws.com/images/logoasistirpng.png',
                          ),
                        ),
                        const SizedBox(height: 40),
                        ChangeNotifierProvider(
                          create: (_) => LoginFormProvider(),
                          child: _LoginForm(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  // const _LoginForm({super.key});
  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    return Form(
      key: loginForm.loginFormKey,
      child: Column(
        children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email, color: IndigoTheme.primaryColor),
            ),
            controller: loginForm.email,
            // onChanged: (value) => loginForm.email = value,
            onFieldSubmitted: (value) {
              _login(context, loginForm);
            },
            validator: (value) {
              if (Validators.required(value)) {
                return 'Este campo es requerido';
              }
              if (Validators.email(value)) {
                return 'El Email no es valido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock, color: IndigoTheme.primaryColor),
            ),
            controller: loginForm.password,
            // onChanged: (value) => loginForm.password = value,
            onFieldSubmitted: (value) {
              _login(context, loginForm);
            },
            validator: (value) {
              if (Validators.required(value)) {
                return 'Este campo es requerido';
              }
              if (Validators.minLength(value, 4)) {
                return 'El campo requiere más caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: loginForm.isLoading
                ? null
                : () {
                    _login(context, loginForm);
                  },
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(loginForm.isLoading ? 'Espera...' : 'Ingresar'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login(BuildContext context, LoginFormProvider loginForm) async {
    FocusScope.of(context).unfocus(); // Para quitar el teclado visual

    final authService = Provider.of<AuthService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bucketService = Provider.of<BucketService>(context, listen: false);

    if (!loginForm.isValidForm()) {
      return;
    }
    loginForm.isLoading = true;
    try {
      await authService.loginUser(
        loginForm.email.text.trim(),
        loginForm.password.text.trim(),
      );
      // Luego de hacer login, bien asignar variables
      await authProvider.checkToken();

      String uri = Uri.base.toString();

      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message(
            message: '¡Bienvenido ${authProvider.user?.name ?? ''}!',
            statusCode: HttpStatusColor.success200.code,
            messages: [],
          ),
        );

        await bucketService.itemsList();

        // Solo para rutas web
        if (uri.contains('http')) {
          if (!uri.contains('login') && !uri.contains('home')) {
            Navigator.pushReplacementNamed(context, uri.split('/#').last);
            return;
          }
        }

        Navigator.pushReplacementNamed(
          context,
          'home',
          // arguments: {'welcome': true},
        );
        return;
      }
    } on DioException catch (e) {
      try {
        if (context.mounted) {
          MessageProvider.showSnackBarContext(
            context,
            Message.fromJson(e.response?.data),
            //Message.fromString(e.toString()),
          );
        }

        // FORMA ANTIGUA DE MOSTRAR LOS MENSAJES.
        // final message = Message.fromString(e.toString());
        // // MessageProvider.showSnackBar(message);
        // if (context.mounted) {
        //   MessageProvider.showSnackBarContext(context, message);
        // }
      } catch (e) {
        if (context.mounted) {
          MessageProvider.showSnackBarContext(
            context,
            Message.fromJson({"error": e.toString(), "statusCode": 400}),
          );
        }
      }
    } finally {
      loginForm.isLoading = false;
    }
  }
}

void _showGoodbyeMessageIfNeeded(BuildContext context, dynamic args) {
  if (args != null && args is Map<String, dynamic> && args['welcome'] == true) {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final userName = authProvider.user?.name ?? 'Usuario';

    // Mostramos el mensaje de bienvenida
    MessageProvider.showSnackBarContext(
      context,
      Message(
        message: '¡Hasta pronto!',
        statusCode: HttpStatusColor.success200.code,
        messages: [],
      ),
    );
  }
}
