import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../screens/download_screen.dart';
import '../theme/app_theme.dart';

/// رابط يفتح صفحة تحميل تطبيق أندرويد.
/// [onDark] للخلفيات الداكنة (نص فاتح).
class DownloadLink extends StatelessWidget {
  final bool onDark;
  const DownloadLink({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final color = onDark ? Colors.white : AppTheme.primaryGreen;
    return TextButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DownloadScreen()),
      ),
      icon: Icon(Icons.android_rounded, color: color, size: 20),
      label: Text(
        AppStrings.downloadLinkLabel,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
