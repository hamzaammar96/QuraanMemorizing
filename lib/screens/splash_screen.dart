import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// شاشة البداية — تعرض اسم التطبيق ثم تنتقل حسب حالة الإعداد.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // أثناء تحميل البيانات من التخزين.
    if (!state.isLoaded) {
      return const Scaffold(
        backgroundColor: AppTheme.primaryGreen,
        body: Center(
          child: _Logo(),
        ),
      );
    }

    // التوجيه بعد التحميل.
    return state.onboardingDone ? const HomeScreen() : const OnboardingScreen();
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.menu_book_rounded, size: 88, color: Colors.white),
        SizedBox(height: 16),
        Text(
          'مُتقِن',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'وردك اليومي للمراجعة والحفظ',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        SizedBox(height: 24),
        CircularProgressIndicator(color: Colors.white),
      ],
    );
  }
}
