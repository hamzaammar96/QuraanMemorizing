import 'package:flutter_test/flutter_test.dart';
import 'package:mutqin/logic/memorization_planner.dart';
import 'package:mutqin/logic/review_planner.dart';
import 'package:mutqin/models/day_type.dart';
import 'package:mutqin/models/memorization_range.dart';
import 'package:mutqin/models/plan_settings.dart';

void main() {
  group('ReviewPlanner', () {
    test('ورد متتابع داخل نطاق واحد', () {
      final ranges = [MemorizationRange(start: 1, end: 51)];
      // اليوم الأول: من المؤشر 0، 10 صفحات => 1..10
      final d1 = ReviewPlanner.computeWard(
          ranges: ranges, dailyReviewPages: 10, reviewIndex: 0);
      expect(d1.totalPages, 10);
      expect(d1.segments.length, 1);
      expect(d1.segments.first.start, 1);
      expect(d1.segments.first.end, 10);

      // اليوم الثاني: من المؤشر 10 => 11..20
      final d2 = ReviewPlanner.computeWard(
          ranges: ranges, dailyReviewPages: 10, reviewIndex: d1.nextIndex);
      expect(d2.segments.first.start, 11);
      expect(d2.segments.first.end, 20);
    });

    test('الالتفاف إلى البداية عند نهاية النطاق', () {
      final ranges = [MemorizationRange(start: 1, end: 51)]; // 51 صفحة
      // المؤشر عند 50 (الصفحة 51)، 10 صفحات => 51 ثم يلتف إلى 1..9
      final w = ReviewPlanner.computeWard(
          ranges: ranges, dailyReviewPages: 10, reviewIndex: 50);
      expect(w.totalPages, 10);
      // مقطعان: [51-51] و [1-9]
      expect(w.segments.length, 2);
      expect(w.segments[0].start, 51);
      expect(w.segments[1].start, 1);
      expect(w.segments[1].end, 9);
      expect(w.nextIndex, 9);
    });

    test('المراجعة عبر نطاقات متعددة متفرقة', () {
      final ranges = [
        MemorizationRange(start: 1, end: 51),
        MemorizationRange(start: 582, end: 604),
      ];
      // المؤشر عند 48 (الصفحة 49) => 49,50,51 ثم 582,583,584 (مقطعان)
      final w = ReviewPlanner.computeWard(
          ranges: ranges, dailyReviewPages: 6, reviewIndex: 48);
      expect(w.totalPages, 6);
      expect(w.segments.length, 2);
      expect(w.segments[0].start, 49);
      expect(w.segments[0].end, 51);
      expect(w.segments[1].start, 582);
      expect(w.segments[1].end, 584);
    });
  });

  group('MemorizationPlanner', () {
    test('يوم الحفظ يعرض الصفحة التالية', () {
      final s = PlanSettings.defaults(lastMemorizedPage: 51);
      final w = MemorizationPlanner.computeWard(
          settings: s, weekday: DateTime.saturday);
      expect(w.type, DayType.memorize);
      expect(w.segment!.start, 52);
      expect(w.segment!.end, 52);
    });

    test('يوم الربط يعرض آخر 5 صفحات', () {
      final s = PlanSettings.defaults(lastMemorizedPage: 51);
      final w = MemorizationPlanner.computeWard(
          settings: s, weekday: DateTime.thursday);
      expect(w.type, DayType.link);
      expect(w.segment!.start, 47);
      expect(w.segment!.end, 51);
    });

    test('يوم الجمعة استراحة', () {
      final s = PlanSettings.defaults(lastMemorizedPage: 51);
      final w = MemorizationPlanner.computeWard(
          settings: s, weekday: DateTime.friday);
      expect(w.type, DayType.rest);
      expect(w.segment, isNull);
    });
  });
}
