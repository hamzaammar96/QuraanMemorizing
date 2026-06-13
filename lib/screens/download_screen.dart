import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_header.dart';

/// صفحة تحميل أحدث نسخة APK لأجهزة أندرويد.
class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.openLinkError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.downloadTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          const BrandHeader(onDark: false, nameSize: 44),
          const SizedBox(height: 28),
          const Icon(Icons.android_rounded,
              size: 64, color: _androidGreen),
          const SizedBox(height: 12),
          const Text(
            AppStrings.downloadHeadline,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            AppStrings.downloadDescription,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.6, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          // زر التحميل بأسلوب أندرويد — مربوط بالرابط المباشر لأحدث APK.
          _AndroidDownloadButton(
            onPressed: () => _open(context, AppStrings.apkDirectUrl),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: () => _open(context, AppStrings.apkReleasesUrl),
              icon: const Icon(Icons.list_alt_rounded, size: 18),
              label: const Text(AppStrings.allReleases),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.downloadNote,
                    style: TextStyle(height: 1.6, color: AppTheme.textDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // جهة التطوير والحقوق.
          const Center(
            child: Column(
              children: [
                Text(
                  AppStrings.developedBy,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                SizedBox(height: 4),
                Text(
                  AppStrings.freeApp,
                  style: TextStyle(color: AppTheme.primaryGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// لون أندرويد الأخضر الرسمي.
const Color _androidGreen = Color(0xFF3DDC84);

/// زر تحميل بأسلوب أندرويد: لون الروبوت الأخضر وأيقونته.
class _AndroidDownloadButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AndroidDownloadButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _androidGreen,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.android, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.downloadButton,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ملف APK — أحدث إصدار',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              const Icon(Icons.download_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
