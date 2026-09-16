/// Secrets and per-environment values, injected at build/run time via
/// `--dart-define` so they never live as string literals in source control.
///
/// Example:
///   flutter run --dart-define=NEWS_API_KEY=your_key_here
class AppConfig {
  AppConfig._();

  static const String newsApiKey = String.fromEnvironment('NEWS_API_KEY');
}
