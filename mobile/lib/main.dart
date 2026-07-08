import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env is only present in local/dev builds (see mobile/.env.example);
  // release builds get config via --dart-define instead, so a missing
  // file here is not an error.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  await SupabaseService.initialize();

  runApp(const ProviderScope(child: KeenleadApp()));
}

class KeenleadApp extends StatelessWidget {
  const KeenleadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Keenlead',
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
