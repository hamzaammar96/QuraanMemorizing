import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// شاشة السجل — تعرض الأيام التي تم فيها إكمال المراجعة والحفظ وآخر محطة.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final history = state.progress.history;

    return Scaffold(
      appBar: AppBar(title: const Text('سجل الإنجاز')),
      body: Column(
        children: [
          // بطاقة آخر محطة وصل إليها المستخدم.
          Card(
            margin: const EdgeInsets.all(12),
            color: AppTheme.lightGreen,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('آخر محطة',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('آخر صفحة محفوظة: صفحة ${state.settings.lastMemorizedPage}'),
                  const SizedBox(height: 4),
                  Text('ورد المراجعة الحالي: ${state.todayReviewWard.arabicText}'),
                ],
              ),
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'لا يوجد إنجاز مسجّل بعد.\nأكمل وردك ليظهر هنا.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: AppTheme.textMuted, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final rec = history[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16,
                                      color: AppTheme.primaryGreen),
                                  const SizedBox(width: 8),
                                  Text(
                                    rec.date,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (rec.reviewSummary != null)
                                _line(Icons.repeat_rounded,
                                    'تم إكمال المراجعة: ${rec.reviewSummary}'),
                              if (rec.memorizeSummary != null)
                                _line(Icons.bookmark_added_rounded,
                                    'تم الإكمال: ${rec.memorizeSummary}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _line(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
