import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_header.dart';

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
              const BrandHeader(onDark: true, nameSize: 60),
              const SizedBox(height: 36),
              const Text(
                AppStrings.welcomeTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                AppStrings.welcomeDescription,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.6, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              if (signingIn)
                const Center(child: CircularProgressIndicator(color: Colors.white))
              else
                _GoogleSignInButton(onPressed: () => state.signInWithGoogle()),
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

/// زر تسجيل الدخول بحساب غوغل مع الشعار الرسمي.
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/google_logo.svg', width: 24, height: 24),
          const SizedBox(width: 12),
          const Text(
            AppStrings.signInWithGoogle,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
