import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/day_type.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ward_card.dart';
import 'history_screen.dart';
import 'ranges_screen.dart';
import 'settings_screen.dart';

/// الشاشة الرئيسية — تعرض ورد المراجعة وورد الحفظ وحالة اليوم وأزرار الإكمال.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final reviewWard = state.todayReviewWard;
    final memorizeWard = state.todayMemorizeWard;
    final dayType = state.todayDayType;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مُتقِن'),
        actions: [
          IconButton(
            tooltip: 'سجل الإنجاز',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            tooltip: 'الإعدادات',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _DayHeader(dayType: dayType),
          const SizedBox(height: 4),

          // بطاقة مراجعة اليوم.
          WardCard(
            title: 'مراجعة اليوم',
            icon: Icons.repeat_rounded,
            wardText: reviewWard.arabicText,
            buttonLabel: 'إكمال المراجعة',
            completed: state.reviewCompletedToday,
            enabled: !reviewWard.isEmpty,
            onComplete: () => _onCompleteReview(context),
          ),

          // بطاقة حفظ اليوم.
          WardCard(
            title: 'حفظ اليوم',
            icon: Icons.bookmark_added_rounded,
            wardText: memorizeWard.arabicText,
            statusBadge: dayType.arabicLabel,
            badgeColor: _badgeColor(dayType),
            buttonLabel: dayType == DayType.link ? 'إكمال الربط' : 'إكمال الحفظ',
            completed: state.memorizeCompletedToday,
            enabled: dayType != DayType.rest,
            onComplete: () => _onCompleteMemorize(context),
          ),

          const SizedBox(height: 8),
          _ProgressSummary(),
          const SizedBox(height: 8),

          // اختصار لنطاقات الحفظ.
          Card(
            child: ListTile(
              leading: const Icon(Icons.format_list_numbered,
                  color: AppTheme.primaryGreen),
              title: const Text('نطاقات الحفظ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${state.settings.ranges.length} نطاق'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RangesScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _badgeColor(DayType type) {
    switch (type) {
      case DayType.memorize:
        return AppTheme.primaryGreen;
      case DayType.link:
        return AppTheme.accentGold;
      case DayType.rest:
        return AppTheme.textMuted;
    }
  }

  Future<void> _onCompleteReview(BuildContext context) async {
    final state = context.read<AppState>();
    await state.completeReview();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إكمال المراجعة')),
    );
  }

  Future<void> _onCompleteMemorize(BuildContext context) async {
    final state = context.read<AppState>();
    final dayType = state.todayDayType;
    final newPages = await state.completeMemorize();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          dayType == DayType.link ? 'تم إكمال الربط' : 'تم إكمال الحفظ',
        ),
      ),
    );

    // عند حفظ صفحات جديدة، نطلب تأكيد إضافتها لنطاق المراجعة.
    if (newPages) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('إضافة إلى المراجعة'),
          content: Text(
            'تم حفظ حتى صفحة ${state.settings.lastMemorizedPage}. '
            'هل تريد إضافتها إلى نطاق المراجعة؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('لاحقاً'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('نعم، أضف'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await state.extendReviewRangeToMemorized();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة الصفحات إلى نطاق المراجعة')),
        );
      }
    }
  }
}

/// رأس يعرض التاريخ وحالة اليوم.
class _DayHeader extends StatelessWidget {
  final DayType dayType;
  const _DayHeader({required this.dayType});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          const Icon(Icons.today, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              today,
              style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'حالة اليوم: ${dayType.arabicLabel}',
            style: const TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

/// ملخص التقدم: آخر صفحة محفوظة وموضع المراجعة.
class _ProgressSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('ملخص التقدم',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _row('آخر صفحة محفوظة', 'صفحة ${state.settings.lastMemorizedPage}'),
            const Divider(),
            _row('مراجعة اليوم', state.todayReviewWard.arabicText),
            const Divider(),
            _row('عدد نطاقات الحفظ', '${state.settings.ranges.length}'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  color: AppTheme.textDark, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
