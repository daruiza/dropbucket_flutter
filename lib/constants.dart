/// Environment variables and shared app constants.
abstract class Constants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    //defaultValue: 'https://dropbucketbk.asistirensalud.space',
    //defaultValue: 'http://localhost:3031',
    //defaultValue: 'http://44.203.46.54:3031',
    defaultValue: 'http://localhost:8080',
  );

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://dropbucket.asistirensalud.space',
  );

  // Puedes definir otras constantes de la misma manera
  static const bool isDebugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: false,
  );

  static const int limitDateValid = int.fromEnvironment(
    'LIMIT_DATE_VALID',
    defaultValue: 720, // 30 dias
  );
}
