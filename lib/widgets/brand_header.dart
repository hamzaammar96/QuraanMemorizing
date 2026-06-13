import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_theme.dart';

/// ترويسة الهوية: شعار دائري + اسم "مُتقِن" بخط كبير مميّز + خط ذهبي زخرفي.
/// تُستخدم في شاشة البداية وتسجيل الدخول.
class BrandHeader extends StatelessWidget {
  /// خلفية داكنة/خضراء => نص أبيض، وإلا أخضر.
  final bool onDark;
  final double nameSize;
  final String? tagline;

  const BrandHeader({
    super.key,
    this.onDark = true,
    this.nameSize = 56,
    this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = onDark ? Colors.white : AppTheme.primaryGreen;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onDark
                ? Colors.white.withValues(alpha: 0.15)
                : AppTheme.primaryGreen.withValues(alpha: 0.10),
          ),
          child: Icon(Icons.menu_book_rounded, size: 56, color: fg),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: nameSize,
            fontWeight: FontWeight.w900,
            color: fg,
            letterSpacing: 3,
            height: 1.05,
            shadows: onDark
                ? const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 10),
        // خط زخرفي ذهبي تحت الاسم.
        Container(
          width: 70,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (tagline != null) ...[
          const SizedBox(height: 16),
          Text(
            tagline!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: onDark ? Colors.white70 : AppTheme.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
