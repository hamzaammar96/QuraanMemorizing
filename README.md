# مُتقِن — تطبيق مراجعة وحفظ القرآن الكريم

تطبيق أندرويد عربي بالكامل (RTL) يساعدك على تنظيم **ورد المراجعة** و**ورد الحفظ**
اليومي وتتبّع التقدم بدقّة. لا ينتقل التطبيق إلى ورد جديد إلا بعد ضغط زر **الإكمال**،
وإذا غبت يوماً أو أكثر لا تتقدّم الخطة تلقائياً بل تتابع من آخر محطة وصلت إليها.

مبني باستخدام **Flutter** (مناسب لتطبيق عربي بسيط وسريع مع دعم ممتاز لـ RTL
والإشعارات والتخزين المحلي).

---

## المزايا

- واجهة عربية بالكامل واتجاه من اليمين إلى اليسار.
- **ورد المراجعة**: عدد صفحات قابل للتخصيص (افتراضياً 10 صفحات يومياً) يتحرّك داخل
  نطاقات الحفظ ثم يعود للبداية، مع دعم **نطاقات متعددة متفرقة** (مثل 1–51 و582–604).
- **ورد الحفظ**: صفحة يومياً، مع **يوم ربط** لآخر صفحات و**يوم استراحة** (الجمعة).
- زرّان منفصلان: **إكمال المراجعة** و**إكمال الحفظ** — لا تقدّم بدون إكمال.
- إضافة الصفحات المحفوظة حديثاً إلى نطاق المراجعة بعد تأكيدك.
- إشعارات يومية عربية لوقتي المراجعة والحفظ (قابلة للتفعيل/الإلغاء).
- **سجل الإنجاز** وآخر محطة وصلت إليها.
- تخزين محلي بالكامل على الجهاز (SharedPreferences).

---

## بنية المشروع

```
lib/
  main.dart                      نقطة البداية + إعداد RTL والعربية
  models/                        نماذج البيانات (نطاقات، إعدادات، تقدم، أوراد)
  logic/
    review_planner.dart          منطق حساب ورد المراجعة (منفصل عن الواجهة)
    memorization_planner.dart    منطق حساب ورد الحفظ (منفصل عن الواجهة)
  services/
    storage_service.dart         التخزين المحلي
    notification_service.dart     الإشعارات اليومية المجدولة
  state/app_state.dart           الحالة المركزية تربط المنطق بالواجهة
  screens/                       الشاشات (بداية، إعداد أول، رئيسية، نطاقات، إعدادات، سجل)
  widgets/ward_card.dart         بطاقة عرض ورد اليوم
  theme/app_theme.dart           الهوية البصرية (أخضر هادئ)
test/planner_test.dart           اختبارات منطق المراجعة والحفظ
```

> **فصل المنطق عن الواجهة:** كل حسابات الخطة موجودة في `lib/logic/` ولا تعتمد على أي
> عنصر واجهة، ما يجعل اختبارها وتعديلها سهلاً (انظر `test/planner_test.dart`).

---

## طريقة التشغيل على أندرويد

