import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';

/// Thin wrapper around the Supabase client singleton, so the rest
/// of the app depends on this instead of importing supabase_flutter
/// directly everywhere.
class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Connectivity check used by the health-check screen during technical
  /// setup: hits Supabase's public auth health endpoint, which responds
  /// even before any business tables or logged-in session exist.
  static Future<bool> ping() async {
    try {
      final uri = Uri.parse('${Env.supabaseUrl}/auth/v1/health');
      final request = await HttpClient().getUrl(uri);
      request.headers.set('apikey', Env.supabaseAnonKey);
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
