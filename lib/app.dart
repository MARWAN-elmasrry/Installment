import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_shell.dart';
import 'utils/app_theme.dart';

class InstallmentApp extends StatelessWidget {
  const InstallmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تقسيط مصر مباشر',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Arabic locale => the whole app is laid out right-to-left.
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}
