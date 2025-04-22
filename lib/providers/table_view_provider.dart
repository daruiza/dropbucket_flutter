import 'package:flutter/material.dart';

enum TableView {
  grid,  
  list,
}

class TableViewProvider extends ChangeNotifier {
  TableView _view;

  TableViewProvider({TableView initialView = TableView.list}) : _view = initialView;

  TableView get stateView => _view;

  set view(TableView value) {
    _view = value;
    notifyListeners();
  }

  // Opcional: Un getter para obtener el valor como String si es necesario
  String get viewAsString => _view.name.toUpperCase();
  TableView get view => _view;
}