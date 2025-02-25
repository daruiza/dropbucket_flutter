class FileItem {
  final String name;
  final String extension;
  final DateTime lastModified;
  final int size;

  FileItem({
    required this.name,
    required this.extension,
    required this.lastModified,
    required this.size,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      name: json['Name'],
      extension: json['Extension'],
      lastModified: DateTime.parse(json['LastModified']),
      size: json['Size'],
    );
  }
}

class FolderItem {
  final String name;
  final int? size;

  FolderItem({
    required this.name,
    this.size,
  });

  factory FolderItem.fromJson(Map<String, dynamic> json) {
    return FolderItem(
      name: json['Name'].endsWith('/') ? json['Name'].substring(0, json['Name'].length - 1) : json['Name'],
      size: json['Size']
    );
  }
}

class ApiResponse {
  final List<FileItem> files;
  final List<FolderItem> folders;

  ApiResponse({
    required this.files,
    required this.folders,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      files: (json['files'] as List)
          .map((file) => FileItem.fromJson(file))
          .toList(),
      folders: (json['folders'] as List)
          .map((folder) => FolderItem.fromJson(folder))
          .toList(),
    );
  }

  get length => null;
}


// {
//   "files":[
//     {
//        "Key":"Goald.png",
//        "LastModified":"2024-10-10T13:44:49.000Z",
//        "Size":335948
//     },
//     {
//        "Key":"SkillBuilder.png",
//        "LastModified":"2024-10-10T13:44:48.000Z",
//        "Size":352263}
//   ],
//   "folders":[
//     "documentation/",
//     "users/"
//   ]
// }