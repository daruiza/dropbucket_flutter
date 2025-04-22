

class DateUtilsLocal {

  // Verifica la distancia entre dos fechas, es mayor al parametro limit
  static bool limitDate(
    int limit,
    DateTime fechaInicial,
    DateTime fechaActual,
  ) {
    return fechaActual.difference(fechaInicial).inHours >= limit;
  }
}