### المتطلبات
- تثبيت [Flutter SDK](https://docs.flutter.dev/get-started/install) إصدار 3.0 أو أحدث.
- جهاز أندرويد أو محاكي (Android Emulator).

### الخطوات

هذا المستودع يحتوي على كود التطبيق (`lib/`, `pubspec.yaml`, `test/`). توليد مجلدات
المنصّة الأصلية (android/ios) يتم بأمر Flutter واحد:

```bash
# 1) من جذر المشروع، ولّد مجلدات المنصّات وطبّق إعدادات أندرويد تلقائياً:
bash tool/scaffold.sh

# 2) شغّل التطبيق على جهاز/محاكي متصل:
flutter run

# لبناء ملف APK جاهز للتثبيت:
flutter build apk --release
# الناتج: build/app/outputs/flutter-apk/app-release.apk
```

السكربت `tool/scaffold.sh` ينفّذ:
1. `flutter create --platforms=android,ios .` لتوليد مجلدات المنصّات.
2. استرجاع ملفاتنا من git إن لزم (آمن).
3. `tool/apply_android_config.py` لضبط اسم التطبيق العربي والإشعارات.
4. `flutter pub get`.

### إن أردت تنفيذ الإعداد يدوياً

بعد `flutter create --platforms=android,ios .` طبّق التعديلات التالية على
`android/app/src/main/AndroidManifest.xml`:

```xml
<!-- قبل وسم <application> -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>

<!-- اسم التطبيق العربي داخل وسم <application> -->
<application android:label="مُتقِن" ... >

<!-- مستقبِلات الإشعارات المجدولة داخل <application> -->
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

وفي `android/app/build.gradle` فعّل desugaring (يتطلبه flutter_local_notifications):

```gradle
android {
    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
}
```

### تشغيل الاختبارات

```bash
flutter test
```

---

## الخطة الافتراضية (قابلة للتعديل بالكامل)

- **المراجعة:** 10 صفحات يومياً. مثال: إن كانت آخر صفحة محفوظة 51، فاليوم الأول
  من صفحة 1، ثم يتقدّم 10 صفحات كل يوم حتى آخر النطاق ثم يعود للبداية.
- **الحفظ:** صفحة واحدة يومياً، 6 أيام.
- **الربط:** الخميس — مراجعة وربط آخر 5 صفحات بدل حفظ جديد.
- **الاستراحة:** الجمعة.

كل ما سبق قابل للتعديل من شاشة **إعدادات الخطة**: عدد صفحات المراجعة/الحفظ/الربط،
آخر صفحة محفوظة، نوع كل يوم في الأسبوع (حفظ/ربط/استراحة)، وأوقات الإشعارات.

---

## منطق المراجعة باختصار

تُسطّح نطاقات الحفظ إلى قائمة صفحات مرتّبة، ويُحفظ مؤشر `reviewIndex` لموضع الصفحة
التالية. كل ورد يأخذ `عدد صفحات المراجعة` صفحات متتالية مع **الالتفاف** عند النهاية،
ويُقسّم إلى مقاطع عند عبور حدود النطاقات. لا يتحرّك المؤشر إلا عند **إكمال المراجعة**.

---

## ربط حساب غوغل والحفظ السحابي (Firebase)

التطبيق يدعم تسجيل الدخول بحساب غوغل ومزامنة بياناتك (الإعدادات + التقدم + السجل)
تلقائياً عبر **Cloud Firestore**. حتى تُكمل الإعداد التالي يعمل التطبيق محلياً بشكل
طبيعي، وتبقى المزامنة معطّلة دون أي خطأ.

### خطوات التفعيل (مرة واحدة)

1. أنشئ مشروعاً مجانياً على [Firebase Console](https://console.firebase.google.com).
2. **Authentication** ← Sign-in method ← فعّل مزوّد **Google**.
3. **Authentication** ← Settings ← **Authorized domains** ← أضف نطاق موقعك:
   `hamzaammar96.github.io` (و`localhost` مضاف افتراضياً للتجربة).
4. **Firestore Database** ← أنشئ قاعدة بيانات، ثم انسخ محتوى ملف `firestore.rules`
   إلى تبويب **Rules** وانشره (كل مستخدم يصل لبياناته فقط).
5. أدخل إعدادات المشروع في التطبيق بإحدى طريقتين:
   - **الأسهل (مستحسن):**
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
     سيولّد `lib/firebase_options.dart` تلقائياً لكل المنصّات.
   - **يدوياً:** انسخ قيم تطبيق الويب من إعدادات المشروع والصقها في
     `lib/firebase_options.dart` (الحقل `web`).
6. ادفع التغييرات إلى الفرع، فيتحدّث الموقع المباشر تلقائياً وتظهر بطاقة
   **الحساب والمزامنة** في الإعدادات لتسجيل الدخول بغوغل.

> **ملاحظة للأندرويد:** لكي يعمل تسجيل دخول غوغل على الـ APK، أضف بصمة **SHA-1**
> لتطبيقك في إعدادات مشروع Firebase، وضع ملف `google-services.json`
> (يضعه `flutterfire configure` تلقائياً). على الويب لا حاجة لذلك.

### كيف تعمل المزامنة

- البيانات تُخزّن في `users/{uid}` مع طابع زمني `lastModified`.
- عند كل تغيير محلي تُرفع البيانات تلقائياً (بتأخير بسيط لتجميع التغييرات).
- عند الدخول من جهاز آخر تُدمج الأحدث، ويستمع التطبيق للتغييرات لحظياً عبر الأجهزة.
- الأمان: قواعد Firestore تمنع أي مستخدم من قراءة بيانات غيره.
