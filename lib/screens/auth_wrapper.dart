import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../providers/learning_provider.dart';
import 'login_screen.dart';
import '../shell/app_shell.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _dataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserDataIfNeeded();
  }

  void _loadUserDataIfNeeded() {
    if (_dataLoaded) return;

    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoggedIn && authProvider.firebaseUser != null) {
      _dataLoaded = true;
      final userId = authProvider.firebaseUser!.uid;
      final dataProvider = context.read<DataProvider>();
      dataProvider.loadDataForUser(userId);

      final learningProvider = context.read<LearningProvider>();
      learningProvider.loadProgress(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoggedIn && !_dataLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadUserDataIfNeeded();
          });
        }

        if (authProvider.isLoading) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (authProvider.isLoggedIn) {
          return const AppShell();
        }

        return const LoginScreen();
      },
    );
  }
}
