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
    apiKey: 'AIzaSyDse4NaGZLwdmDQ4nR3QlSoYu_GmdNTeM8',
    appId: '1:878978217300:web:8d21de6cd3e9b85497c4c1',
    messagingSenderId: '878978217300',
    projectId: 'moutqin-7fa44',
    authDomain: 'moutqin-7fa44.firebaseapp.com',
    storageBucket: 'moutqin-7fa44.firebasestorage.app',
    measurementId: 'G-MNQ8BSRQ1S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAK1ofbF27uyOlTton1PlBnLMs3PpY5n1M',
    appId: '1:878978217300:android:c9f7ba206e8a5dd197c4c1',
    messagingSenderId: '878978217300',
    projectId: 'moutqin-7fa44',
    storageBucket: 'moutqin-7fa44.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDse4NaGZLwdmDQ4nR3QlSoYu_GmdNTeM8',
    appId: '1:878978217300:web:8d21de6cd3e9b85497c4c1',
    messagingSenderId: '878978217300',
    projectId: 'moutqin-7fa44',
    storageBucket: 'moutqin-7fa44.firebasestorage.app',
    iosBundleId: 'com.mutqin.mutqin',
  );
}
