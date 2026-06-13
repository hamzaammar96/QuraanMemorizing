import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/// شاشة الإعداد الأول — تسأل عن آخر صفحة محفوظة واستخدام الخطة الافتراضية.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = TextEditingController(text: '1');
  bool _useDefaultPlan = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final page = int.tryParse(_pageController.text.trim()) ?? 1;
    final lastPage = page.clamp(1, 604);

    final state = context.read<AppState>();
    await state.completeOnboarding(
      lastMemorizedPage: lastPage,
      useDefaultPlan: _useDefaultPlan,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.menu_book_rounded,
                  size: 72, color: AppTheme.primaryGreen),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'مُتقِن',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'لنبدأ بإعداد خطتك',
                  style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 32),

              // آخر صفحة محفوظة.
              const Text(
                'آخر صفحة محفوظة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'أدخل رقم آخر صفحة وصلت إليها في الحفظ (1 - 604).',
                style: TextStyle(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.lightGreen,
                ),
              ),
              const SizedBox(height: 24),

              // استخدام الخطة الافتراضية.
              Card(
                child: SwitchListTile(
                  value: _useDefaultPlan,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (v) => setState(() => _useDefaultPlan = v),
                  title: const Text(
                    'استخدام الخطة الافتراضية',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'مراجعة 10 صفحات يومياً، حفظ صفحة واحدة 6 أيام، '
                    'يوم ربط لآخر 5 صفحات، والجمعة استراحة.',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _finish,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('ابدأ الآن'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  // حفظ الإعداد الأولي ثم فتح الإعدادات للتعديل.
                  await _finish();
                  if (!mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                icon: const Icon(Icons.tune),
                label: const Text('تعديل الإعدادات قبل البدء'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
