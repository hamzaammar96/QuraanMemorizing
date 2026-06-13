import '../models/memorization_range.dart';
import '../models/ward.dart';

/// منطق المراجعة — منفصل تماماً عن واجهة المستخدم.
///
/// يحسب ورد المراجعة التالي بناءً على:
/// - نطاقات الحفظ.
/// - عدد صفحات المراجعة اليومية.
/// - آخر موضع مراجعة مكتمل (reviewIndex).
///
/// عند الوصول إلى نهاية آخر نطاق تعود المراجعة إلى بداية أول نطاق،
/// وإذا كانت الصفحات المتبقية في النطاق أقل من المطلوب يُكمل في النطاق التالي.
class ReviewPlanner {
  /// تحويل النطاقات إلى قائمة مسطّحة بكل أرقام الصفحات بالترتيب.
  /// مثال: [1-3, 10-11] => [1, 2, 3, 10, 11]
  static List<int> flatten(List<MemorizationRange> ranges) {
    final pages = <int>[];
    for (final r in ranges) {
      if (r.end < r.start) continue; // تجاهل النطاقات غير الصحيحة
      for (int p = r.start; p <= r.end; p++) {
        pages.add(p);
      }
    }
    return pages;
  }

  /// حساب ورد المراجعة لليوم.
  /// [reviewIndex] هو موضع الصفحة التالية داخل القائمة المسطّحة.
  static ReviewWard computeWard({
    required List<MemorizationRange> ranges,
    required int dailyReviewPages,
    required int reviewIndex,
  }) {
    final flat = flatten(ranges);

    if (flat.isEmpty || dailyReviewPages <= 0) {
      return ReviewWard(segments: [], totalPages: 0, nextIndex: reviewIndex);
    }

    final total = flat.length;
    // عدد الصفحات لا يتجاوز إجمالي الصفحات المتاحة.
    final count = dailyReviewPages > total ? total : dailyReviewPages;
    // ضبط المؤشر ضمن الحدود (يدعم الالتفاف للبداية).
    final start = ((reviewIndex % total) + total) % total;

    // جمع صفحات الورد مع الالتفاف عند نهاية القائمة.
    final wardPages = <int>[];
    for (int i = 0; i < count; i++) {
      wardPages.add(flat[(start + i) % total]);
    }

    final segments = _mergeIntoSegments(wardPages);
    final nextIndex = (start + count) % total;

    return ReviewWard(
      segments: segments,
      totalPages: count,
      nextIndex: nextIndex,
    );
  }

  /// دمج الصفحات المتتالية في مقاطع متصلة.
  /// الصفحات غير المتصلة (عبور نطاق أو التفاف) تُكوّن مقاطع منفصلة.
  static List<PageSegment> _mergeIntoSegments(List<int> pages) {
    final segments = <PageSegment>[];
    if (pages.isEmpty) return segments;

    int segStart = pages.first;
    int prev = pages.first;

    for (int i = 1; i < pages.length; i++) {
      final p = pages[i];
      if (p == prev + 1) {
        prev = p; // استمرار المقطع الحالي
      } else {
        segments.add(PageSegment(segStart, prev));
        segStart = p;
        prev = p;
      }
    }
    segments.add(PageSegment(segStart, prev));
    return segments;
  }
}
