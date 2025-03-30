/// Environment variables and shared app constants.
abstract class Constants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dropbucketbk.asistirensalud.online',
  );

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://dropbucket.asistirensalud.online',
  );

  // Puedes definir otras constantes de la misma manera
  static const bool isDebugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: false,
  );
}
