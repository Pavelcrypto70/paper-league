/// Local league API URL — started by tool/league_api.
abstract final class LeagueApiConfig {
  static const url = String.fromEnvironment(
    'LEAGUE_API_URL',
    defaultValue: 'http://127.0.0.1:8787',
  );

  static bool get enabled => url.isNotEmpty;
}
