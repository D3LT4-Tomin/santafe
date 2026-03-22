import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class AddInvestmentScreen extends StatelessWidget {
  const AddInvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Agregar Inversión')),
      child: SafeArea(
        child: Center(
          child: Text(
            'Add Investment Screen',
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
