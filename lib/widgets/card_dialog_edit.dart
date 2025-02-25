import 'package:flutter/material.dart';

Future<String?> showEditDialog(BuildContext context,
    {required Function flipCard,
    required List<String> name,
    required Function onEditObject}) {
  final String coreName = name.last.split('.')[0];

  TextEditingController textFieldController = TextEditingController(
    text: coreName,
  );
  bool isButtonEnabled = false;

  void validateInput(String input) {
    isButtonEnabled = false;
    if (input == coreName) {
      return;
    }

    // Validar que el texto contenga solo letras y números
    final isValid = RegExp(
            r'^[a-zA-Z0-9][-_a-zA-Z0-9áéíóúÁÉÍÓÚüÜñÑ\s]{0,63}(?<![-_. ])\.?[a-zA-Z0-9]{0,8}$')
        .hasMatch(input);
    // Actualizar el estado local
    isButtonEnabled = isValid && input.isNotEmpty;
  }

  onEdit(String rename) async {
    await onEditObject(rename);
    if (context.mounted) {
      Navigator.pop(context, 'rename');

    }
    flipCard();
  }

  return showDialog<String>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                title: Text(
                  'Editar ${name.last}',
                  style: TextStyle(fontSize: 17.0),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textFieldController,
                      decoration: InputDecoration(
                        hintText: "Nombre de archivo",
                        errorText: textFieldController.text.isEmpty
                            ? null
                            : RegExp(r'^[a-zA-Z0-9][-_a-zA-Z0-9áéíóúÁÉÍÓÚüÜñÑ\s]{0,63}(?<![-_. ])\.?[a-zA-Z0-9]{0,8}$')
                                    .hasMatch(textFieldController.text)
                                ? null
                                : 'Solo letras y números',
                      ),
                      onChanged: (text) {
                        setState(() {
                          validateInput(text);
                        });
                      },
                    )
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: isButtonEnabled
                        ? () {
                            onEdit(textFieldController.text);
                          }
                        : null,
                    child: const Text('OK'),
                  )
                ]);
          }));
}
