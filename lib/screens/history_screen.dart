import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/completion_event.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// شاشة السجل — رزنامة شهرية تعرض الإنجاز اليومي عند اختيار أي يوم.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  // ترتيب أيام الأسبوع بدءاً من السبت (DateTime.weekday: السبت=6 ... الجمعة=5).
  static const _weekOrder = [6, 7, 1, 2, 3, 4, 5];
  static const _weekLabels = ['سبت', 'أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dayEvents = state.eventsForDate(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('سجل الإنجاز')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _lastStationCard(state),
          _calendarCard(state),
          const SizedBox(height: 8),
          _selectedDayCard(context, dayEvents),
        ],
      ),
    );
  }

  // بطاقة آخر محطة وصل إليها المستخدم.
  Widget _lastStationCard(AppState state) {
    return Card(
      color: AppTheme.lightGreen,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('آخر محطة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('آخر صفحة محفوظة: صفحة ${state.settings.lastMemorizedPage}'),
            const SizedBox(height: 4),
            Text('ورد المراجعة الحالي: ${state.todayReviewWard.arabicText}'),
          ],
        ),
      ),
    );
  }

  // بطاقة الرزنامة الشهرية.
  Widget _calendarCard(AppState state) {
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = _focusedMonth.weekday;
    final leadingEmpty = _weekOrder.indexOf(firstWeekday);
    final totalCells = ((leadingEmpty + daysInMonth) / 7).ceil() * 7;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // رأس الشهر مع أسهم التنقل.
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                  }),
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy', 'ar').format(_focusedMonth),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                  }),
                ),
              ],
            ),
            // عناوين أيام الأسبوع.
            Row(
              children: _weekLabels
                  .map((l) => Expanded(
                        child: Center(
                          child: Text(l,
                              style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            // شبكة الأيام.
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: totalCells,
              itemBuilder: (context, index) {
                final dayNum = index - leadingEmpty + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const SizedBox();
                }
                final date = DateTime(
                    _focusedMonth.year, _focusedMonth.month, dayNum);
                return _dayCell(state, date, dayNum);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(AppState state, DateTime date, int dayNum) {
    final events = state.eventsForDate(date);
    final hasReview = events.any((e) => e.type == 'review');
    final hasMemorize = events.any((e) => e.type == 'memorize' || e.type == 'link');
    final isSelected = _sameDay(date, _selectedDay);
    final isToday = _sameDay(date, DateTime.now());

    return GestureDetector(
      onTap: () => setState(() => _selectedDay = date),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen
              : (isToday ? AppTheme.lightGreen : null),
          borderRadius: BorderRadius.circular(10),
          border: isToday && !isSelected
              ? Border.all(color: AppTheme.primaryGreen)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNum',
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasReview) _dot(isSelected ? Colors.white : AppTheme.primaryGreen),
                if (hasMemorize) _dot(isSelected ? Colors.white70 : AppTheme.accentGold),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  // بطاقة تفاصيل اليوم المختار مع إمكانية التراجع عن أي حدث.
  Widget _selectedDayCard(BuildContext context, List<CompletionEvent> events) {
    final dateText =
        DateFormat('EEEE، d MMMM yyyy', 'ar').format(_selectedDay);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(dateText,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (events.isEmpty)
              const Text('لا يوجد إنجاز في هذا اليوم',
                  style: TextStyle(color: AppTheme.textMuted))
            else
              ...events.map((e) => _eventRow(context, e)),
          ],
        ),
      ),
    );
  }

  Widget _eventRow(BuildContext context, CompletionEvent e) {
    final color =
        e.type == 'review' ? AppTheme.primaryGreen : AppTheme.accentGold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            e.type == 'review'
                ? Icons.repeat_rounded
                : Icons.bookmark_added_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${e.typeLabel} • ${e.time}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text(e.summary,
                    style: const TextStyle(color: AppTheme.textDark)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'تراجع',
            icon: const Icon(Icons.undo, color: Colors.redAccent),
            onPressed: () => _undo(context, e),
          ),
        ],
      ),
    );
  }

  Future<void> _undo(BuildContext context, CompletionEvent e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تراجع عن الإنجاز'),
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
      await context.read<AppState>().undoEvent(e.id);
    }
  }
}
