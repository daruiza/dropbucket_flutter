import 'package:dropbucket_flutter/models/bucket_response.dart';
import 'package:flutter/material.dart';

class CardFile extends StatelessWidget {
  final FileItem file;
  const CardFile({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Text(file.name);
  }
}
