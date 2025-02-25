import 'package:flutter/material.dart';

class DialogInput extends StatelessWidget {
  final String title;
  final String label;
  const DialogInput({super.key, required this.title, required this.label});

  @override
  Widget build(BuildContext context) {
    TextEditingController textFieldController = TextEditingController();
    bool isButtonEnabled = false;

    void validateInput(String input) {
      // Validar que el texto contenga solo letras y números
      final isValid = RegExp(r'^[a-zA-Z0-9\s@$!%*?&_#]*$').hasMatch(input);
      // Actualizar el estado local
      isButtonEnabled = isValid && input.isNotEmpty;
    }

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontSize: 16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textFieldController,
                decoration: InputDecoration(
                  hintText: label,
                  errorText: textFieldController.text.isEmpty
                      ? null
                      : RegExp(r'^[a-zA-Z0-9\s@$!%*?&_#]*$')
                              .hasMatch(textFieldController.text)
                          ? null
                          : 'No cumple con el formato permitido',
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
              onPressed: () => Navigator.of(context).pop({'option': 'cancel'}),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop({'option': 'done', 'value': textFieldController.text});
              },
              child: const Text('OK'),
            ),
          ]);
    });
  }
}
