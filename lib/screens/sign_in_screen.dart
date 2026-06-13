import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// شاشة تسجيل الدخول الإلزامية بحساب غوغل.
/// تظهر قبل استخدام التطبيق عند تفعيل المزامنة السحابية.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final signingIn = state.syncStatus.contains('تسجيل الدخول');

    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.menu_book_rounded, size: 84, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'مُتقِن',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'سجّل الدخول بحساب غوغل لحفظ وردك ومزامنته عبر أجهزتك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              if (signingIn)
                const Center(child: CircularProgressIndicator(color: Colors.white))
              else
                ElevatedButton.icon(
                  onPressed: () => state.signInWithGoogle(),
                  icon: const Icon(Icons.login),
                  label: const Text('تسجيل الدخول بحساب غوغل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              if (!signingIn && state.syncStatus.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  state.syncStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
