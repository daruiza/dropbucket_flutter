import 'package:flutter/material.dart';

class StateBoolProvider extends ChangeNotifier {
  bool _stateBool;

  StateBoolProvider({bool initialState = false}) : _stateBool = initialState;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  bool get stateBool => _stateBool;
  set stateBool(bool value) {
    _stateBool = value;
    notifyListeners();
  }
}
