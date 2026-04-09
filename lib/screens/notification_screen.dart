import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Notificaciones'),
        backgroundColor: AppColors.frostedGreen.withValues(alpha: 0.5),
        border: null,
      ),
      backgroundColor: AppColors.secondaryBackground,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.systemGreen.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  CupertinoIcons.bell,
                  size: 36,
                  color: AppColors.systemGreen,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sin notificaciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No tienes notificaciones nuevas',
                style: TextStyle(fontSize: 15, color: AppColors.secondaryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
