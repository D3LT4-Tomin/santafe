import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
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
      final dataProvider = context.read<DataProvider>();
      dataProvider.loadDataForUser(authProvider.firebaseUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Try to load data when user is logged in
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
