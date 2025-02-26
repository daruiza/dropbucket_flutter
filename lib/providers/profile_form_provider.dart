import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:flutter/material.dart';

class ProfileFormProvider extends ChangeNotifier {
  GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  @override
  void notifyListeners() {
    // TODO: implement notifyListeners
    super.notifyListeners();
  }
  

  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
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

  void setUserProfile(UserResponse? user) {
    if (user != null) {
      email.text = user.email;
      name.text = user.name;
      names.text = user.names ?? '';
      lastnames.text = user.lastnames ?? '';
      phone.text = user.phone ?? '';
      theme.text = user.theme ?? '';
      prefix.text = user.prefix ?? '';
      photo.text = user.photo ?? '';      
    }
  }

  bool isValidForm() {
    return profileFormKey.currentState?.validate() ?? false;
  }
}
