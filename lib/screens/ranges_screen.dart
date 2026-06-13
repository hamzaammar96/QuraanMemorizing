import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/memorization_range.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// شاشة نطاقات الحفظ — إضافة وتعديل وحذف نطاقات المراجعة المتعددة.
class RangesScreen extends StatelessWidget {
  const RangesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ranges = state.settings.ranges;

    return Scaffold(
      appBar: AppBar(title: const Text('نطاقات الحفظ')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('إضافة نطاق'),
        onPressed: () => _editRange(context, null),
      ),
      body: ranges.isEmpty
          ? const Center(
              child: Text(
                'لا توجد نطاقات بعد.\nأضف نطاق حفظ لبدء المراجعة.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(
                  12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
              itemCount: ranges.length,
              itemBuilder: (context, index) {
                final r = ranges[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.lightGreen,
                      child: Text('${index + 1}',
                          style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                      'من صفحة ${r.start} إلى صفحة ${r.end}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${r.pageCount} صفحة'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: AppTheme.primaryGreen),
                          onPressed: () => _editRange(context, index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف النطاق'),
        content: const Text('هل تريد حذف هذا النطاق؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<AppState>().deleteRange(index);
    }
  }

  Future<void> _editRange(BuildContext context, int? index) async {
    final state = context.read<AppState>();
    final existing = index != null ? state.settings.ranges[index] : null;
    final startCtrl =
        TextEditingController(text: existing?.start.toString() ?? '');
    final endCtrl = TextEditingController(text: existing?.end.toString() ?? '');

    final result = await showDialog<MemorizationRange>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? 'إضافة نطاق' : 'تعديل النطاق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _numField(startCtrl, 'من صفحة'),
            const SizedBox(height: 12),
            _numField(endCtrl, 'إلى صفحة'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final start = int.tryParse(startCtrl.text.trim()) ?? 0;
              final end = int.tryParse(endCtrl.text.trim()) ?? 0;
              if (start < 1 || end < start || end > 604) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text('أدخل نطاقاً صحيحاً (1 - 604)')),
                );
                return;
              }
              Navigator.pop(
                  ctx, MemorizationRange(start: start, end: end));
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      if (index == null) {
        await state.addRange(result.start, result.end);
      } else {
        await state.updateRange(index, result.start, result.end);
      }
    }
  }

  Widget _numField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
