import 'dart:convert';

import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:dropbucket_flutter/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:dropbucket_flutter/app_bar_menu.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';
import 'package:dropbucket_flutter/providers/profile_form_provider.dart';
import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:dropbucket_flutter/utils/validators.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  void _toggleEditMode(bool value) {
    setState(() {
      _isEditing = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(        
        title: 'Profile',
        actions: [
          Transform.scale(
            scale: 0.7,
            child: Switch.adaptive(
              value: _isEditing,
              onChanged: (value) => _toggleEditMode(value),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth =
              constraints.maxWidth > 600 ? 500 : constraints.maxWidth * 0.8;
          return Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ChangeNotifierProvider(
                  create: (_) => ProfileFormProvider(),
                  child: _ProfileForm(
                    isEditing: _isEditing,
                    maxWidth: maxWidth,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileForm extends StatelessWidget {
  final bool isEditing;
  final double maxWidth;
  const _ProfileForm({required this.isEditing, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileForm = Provider.of<ProfileFormProvider>(context);

    profileForm.setUserProfile(authProvider.user);

    return FutureBuilder(
      future: _photoExist(context),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Indicador de carga
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data profile.'));
        }

        profileForm.photoExists.text = snapshot.data ? 'true' : 'false';

        return Form(
          key: profileForm.profileFormKey,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: 2 * maxWidth / 3 - 20,
                      child: Column(
                        children: [
                          TextFormField(
                            enabled: isEditing,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            keyboardType: TextInputType.emailAddress,
                            controller: profileForm.email,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              floatingLabelStyle: TextStyle(
                                color:
                                    isEditing
                                        ? IndigoTheme.primaryColor
                                        : IndigoTheme.disableColor,
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color:
                                    isEditing
                                        ? IndigoTheme.primaryColor
                                        : IndigoTheme.disableColor,
                              ),
                            ),
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
                            enabled: isEditing,
                            keyboardType: TextInputType.text,
                            controller: profileForm.name,
                            decoration: InputDecoration(
                              labelText: 'Nombre de usuario',
                              floatingLabelStyle: TextStyle(
                                color:
                                    isEditing
                                        ? IndigoTheme.primaryColor
                                        : IndigoTheme.disableColor,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color:
                                    isEditing
                                        ? IndigoTheme.primaryColor
                                        : IndigoTheme.disableColor,
                              ),
                            ),
                            validator: (value) {
                              if (Validators.required(value)) {
                                return 'Este campo es requerido';
                              }
                              if (value != null && value.length <= 3) {
                                return 'El campo debe ser mayor a 3';
                              }
                              if (value != null && value.length >= 16) {
                                return 'El campo debe ser menor a 16';
                              }
                              return null;
                            }
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: maxWidth / 3 - 20,
                        child: MouseRegion(
                          cursor:
                              isEditing
                                  ? SystemMouseCursors.click
                                  : SystemMouseCursors.basic,
                          child: GestureDetector(
                            onTap:
                                () =>
                                    isEditing ? _onUploadImage(context) : null,
                            child:
                                profileForm.photoExists.text == 'true'
                                    ? Center(
                                      child: Stack(
                                        children: [
                                          // CircleAvatar base
                                          CircleAvatar(
                                            maxRadius: 50,
                                            backgroundImage: NetworkImage(
                                              profileForm.photo.text,
                                            ),
                                          ),
                                          if (!isEditing)
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  // color: Color(0x80808080), // Gris medio, 50% opacidad
                                                  // color: Color(0x60808080), // Gris medio, 38% opacidad
                                                  // color: Color(0xA0808080), // Gris medio, 63% opacidad
                                                  // color: Color(0x80A0A0A0), // Gris claro, 50% opacidad
                                                  // color: Color(0x80606060), // Gris oscuro, 50% opacidad
                                                  color: Color(
                                                    0x80909090,
                                                  ), // Gris plateado, 50% opacidad
                                                  // color: Color(0x40808080), // Gris medio, 25% opacidad
                                                  // color: Color(0xC0808080), // Gris medio, 75% opacidad
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                    : Icon(
                                      Icons.person,
                                      size: 96,
                                      color:
                                          isEditing
                                              ? IndigoTheme.primaryColor
                                              : IndigoTheme.disableColor,
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // GestureDetector(),
                const SizedBox(height: 20),
                TextFormField(
                  enabled: isEditing,
                  keyboardType: TextInputType.text,
                  controller: profileForm.names,
                  decoration: InputDecoration(
                    labelText: 'Nombres',
                    floatingLabelStyle: TextStyle(
                      color:
                          isEditing
                              ? IndigoTheme.primaryColor
                              : IndigoTheme.disableColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  enabled: isEditing,
                  keyboardType: TextInputType.text,
                  controller: profileForm.lastnames,
                  decoration: InputDecoration(
                    labelText: 'Apellidos',
                    floatingLabelStyle: TextStyle(
                      color:
                          isEditing
                              ? IndigoTheme.primaryColor
                              : IndigoTheme.disableColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  enabled: isEditing,
                  keyboardType: TextInputType.text,
                  controller: profileForm.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    floatingLabelStyle: TextStyle(
                      color:
                          isEditing
                              ? IndigoTheme.primaryColor
                              : IndigoTheme.disableColor,
                    ),
                    prefixIcon: Icon(
                      Icons.phone,
                      color:
                          isEditing
                              ? IndigoTheme.primaryColor
                              : IndigoTheme.disableColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  enabled: isEditing,
                  keyboardType: TextInputType.text,
                  controller: profileForm.theme,
                  decoration: InputDecoration(
                    labelText: 'Estilo/Tema de aplicación',
                    floatingLabelStyle: TextStyle(
                      color:
                          isEditing
                              ? IndigoTheme.primaryColor
                              : IndigoTheme.disableColor,
                    ),
                    prefixIcon: Icon(
                      Icons.style,
                      color:
                          isEditing
                              ? IndigoTheme.primaryColor
                              : IndigoTheme.disableColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        !isEditing
                            ? WidgetStateProperty.all(IndigoTheme.disableColor)
                            : null,
                  ),
                  onPressed: isEditing ? () => userEdit(context) : null,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(child: Text('Editar')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _photoExist(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bucketService = Provider.of<BucketService>(context, listen: false);
    try {
      if (authProvider.user?.photo != null && authProvider.user?.photo != '') {
        final existFile = await bucketService.existFile(
          authProvider.user?.photo?.split('.com/')[1] ?? '',
        );
        return jsonDecode(existFile.body)['exist'] ?? false;
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message.fromJson({"error": e.toString(), "statusCode": 400}),
        );
      }
      return false;
    }
  }

  Future<void> _onUploadImage(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bucketService = Provider.of<BucketService>(context, listen: false);
    final profileForm = Provider.of<ProfileFormProvider>(
      context,
      listen: false,
    );

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      withData: true, //Fuerza la carga de los datos en memoria
    );

    if (result != null) {
      try {
        final allowedMimeTypes = [
          'image/jpeg',
          'image/png',
          'image/gif',
          'jpg',
          'jpeg',
          'png',
          'gif',
        ];
        if (result.files.single.bytes != null) {
          final file = result.files.first;
          final oldFileName = profileForm.photo.text.split('/').last;

          if (!allowedMimeTypes.contains(
            file.extension.toString().toLowerCase(),
          )) {
            throw Exception('Formato de archivo no válido');
          }
          // context.loaderOverlay.show();
          final response = await bucketService.storeFile(
            file: file,
            prefix: 'users',
          );

          final json = jsonDecode(response.body);

          if (context.mounted) {
            MessageProvider.showSnackBarContext(
              context,
              Message(
                messages: ['Archivo: ${json['key'] ?? ''}!'],
                message: 'Carga exitosa',
                statusCode: HttpStatusColor.success200.code,
              ),
            );
          }

          if (json['url'].isNotEmpty) {
            profileForm.photo.text = json['url'];
            profileForm.photoExists.text = 'true';
            if (context.mounted) {
              try {
                await userPatch(context);
                await authProvider.checkToken();
                // Notifica y vuelve a recargar el build
                profileForm.notifyListeners();
              } on Exception catch (e) {
                if (context.mounted) {
                  MessageProvider.showSnackBarContext(
                    context,
                    Message.fromJson({
                      "error": e.toString(),
                      "statusCode": 400,
                    }),
                  );
                }
              }
            }

            // Eliminar archivo anterior
            if (oldFileName != '') {
              await bucketService.deleteFile(
                null,
                file: FileItem(
                  name: 'users/$oldFileName',
                  extension: file.name.split('.').last,
                  lastModified: DateTime.now(),
                  size: 0,
                ),
                fileName: 'users/$oldFileName',
              );
            }
          }
        } else {
          // Para plataformas no web (path)
          // final file = File(result.files.single.path!);
        }
        // context.loaderOverlay.hide();
      } on Exception catch (e) {
        if (context.mounted) {
          MessageProvider.showSnackBarContext(
            context,
            Message.fromJson({"error": e.toString(), "statusCode": 400}),
          );
        }
        // context.loaderOverlay.hide();
      }
    }
  }

  Future<void> userEdit(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final profileForm = Provider.of<ProfileFormProvider>(
      context,
      listen: false,
    );

    bool valdiate =
        profileForm.profileFormKey.currentState?.validate() ?? false;
    if (!valdiate) {
      return;
    }

    try {
      // context.loaderOverlay.show();
      await userPatch(context).then((_) {});
      // Refrescamos el formulario con la nueva data
      // Actulizar el authProvider, bien aqui
      await authProvider.checkToken();
      profileForm.setUserProfile(authProvider.user);
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message(
            messages: ['Usurio editado correctamente'],
            message: 'Edisión exitosa',
            statusCode: HttpStatusColor.success200.code,
          ),
        );
      }
      // context.loaderOverlay.hide();
    } on Exception catch (e) {
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message.fromJson({"error": e.toString(), "statusCode": 400}),
        );
      }
      // context.loaderOverlay.hide();
    }
  }

  Future<void> userPatch(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final userService = Provider.of<UserService>(context, listen: false);
    final userService = UserService(context);
    final profileForm = Provider.of<ProfileFormProvider>(
      context,
      listen: false,
    );
    // Validamos que los campos no estén vacíos
    await userService.userPatchProfile(
      UserResponse(
        id: authProvider.user?.id ?? '1',
        email: profileForm.email.text,
        name: profileForm.name.text,
        names: profileForm.names.text,
        lastnames: profileForm.lastnames.text,
        phone: profileForm.phone.text,
        theme: profileForm.theme.text,
        prefix: profileForm.prefix.text,
        photo: profileForm.photo.text,
        rol: authProvider.user?.rol ?? Rol(id: '1', name: '', description: ''),
        rolId: authProvider.user?.rolId ?? '1',
        options: authProvider.user?.options ?? [],
        token: authProvider.user?.token ?? '',
      ),
    );

    // authProvider.user
  }
}
