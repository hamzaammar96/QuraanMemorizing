/// نوع اليوم بالنسبة لخطة الحفظ.
/// - memorize: يوم حفظ صفحة (أو عدد الصفحات المحدد) جديدة.
/// - link: يوم ربط ومراجعة لآخر صفحات محفوظة.
/// - rest: يوم استراحة.
enum DayType {
  memorize,
  link,
  rest;

  /// الاسم العربي المعروض في الواجهة.
  String get arabicLabel {
    switch (this) {
      case DayType.memorize:
        return 'حفظ';
      case DayType.link:
        return 'ربط';
      case DayType.rest:
        return 'استراحة';
    }
  }

  static DayType fromName(String name) {
    return DayType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => DayType.memorize,
    );
  }
}
