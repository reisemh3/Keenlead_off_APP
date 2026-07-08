import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads configuration from `.env` in debug, or from `--dart-define`
/// values for release builds (CI/CD should pass secrets that way,
/// never bundling `.env` into the release artifact).
class Env {
  static String get supabaseUrl => _read('SUPABASE_URL');
  static String get supabaseAnonKey => _read('SUPABASE_ANON_KEY');

  static String _read(String key) {
    const fromDefine = String.fromEnvironment('');
    final fromDartDefine = _dartDefine(key);
    if (fromDartDefine.isNotEmpty) return fromDartDefine;
    return dotenv.env[key] ?? fromDefine;
  }

  static String _dartDefine(String key) {
    switch (key) {
      case 'SUPABASE_URL':
        return const String.fromEnvironment('SUPABASE_URL');
      case 'SUPABASE_ANON_KEY':
        return const String.fromEnvironment('SUPABASE_ANON_KEY');
      default:
        return '';
    }
  }
}
