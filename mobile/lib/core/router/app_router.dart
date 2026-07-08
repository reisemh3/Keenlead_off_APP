import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/services/supabase_service.dart';
import '../theme/app_theme.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HealthCheckScreen(),
    ),
  ],
);

/// Temporary home screen for the technical-setup step: proves the
/// Flutter app can reach Supabase. Replaced by the real home screen
/// (Étape 5 — Mobile MVP).
class HealthCheckScreen extends StatefulWidget {
  const HealthCheckScreen({super.key});

  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  bool? _connected;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final ok = await SupabaseService.ping();
    if (mounted) setState(() => _connected = ok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Keenlead', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16),
            if (_connected == null)
              const CircularProgressIndicator()
            else
              Text(
                _connected!
                    ? 'Connexion Supabase OK'
                    : 'Connexion Supabase échouée — vérifie ton .env',
                style: TextStyle(
                  color: _connected! ? AppColors.audioGreen : AppColors.warmOrange,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
