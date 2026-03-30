import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class GastosHormigaLesson extends StatelessWidget {
  const GastosHormigaLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.systemBackground,
      child: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.systemBackground.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: AppColors.label,
                  size: 18,
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 40),
                const Text(
                  '8 min',
                  style: TextStyle(fontSize: 12, color: AppColors.systemOrange),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gastos Hormiga',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Los gastos hormiga son pequeñas compras que hacemos sin pensar y que summed pueden representar una cantidad significativa de nuestro presupuesto.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ejemplos de gastos hormiga',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Café toutes las mañanas\n• Botanas en la tienda\n• Servicios de streaming que no usas\n• Compras por impulso en redes\n• Cigarros o vapeo',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Cómo identificarlos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Revisa tu historial de compras\n2. Identifica patrones repetitivos\n3. Pregúntate: "¿Realmente lo necesito?"\n4. Establece un límite mensual para estos gastos',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
