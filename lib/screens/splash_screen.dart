import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_header.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'sign_in_screen.dart';

/// شاشة البداية — تعرض اسم التطبيق ثم تنتقل حسب حالة الإعداد.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // أثناء تحميل البيانات أو انتظار استعادة جلسة الدخول.
    if (!state.isLoaded || (state.isCloudReady && !state.authResolved)) {
      return const Scaffold(
        backgroundColor: AppTheme.primaryGreen,
        body: Center(
          child: _Logo(),
        ),
      );
    }

    // بوابة الدخول الإلزامية عند تفعيل المزامنة.
    if (state.isCloudReady && !state.isSignedIn) {
      return const SignInScreen();
    }

    // التوجيه بعد الدخول.
    return state.onboardingDone ? const HomeScreen() : const OnboardingScreen();
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandHeader(onDark: true, nameSize: 48, tagline: AppStrings.splashTagline),
        SizedBox(height: 28),
        CircularProgressIndicator(color: Colors.white),
      ],
    );
  }
}
