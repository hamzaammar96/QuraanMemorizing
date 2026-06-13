import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../screens/download_screen.dart';
import '../theme/app_theme.dart';

/// زر يفتح صفحة تحميل تطبيق أندرويد.
/// [onDark] للخلفيات الداكنة (زر أبيض بنص أخضر).
class DownloadLink extends StatelessWidget {
  final bool onDark;
  const DownloadLink({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    // زر تحميل أندرويد يظهر على الويب فقط؛ يُخفى داخل التطبيق نفسه.
    if (!kIsWeb) return const SizedBox.shrink();

    final onPressed = () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DownloadScreen()),
        );
    const icon = Icon(Icons.android_rounded, size: 20);
    const label = Text(
      AppStrings.downloadLinkLabel,
      style: TextStyle(fontWeight: FontWeight.bold),
    );

    if (onDark) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
