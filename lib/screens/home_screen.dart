import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../models/day_type.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ward_card.dart';
import 'help_screen.dart';
import 'history_screen.dart';
import 'ranges_screen.dart';
import 'settings_screen.dart';

/// الشاشة الرئيسية — تعرض ورد المراجعة وورد الحفظ وحالة اليوم وأزرار الإكمال.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // عرض دليل الاستخدام تلقائياً عند أول استخدام.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowHelp());
  }

  Future<void> _maybeShowHelp() async {
    final state = context.read<AppState>();
    if (state.helpSeen) return;
    await state.markHelpSeen();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HelpScreen()),
    );
  }

  void _openHelp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HelpScreen()),
    );
  }

  /// نص عربي لعدد مرّات الإكمال اليوم.
  static String? _countNote(int count) {
    if (count <= 0) return null;
    if (count == 1) return 'أُكمل اليوم مرّة واحدة';
    if (count == 2) return 'أُكمل اليوم مرّتان';
    return 'أُكمل اليوم $count مرّات';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final reviewWard = state.todayReviewWard;
    final memorizeWard = state.todayMemorizeWard;
    final dayType = state.todayDayType;
    final last = state.lastEvent;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.menu_book_rounded, size: 26),
            SizedBox(width: 8),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          if (last != null)
            IconButton(
              tooltip: 'تراجع عن آخر إنجاز',
              icon: const Icon(Icons.undo),
              onPressed: () => _confirmUndo(context),
            ),
          IconButton(
            tooltip: AppStrings.helpButton,
            icon: const Icon(Icons.help_outline),
            onPressed: _openHelp,
          ),
          IconButton(
            tooltip: 'سجل الإنجاز',
            icon: const Icon(Icons.calendar_month),
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
        padding: EdgeInsets.fromLTRB(
            12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
        children: [
          const _WelcomeBanner(),
          _DayHeader(dayType: dayType),
          const SizedBox(height: 4),

          // بطاقة مراجعة اليوم (يمكن إكمالها أكثر من مرة).
          WardCard(
            title: 'مراجعة اليوم',
            icon: Icons.repeat_rounded,
            wardText: reviewWard.arabicText,
            buttonLabel: 'إكمال المراجعة',
            enabled: !reviewWard.isEmpty,
            todayNote: _countNote(state.reviewCountToday),
            onComplete: () => _onCompleteReview(context),
          ),

          // بطاقة حفظ اليوم (يمكن حفظ أكثر من صفحة في اليوم).
          WardCard(
            title: 'حفظ اليوم',
            icon: Icons.bookmark_added_rounded,
            wardText: memorizeWard.arabicText,
            statusBadge: dayType.arabicLabel,
            badgeColor: _badgeColor(dayType),
            buttonLabel: dayType == DayType.link ? 'إكمال الربط' : 'إكمال الحفظ',
            enabled: dayType != DayType.rest,
            todayNote: _countNote(state.memorizeCountToday),
            onComplete: () => _onCompleteMemorize(context),
          ),

          const SizedBox(height: 8),
          _ProgressSummary(),
          const SizedBox(height: 8),

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
    await context.read<AppState>().completeReview();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إكمال المراجعة')),
    );
  }

  Future<void> _onCompleteMemorize(BuildContext context) async {
    final state = context.read<AppState>();
    final dayType = state.todayDayType;
    await state.completeMemorize();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            dayType == DayType.link ? 'تم إكمال الربط' : 'تم إكمال الحفظ'),
      ),
    );
  }

  Future<void> _confirmUndo(BuildContext context) async {
    final state = context.read<AppState>();
    final e = state.lastEvent;
    if (e == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تراجع عن آخر إنجاز'),
        content: Text('سيتم التراجع عن: ${e.typeLabel} — ${e.summary}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تراجع')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await state.undoLastEvent();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم التراجع عن آخر إنجاز')),
      );
    }
  }
}

/// لافتة ترحيب في أعلى الصفحة الرئيسية.
class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Color(0xFF1B7A5A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, color: AppTheme.accentGold),
              const SizedBox(width: 8),
              Text(
                AppStrings.homeTitle,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.homeDescription,
            style: TextStyle(fontSize: 14, height: 1.6, color: Colors.white70),
          ),
        ],
      ),
    );
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
            child: Text(today,
                style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600)),
          ),
          Text('حالة اليوم: ${dayType.arabicLabel}',
              style: const TextStyle(color: AppTheme.textMuted)),
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
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    color: AppTheme.textDark, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
