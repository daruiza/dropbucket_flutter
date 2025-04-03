import 'package:dropbucket_flutter/models/user_response.dart';

enum EnumOption {
  users(Option(id: 1, name: 'users')),
  folderCreate(Option(id: 2, name: 'folder_create')),
  folderEdit(Option(id: 3, name: 'folder_edit')),
  folderDelete(Option(id: 4, name: 'folder_delete')),
  folderRequestUpload(Option(id: 5, name: 'folder_request_upload')),
  fileEdit(Option(id: 6, name: 'file_edit')),
  fileDelete(Option(id: 7, name: 'file_delete')),
  fileShare(Option(id: 8, name: 'file_share')),
  fileDownload(Option(id: 9, name: 'file_download')),
  fileUpload(Option(id: 10, name: 'file_upload'));

  final Option option;

  const EnumOption(this.option);

  static bool hasOption(List<Option>? options, String option) {
    // Verifica si 'option' es nulo o está vacío
    if (option.isEmpty) return false;

    // Verifica si la lista 'options' es nula o vacía
    if (options == null || options.isEmpty) return false;

    // Usa 'any' para comprobar si algún elemento cumple la condición
    return options.any((opt) => opt.name == option);
  }
}
