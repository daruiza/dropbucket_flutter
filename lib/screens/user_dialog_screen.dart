import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:dropbucket_flutter/providers/message_provider.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:dropbucket_flutter/services/bucket_service.dart';
import 'package:dropbucket_flutter/services/rol_service.dart';
import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:dropbucket_flutter/providers/user_form_provider.dart';
import 'package:dropbucket_flutter/utils/validators.dart';
import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropbucket_flutter/themes/indigo.dart';
import 'package:dropbucket_flutter/enums/role_enum.dart';

class UserDialogScreen extends StatelessWidget {
  final UserResponse? user;

  const UserDialogScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth =
              constraints.maxWidth > 600
                  ? constraints.maxWidth * 0.5
                  : constraints.maxWidth * 0.8;
          return SingleChildScrollView(
            child: Container(
              width: maxWidth,
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ChangeNotifierProvider(
                create: (_) => UserFormProvider(),
                child: _UserForm(maxWidth: maxWidth, user: user),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserForm extends StatelessWidget {
  final double maxWidth;
  final UserResponse? user;
  const _UserForm({required this.maxWidth, required this.user});
  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userForm = Provider.of<UserFormProvider>(context);

    return FutureBuilder(
      future: fetchServices(context),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: const CircularProgressIndicator(),
          ); // Indicador de carga
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data.'));
        }

        List<Rol>? rols = snapshot.data['rols'];
        userForm.photoExists.text =
            snapshot.data['photoExist'] ? 'true' : 'false';

        userForm.setUser(user: user, rols: rols);

        return Form(
          key: userForm.userFormKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 2 * maxWidth / 3 - 20,
                      child: Column(
                        children: [
                          SizedBox(
                            width: maxWidth / 1 - 20,
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.emailAddress,
                              controller: userForm.email,
                              decoration: InputDecoration(
                                labelText: 'Correo electrónico',
                                floatingLabelStyle: TextStyle(),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: IndigoTheme.primaryColor,
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
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: maxWidth / 1 - 20,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: userForm.name,
                              decoration: InputDecoration(
                                labelText: 'Nombre de usuario',
                                floatingLabelStyle: TextStyle(),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: IndigoTheme.primaryColor,
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
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: maxWidth / 3 - 20,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _onUploadImage(context),
                            child:
                                userForm.photoExists.text == 'true'
                                    ? Center(
                                      child: Stack(
                                        children: [
                                          // CircleAvatar base
                                          CircleAvatar(
                                            maxRadius: 50,
                                            backgroundImage: NetworkImage(
                                              userForm.photo.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : Icon(
                                      Icons.person,
                                      size: 96,
                                      color: IndigoTheme.primaryColor,
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: maxWidth / 1 - 20,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: userForm.names,
                    decoration: InputDecoration(
                      labelText: 'Nombres',
                      floatingLabelStyle: TextStyle(
                        color: IndigoTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: maxWidth / 1 - 20,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: userForm.lastnames,
                    decoration: InputDecoration(
                      labelText: 'Apellidos',
                      floatingLabelStyle: TextStyle(
                        color: IndigoTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: userForm.phone,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          floatingLabelStyle: TextStyle(
                            color: IndigoTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: userForm.theme,
                        decoration: InputDecoration(
                          labelText: 'Tema',
                          floatingLabelStyle: TextStyle(
                            color: IndigoTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Rol>(
                        decoration: InputDecoration(labelText: 'Rol'),
                        items:
                            rols
                                ?.map(
                                  (rol) => DropdownMenuItem(
                                    value: rol,
                                    child: Text(
                                      rol.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          userForm.rolId.text = '${value?.id}';
                          userForm.rol.value = value;
                        },
                        value: userForm.rol.value,
                        validator: (value) {
                          if (value == null) {
                            return 'Este campo es requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Si el usuario es superadministrador no cambia el prefix
                if (user?.rolId != Role.superadministrador.id)
                  SizedBox(
                    width: maxWidth / 1 - 20,
                    child: TextFormField(
                      controller: userForm.prefix,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(labelText: 'Prefix'),
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> fetchServices(BuildContext context) async {
    final responses = await Future.wait([
      _photoExist(context),
      _getRols(context),
    ]);

    final imageResponse = responses[0];
    final rolesResponse = responses[1];

    return {'photoExist': imageResponse, 'rols': rolesResponse};
  }

  Future<bool> _photoExist(BuildContext context) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    final userForm = Provider.of<UserFormProvider>(context, listen: false);

    final photo = user?.photo ?? userForm.photo.text;
    try {
      if (photo != '') {
        final existFile = await bucketService.existFile(
          photo.split('.com/')[1],
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

  Future<List<Rol>?> _getRols(BuildContext context) async {
    final rolService = RolService(context);
    try {
      return await rolService.rols();
    } catch (e) {
      if (context.mounted) {
        MessageProvider.showSnackBarContext(
          context,
          Message.fromJson({"error": e.toString(), "statusCode": 400}),
        );
      }
      return null;
    }
  }

  Future<void> _onUploadImage(BuildContext context) async {
    final bucketService = Provider.of<BucketService>(context, listen: false);
    final userForm = Provider.of<UserFormProvider>(context, listen: false);

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
          final oldFileName = userForm.photo.text.split('/').last;
          if (!allowedMimeTypes.contains(
            file.extension.toString().toLowerCase(),
          )) {
            throw Exception('Formato de archivo no válido');
          }

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
            userForm.photo.text = json['url'];
            userForm.notifyListeners();
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
}
