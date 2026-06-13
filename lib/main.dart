import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة بيانات التواريخ للغة العربية (لعرض اسم اليوم والشهر).
  await initializeDateFormatting('ar', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: const MutqinApp(),
    ),
  );
}

/// تطبيق "مُتقِن" — عربي بالكامل واتجاه من اليمين إلى اليسار.
class MutqinApp extends StatelessWidget {
  const MutqinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مُتقِن',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // دعم اللغة العربية والاتجاه من اليمين إلى اليسار.
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // فرض اتجاه RTL على كامل التطبيق.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
