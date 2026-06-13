import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// بطاقة عرض ورد اليوم (مراجعة أو حفظ) مع زر إكمال.
class WardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String wardText;
  final String? statusBadge;
  final Color badgeColor;
  final String buttonLabel;
  final bool completed;
  final bool enabled;
  final VoidCallback onComplete;

  const WardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.wardText,
    this.statusBadge,
    this.badgeColor = AppTheme.primaryGreen,
    required this.buttonLabel,
    required this.completed,
    required this.enabled,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (statusBadge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusBadge!,
                      style: TextStyle(
                          color: badgeColor, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              wardText,
              style: const TextStyle(fontSize: 20, color: AppTheme.textDark),
            ),
            const SizedBox(height: 16),
            if (completed)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: AppTheme.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'تم الإكمال اليوم',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: enabled ? onComplete : null,
                icon: const Icon(Icons.done_all),
                label: Text(buttonLabel),
              ),
          ],
        ),
      ),
    );
  }
}
