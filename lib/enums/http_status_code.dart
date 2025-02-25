import 'package:flutter/material.dart';

enum HttpStatusColor {
  success200(200, Colors.green),
  created201(201, Colors.greenAccent),
  badRequest400(400, Colors.red),
  unauthorized401(401, Colors.redAccent),
  forbidden403(403, Colors.deepOrange),
  notFound404(404, Colors.red),
  internalServerError500(500, Colors.redAccent),
  notImplemented501(501, Colors.orange),
  badGateway502(502, Colors.deepOrangeAccent);

  final int code;
  final Color color;

  const HttpStatusColor(this.code, this.color);

  // Método para obtener el color a partir del código de estado
  static Color getColor(int code) {
    // Buscar si existe un enum que coincida con el código dado
    final status = HttpStatusColor.values
        .firstWhere((element) => element.code == code, orElse: () => HttpStatusColor.internalServerError500);
    // Retornar el color del enum encontrado
    return status.color;
  }
}
