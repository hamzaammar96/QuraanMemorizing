import 'day_type.dart';

/// مقطع صفحات متصل (من صفحة start إلى صفحة end).
class PageSegment {
  final int start;
  final int end;

  PageSegment(this.start, this.end);

  int get pageCount => end - start + 1;

  /// نص عربي: "من صفحة X إلى صفحة Y" أو "صفحة X" لو صفحة واحدة.
  String get arabicText {
    if (start == end) return 'صفحة $start';
    return 'من صفحة $start إلى صفحة $end';
  }
}

/// ناتج حساب ورد المراجعة لليوم.
class ReviewWard {
  /// مقاطع الصفحات (قد تكون أكثر من مقطع عند تجاوز حدود النطاقات أو الالتفاف).
  final List<PageSegment> segments;

  /// إجمالي عدد الصفحات في الورد.
  final int totalPages;

  /// مؤشر المراجعة بعد إكمال هذا الورد.
  final int nextIndex;

  ReviewWard({
    required this.segments,
    required this.totalPages,
    required this.nextIndex,
  });

  bool get isEmpty => segments.isEmpty;

  /// نص عربي كامل يجمع كل المقاطع.
  String get arabicText {
    if (segments.isEmpty) return 'لا توجد نطاقات للمراجعة';
    return segments.map((s) => s.arabicText).join('، و');
  }
}

/// ناتج حساب ورد الحفظ لليوم.
class MemorizationWard {
  /// نوع اليوم: حفظ / ربط / استراحة.
  final DayType type;

  /// مقطع الصفحات (للحفظ أو الربط)، أو null في الاستراحة.
  final PageSegment? segment;

  MemorizationWard({required this.type, this.segment});

  /// نص عربي وصفي لورد الحفظ اليوم.
  String get arabicText {
    switch (type) {
      case DayType.rest:
        return 'اليوم استراحة، لا حفظ اليوم';
      case DayType.link:
        if (segment == null) return 'لا توجد صفحات للربط بعد';
        return 'ربط ومراجعة ${segment!.arabicText}';
      case DayType.memorize:
        if (segment == null) return 'لا توجد صفحة محددة للحفظ';
        return 'حفظ ${segment!.arabicText}';
    }
  }
}
