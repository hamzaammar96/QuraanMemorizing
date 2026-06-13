import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/day_type.dart';
import '../models/plan_settings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'ranges_screen.dart';

/// شاشة الإعدادات — تعديل كل عناصر الخطة والإشعارات.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late PlanSettings _draft;

  // أسماء أيام الأسبوع حسب DateTime.weekday (1=الإثنين ... 7=الأحد).
  static const _weekdayNames = {
    DateTime.saturday: 'السبت',
    DateTime.sunday: 'الأحد',
    DateTime.monday: 'الإثنين',
    DateTime.tuesday: 'الثلاثاء',
    DateTime.wednesday: 'الأربعاء',
    DateTime.thursday: 'الخميس',
    DateTime.friday: 'الجمعة',
  };

  // ترتيب عرض الأيام بدءاً من السبت.
  static const _weekdayOrder = [
    DateTime.saturday,
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  ];

  @override
  void initState() {
    super.initState();
    // نعمل على نسخة حتى لا نؤثر على الحالة قبل الحفظ.
    _draft = context.read<AppState>().settings.copy();
  }

  Future<void> _save() async {
    await context.read<AppState>().updateSettings(_draft);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الإعدادات')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الخطة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'حفظ',
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _section('الحساب والمزامنة'),
          _accountCard(context.watch<AppState>()),
          _section('خطة المراجعة'),
          _numberTile(
            label: 'عدد صفحات المراجعة اليومية',
            value: _draft.dailyReviewPages,
            min: 1,
            max: 604,
            onChanged: (v) => setState(() => _draft.dailyReviewPages = v),
          ),
          _numberTile(
            label: 'آخر صفحة محفوظة',
            value: _draft.lastMemorizedPage,
            min: 1,
            max: 604,
            onChanged: (v) => setState(() => _draft.lastMemorizedPage = v),
          ),
          Card(
            child: SwitchListTile(
              value: _draft.includeFatihaExtra,
              activeColor: AppTheme.primaryGreen,
              title: const Text('صفحة الفاتحة الإضافية'),
              subtitle: const Text('أول ورد يبدأ من صفحة 1 يكون 1→11 ثم 12→21'),
              onChanged: (v) => setState(() => _draft.includeFatihaExtra = v),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.format_list_numbered,
                  color: AppTheme.primaryGreen),
              title: const Text('نطاقات الحفظ'),
              subtitle: Text('${_draft.ranges.length} نطاق'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RangesScreen()),
              ),
            ),
          ),

          _section('خطة الحفظ'),
          _numberTile(
            label: 'عدد صفحات الحفظ اليومية',
            value: _draft.memorizeDailyPages,
            min: 1,
            max: 20,
            onChanged: (v) => setState(() => _draft.memorizeDailyPages = v),
          ),
          _numberTile(
            label: 'عدد صفحات الربط',
            value: _draft.linkPages,
            min: 1,
            max: 20,
            onChanged: (v) => setState(() => _draft.linkPages = v),
          ),

          _section('أيام الأسبوع (حفظ / ربط / استراحة)'),
          ..._weekdayOrder.map(_dayTypeTile),

          _section('الإشعارات'),
          Card(
            child: SwitchListTile(
              value: _draft.notificationsEnabled,
              activeColor: AppTheme.primaryGreen,
              title: const Text('تفعيل الإشعارات'),
              onChanged: (v) =>
                  setState(() => _draft.notificationsEnabled = v),
            ),
          ),
          _timeTile(
            label: 'وقت إشعار المراجعة',
            hour: _draft.reviewNotifHour,
            minute: _draft.reviewNotifMinute,
            onChanged: (h, m) => setState(() {
              _draft.reviewNotifHour = h;
              _draft.reviewNotifMinute = m;
            }),
          ),
          _timeTile(
            label: 'وقت إشعار الحفظ',
            hour: _draft.memorizeNotifHour,
            minute: _draft.memorizeNotifMinute,
            onChanged: (h, m) => setState(() {
              _draft.memorizeNotifHour = h;
              _draft.memorizeNotifMinute = m;
            }),
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('حفظ الإعدادات'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // بطاقة الحساب والمزامنة السحابية بحساب غوغل.
  Widget _accountCard(AppState state) {
    if (!state.isCloudConfigured) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_off, color: AppTheme.textMuted),
                  SizedBox(width: 8),
                  Text('المزامنة غير مُفعّلة',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'لتفعيل الحفظ السحابي وربط حساب غوغل، أكمل إعداد Firebase '
                'حسب الخطوات في ملف README ثم أعد فتح التطبيق.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (!state.isSignedIn) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('احفظ بياناتك سحابياً وزامنها عبر أجهزتك',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => state.signInWithGoogle(),
                icon: const Icon(Icons.login),
                label: const Text('تسجيل الدخول بحساب غوغل'),
              ),
              if (state.syncStatus.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(state.syncStatus,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textMuted)),
              ],
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_done, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.userName ?? 'حساب غوغل',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      if (state.userEmail != null)
                        Text(state.userEmail!,
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              state.syncStatus.isEmpty ? 'المزامنة مُفعّلة' : state.syncStatus,
              style: const TextStyle(color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await state.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 18, 8, 6),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
      );

  Widget _numberTile({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: AppTheme.primaryGreen,
              onPressed:
                  value > min ? () => onChanged(value - 1) : null,
            ),
            SizedBox(
              width: 56,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: TextEditingController(text: '$value')
                  ..selection = TextSelection.collapsed(
                      offset: '$value'.length),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                onSubmitted: (t) {
                  final v = int.tryParse(t) ?? value;
                  onChanged(v.clamp(min, max));
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppTheme.primaryGreen,
              onPressed:
                  value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayTypeTile(int weekday) {
    final current = _draft.dayTypes[weekday] ?? DayType.memorize;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                _weekdayNames[weekday]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            DropdownButton<DayType>(
              value: current,
              underline: const SizedBox(),
              items: DayType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.arabicLabel),
                      ))
                  .toList(),
              onChanged: (t) {
                if (t != null) {
                  setState(() => _draft.dayTypes[weekday] = t);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeTile({
    required String label,
    required int hour,
    required int minute,
    required void Function(int, int) onChanged,
  }) {
    final timeText =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    return Card(
      child: ListTile(
        enabled: _draft.notificationsEnabled,
        leading: const Icon(Icons.access_time, color: AppTheme.primaryGreen),
        title: Text(label),
        trailing: Text(
          timeText,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: hour, minute: minute),
          );
          if (picked != null) onChanged(picked.hour, picked.minute);
        },
      ),
    );
  }
}
