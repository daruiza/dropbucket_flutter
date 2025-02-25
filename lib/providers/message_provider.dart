// Es un proveedor pero no maneja estado
import 'package:flutter/material.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:dropbucket_flutter/widgets/message_snack_bar.dart';

class MessageProvider {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Método para mostrar SnackBar
  static void showSnackBar(
    Message message, {
    Duration duration = const Duration(seconds: 4),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
  }) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message.message, style: TextStyle(color: textColor)),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  static void showSnackBarContext(
    BuildContext context,
    Message message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar(); // Use the passed context
    ScaffoldMessenger.of(context).showSnackBar(
      // Use the passed context
      MessageSnackBar(
        message: message,
        context: context,
        duration: duration, // Pass the context to your custom SnackBar
      ),
    );
  }
}
