import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart' as app;
import 'providers/data_provider.dart';
import 'widgets/insights_layout_controller.dart';
import 'screens/auth_wrapper.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FinanzasApp());
}

class FinanzasApp extends StatelessWidget {
  const FinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app.AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => InsightsLayoutController()),
      ],
      child: const CupertinoApp(
        title: 'SantaFe',
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.systemBlue,
          scaffoldBackgroundColor: AppColors.systemBackground,
          textTheme: CupertinoTextThemeData(primaryColor: AppColors.systemBlue),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}
