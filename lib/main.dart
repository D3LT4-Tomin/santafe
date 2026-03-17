import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'shell/app_shell.dart';
import 'theme/app_theme.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const FinanzasApp());
}

class FinanzasApp extends StatelessWidget {
  const FinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Finanzas',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.systemBlue,
        scaffoldBackgroundColor: AppColors.systemBackground,
        textTheme: CupertinoTextThemeData(primaryColor: AppColors.systemBlue),
      ),
      home: AppShell(),
    );
  }
}
