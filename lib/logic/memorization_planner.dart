import '../models/day_type.dart';
import '../models/plan_settings.dart';
import '../models/ward.dart';

/// منطق الحفظ — منفصل تماماً عن واجهة المستخدم.
///
/// يحدّد ورد الحفظ اليومي بناءً على:
/// - نوع اليوم (حفظ / ربط / استراحة).
/// - عدد صفحات الحفظ اليومية.
/// - عدد صفحات الربط.
/// - آخر صفحة حفظ مكتملة (lastMemorizedPage).
class MemorizationPlanner {
  /// أقصى عدد صفحات في المصحف (المصحف المعتاد 604 صفحة).
  static const int maxPage = 604;

  /// حساب ورد الحفظ لليوم حسب رقم اليوم في الأسبوع (DateTime.weekday: 1..7).
  static MemorizationWard computeWard({
    required PlanSettings settings,
    required int weekday,
  }) {
    final type = settings.dayTypes[weekday] ?? DayType.memorize;

    switch (type) {
      case DayType.rest:
        return MemorizationWard(type: DayType.rest);

      case DayType.link:
        // عرض آخر عدد من الصفحات للربط والمراجعة.
        final last = settings.lastMemorizedPage;
        if (last < 1) {
          return MemorizationWard(type: DayType.link, segment: null);
        }
        final startPage = (last - settings.linkPages + 1).clamp(1, maxPage);
        return MemorizationWard(
          type: DayType.link,
          segment: PageSegment(startPage, last),
        );

      case DayType.memorize:
        // الصفحة (أو الصفحات) التالية للحفظ بعد آخر صفحة محفوظة.
        final start = settings.lastMemorizedPage + 1;
        if (start > maxPage) {
          // تم حفظ المصحف كاملاً.
          return MemorizationWard(type: DayType.memorize, segment: null);
        }
        final end =
            (settings.lastMemorizedPage + settings.memorizeDailyPages)
                .clamp(start, maxPage);
        return MemorizationWard(
          type: DayType.memorize,
          segment: PageSegment(start, end),
        );
    }
  }

  /// حساب آخر صفحة محفوظة الجديدة بعد إكمال حفظ اليوم.
  static int advanceAfterMemorize(PlanSettings settings) {
    return (settings.lastMemorizedPage + settings.memorizeDailyPages)
        .clamp(0, maxPage);
  }
}
