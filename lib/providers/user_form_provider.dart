import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:flutter/material.dart';

class UserFormProvider extends ChangeNotifier {
  GlobalKey<FormState> userFormKey = GlobalKey<FormState>();

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  ValueNotifier<Rol?> rol = ValueNotifier<Rol?>(null);
  TextEditingController rolId = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController textRol = TextEditingController();
  TextEditingController names = TextEditingController();
  TextEditingController lastnames = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController theme = TextEditingController();
  TextEditingController prefix = TextEditingController();
  TextEditingController photo = TextEditingController();

  TextEditingController photoExists = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setUser({UserResponse? user, String? password, List<Rol>? rols}) {
    if (password != null) this.password.text = password;
    if (user != null) {
      email.text = user.email;
      rol.value = user.rol;
      rolId.text = user.rolId.toString();
      name.text = user.name;
      names.text = user.names ?? '';
      lastnames.text = user.lastnames ?? '';
      phone.text = user.phone ?? '';
      theme.text = user.theme ?? '';
      prefix.text = user.prefix ?? '';
      photo.text = user.photo ?? '';
      // Asignación de Rol
      if (rols != null) {
        rol.value = rols.where((rol) => rol.id == user.rol.id).first;
      }
    }
  }

  bool isValidForm() {
    return userFormKey.currentState?.validate() ?? false;
  }
}
