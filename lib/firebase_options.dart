import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// إعدادات مشروع Firebase.
///
/// هذه القيم فارغة افتراضياً، فيبقى التطبيق يعمل محلياً بلا سحابة.
/// لتفعيل المزامنة: املأ القيم من إعدادات مشروعك في Firebase
/// (أو شغّل `flutterfire configure` لتوليد هذا الملف تلقائياً).
/// راجع قسم "ربط حساب غوغل" في README.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  /// هل تم إدخال إعدادات Firebase؟ (يُفعّل المزامنة تلقائياً عند الإدخال)
  static bool get isConfigured => currentPlatform.apiKey.isNotEmpty;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '', // ← الصق القيم من Firebase Console → إعدادات المشروع → تطبيق الويب
    appId: '',
    messagingSenderId: '',
    projectId: '',
    authDomain: '',
    storageBucket: '',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    storageBucket: '',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
    storageBucket: '',
    iosBundleId: 'com.mutqin.mutqin',
  );
}
