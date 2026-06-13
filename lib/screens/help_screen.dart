import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_theme.dart';

/// دليل استخدام التطبيق — يظهر أول مرة، ويمكن فتحه دائماً من زر المساعدة.
/// يعرض الخطوات مع رسوم توضيحية (أيقونات) واتجاه RTL.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  /// أيقونة توضيحية لكل خطوة بحسب ترتيبها.
  static const List<IconData> _icons = [
    Icons.flag_rounded,
    Icons.calendar_month_rounded,
    Icons.menu_book_rounded,
    Icons.check_circle_rounded,
    Icons.bookmark_added_rounded,
    Icons.cloud_done_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final steps = AppStrings.helpSteps;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // ترويسة توضيحية.
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb_rounded,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 14),
                const Text(
                  AppStrings.helpIntro,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < steps.length; i++)
            _StepTile(
              number: i + 1,
              icon: _icons[i % _icons.length],
              title: steps[i][0],
              body: steps[i][1],
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text(AppStrings.helpGotIt),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة خطوة واحدة: رقم + أيقونة دائرية + عنوان + شرح.
class _StepTile extends StatelessWidget {
  final int number;
  final IconData icon;
  final String title;
  final String body;

  const _StepTile({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة دائرية مع شارة الرقم.
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.primaryGreen, size: 28),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: AppTheme.accentGold,
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
