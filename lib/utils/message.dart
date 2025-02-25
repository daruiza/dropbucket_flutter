import 'dart:convert';

class Message {
  final List<String> messages;
  final String message;
  final int statusCode;

  Message({
    required this.messages,
    required this.message,
    required this.statusCode,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messages:
          json['messages'] != null
              ? jsonDecode(json['messages'])
              : [json['message'] ?? json['error']],
      message:
          json['error'] ?? json['message'], // Mapeado de 'error' a 'message'
      statusCode: json['statusCode'],
    );
  }

  factory Message.fromString(String jsonString) {
    try {
      final stringData =
          jsonString.contains('{')
              ? jsonString.substring(jsonString.indexOf('{'))
              : '{"message": "$jsonString"}';

      final Map<String, dynamic> json = jsonDecode(stringData);
      return Message.fromJson(json);
    } catch (e) {
      throw FormatException('Error al parsear el string JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {'messages': messages, 'message': message, 'statusCode': statusCode};
  }

  @override
  String toString() {
    return 'Message(messages: $messages, message: $message, statusCode: $statusCode)';
  }

  // Método para obtener todos los mensajes de error como un solo String
  String get errorMessages {
    if (messages == []) {
      return message != '' ? message : 'Error desconocido';
    } else {}
    return messages.join(', ');
  }
}
