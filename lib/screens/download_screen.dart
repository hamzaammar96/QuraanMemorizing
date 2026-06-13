import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_header.dart';

/// صفحة تحميل أحدث نسخة APK لأجهزة أندرويد.
class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  Future<void> _openReleases(BuildContext context) async {
    final uri = Uri.parse(AppStrings.apkReleasesUrl);
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
              size: 64, color: AppTheme.primaryGreen),
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
          ElevatedButton.icon(
            onPressed: () => _openReleases(context),
            icon: const Icon(Icons.download_rounded),
            label: const Text(AppStrings.downloadButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
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
