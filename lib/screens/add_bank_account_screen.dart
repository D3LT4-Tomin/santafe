import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class AddBankAccountScreen extends StatelessWidget {
  const AddBankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Agregar Cuenta Bancaria'),
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            'Add Bank Account Screen',
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
