/// نصوص الواجهة العربية لتطبيق "مُتقِن" في مكان مركزي واحد.
/// عدّل النصوص من هنا بدلاً من كتابتها داخل الشاشات.
class AppStrings {
  AppStrings._();

  /// اسم التطبيق.
  static const String appName = 'مُتقِن';

  // ===== شاشة البداية / تسجيل الدخول =====
  static const String splashTagline = 'وردك اليومي للمراجعة والحفظ';
  static const String welcomeTitle = 'مرحباً بك في مُتقِن';
  static const String welcomeDescription =
      'نظّم حفظك، ثبّت مراجعتك، وتابع وردك اليومي بخطة مرنة تناسبك.';
  static const String signInWithGoogle = 'تسجيل الدخول بحساب غوغل';
  static const String signingIn = 'جارٍ تسجيل الدخول...';

  // ===== الصفحة الرئيسية =====
  static const String homeTitle = 'وردك اليوم بانتظارك';
  static const String homeDescription =
      'أكمل مراجعتك وحفظك، وسيحفظ مُتقِن تقدمك لتتابع دائماً من آخر محطة وصلت إليها.';

  // ===== دليل الاستخدام (يظهر أول مرة + زر المساعدة) =====
  static const String helpButton = 'كيفية الاستخدام';
  static const String helpTitle = 'كيف تستخدم مُتقِن؟';
  static const String helpIntro =
      'خطوات بسيطة تنظّم وردك اليومي للحفظ والمراجعة:';
  static const String helpGotIt = 'فهمت، لنبدأ';

  /// خطوات الدليل: كل خطوة [العنوان، الشرح]. الأيقونات تُربط حسب الترتيب في الواجهة.
  static const List<List<String>> helpSteps = [
    [
      'حدّد نقطة البداية',
      'من الإعدادات اختر آخر صفحة وصلت إليها، وعدد صفحات المراجعة اليومية.',
    ],
    [
      'خصّص أيامك',
      'اضبط أيام الحفظ والربط والاستراحة بما يناسب ظروفك خلال الأسبوع.',
    ],
    [
      'تابع وردك اليوم',
      'تظهر لك في الصفحة الرئيسية مراجعة اليوم وحفظ اليوم بوضوح.',
    ],
    [
      'أكمل بضغطة واحدة',
      'اضغط «إكمال المراجعة» أو «إكمال الحفظ» عند انتهائك من الورد.',
    ],
    [
      'لا تقدّم تلقائي',
      'لا يتقدّم مُتقِن عند غيابك، بل يحفظ آخر محطة مكتملة ويتابع منها لاحقاً.',
    ],
    [
      'تابع تقدمك ومزامنته',
      'راجع سجل الإنجاز وملخص التقدم، وبياناتك محفوظة بحسابك وتتزامن عبر أجهزتك.',
    ],
  ];

  // ===== جهة التطوير والحقوق =====
  static const String aboutTitle = 'حول التطبيق';
  static const String developedBy = 'تطوير روبوغيكس — لبنان';
  static const String freeApp = 'هذا التطبيق مجاني بالكامل';
  static const String rightsNote = '© روبوغيكس، لبنان — جميع الحقوق محفوظة';

  // ===== صفحة تحميل تطبيق أندرويد =====
  static const String apkReleasesUrl =
      'https://github.com/hamzaammar96/QuraanMemorizing/releases/latest';
  // رابط مباشر لتنزيل ملف APK (أحدث نسخة منشورة).
  static const String apkDirectUrl =
      'https://github.com/hamzaammar96/QuraanMemorizing/releases/download/apk-v23/app-release.apk';
  static const String downloadLinkLabel = 'تحميل تطبيق أندرويد';
  static const String downloadTitle = 'تطبيق أندرويد';
  static const String downloadHeadline = 'حمّل مُتقِن على أجهزة أندرويد';
  static const String downloadDescription =
      'احصل على أحدث نسخة (APK) لتثبيتها على هاتف أندرويد، والاستفادة من '
      'الإشعارات اليومية والعمل دون اتصال.';
  static const String downloadButton = 'تنزيل لأجهزة أندرويد';
  static const String allReleases = 'عرض كل الإصدارات';
  static const String downloadNote =
      'عند التثبيت قد يطلب الجهاز تفعيل «السماح بالتثبيت من مصادر غير معروفة» '
      'للمتصفّح. الملف موقّع رسمياً وآمن.';
  static const String openLinkError = 'تعذّر فتح الرابط';

  // ===== وصف التطبيق العام (المتجر / README) =====
  static const String appShortDescription =
      'مُتقِن يساعدك على تنظيم حفظ القرآن ومراجعته يومياً بخطة مرنة تتابع معك '
      'من آخر محطة وصلت إليها.';
  static const String appLongDescription =
      'مُتقِن هو تطبيق عربي بسيط يساعدك على متابعة ورد الحفظ والمراجعة بطريقة '
      'منظمة ومرنة. يمكنك تحديد آخر صفحة وصلت إليها، ضبط مقدار المراجعة اليومية، '
      'تخصيص أيام الحفظ والربط والاستراحة، وإكمال وردك اليومي بضغطة واحدة. '
      'لا يتقدم التطبيق تلقائياً عند غيابك، بل يحفظ آخر محطة مكتملة ويتابع منها، '
      'حتى تبقى خطتك واقعية ومناسبة لظروفك.';
}
