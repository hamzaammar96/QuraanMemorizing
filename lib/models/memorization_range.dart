/// نطاق حفظ يمثّل مجموعة صفحات متصلة محفوظة ويجري مراجعتها.
/// مثال: من صفحة 1 إلى 51، أو من صفحة 582 إلى 604.
class MemorizationRange {
  int start;
  int end;

  MemorizationRange({required this.start, required this.end});

  /// عدد الصفحات داخل النطاق (شامل للطرفين).
  int get pageCount => (end - start + 1).clamp(0, 9999);

  Map<String, dynamic> toJson() => {'start': start, 'end': end};

  factory MemorizationRange.fromJson(Map<String, dynamic> json) {
    return MemorizationRange(
      start: json['start'] as int,
      end: json['end'] as int,
    );
  }

  MemorizationRange copy() => MemorizationRange(start: start, end: end);
}
