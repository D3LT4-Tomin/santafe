import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class UserAccountScreen extends StatelessWidget {
  const UserAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Cuenta de Usuario')),
      child: SafeArea(
        child: Center(
          child: Text(
            'User Account Screen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.label,
            ),
          ),
        ),
      ),
    );
  }
}
