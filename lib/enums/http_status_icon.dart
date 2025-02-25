import 'package:flutter/material.dart';

enum HttpStatusIcon {
  success200(200, Icons.check_circle),
  created201(201, Icons.check_circle_outline),
  badRequest400(400, Icons.error_outline),
  unauthorized401(401, Icons.lock),
  forbidden403(403, Icons.block),
  notFound404(404, Icons.search_off),
  internalServerError500(500, Icons.warning),
  notImplemented501(501, Icons.build),
  badGateway502(502, Icons.cloud_off);  

  final int code;
  final IconData icon;

  const HttpStatusIcon(this.code, this.icon);

  // Método para obtener el ícono a partir del código de estado
  static IconData getIcon(int code) {
    // Buscar si existe un enum que coincida con el código dado
    final status = HttpStatusIcon.values
        .firstWhere((element) => element.code == code, orElse: () => HttpStatusIcon.internalServerError500);
    // Retornar el ícono del enum encontrado
    return status.icon;
  }
}
