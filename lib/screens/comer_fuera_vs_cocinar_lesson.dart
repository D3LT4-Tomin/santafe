import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/header_row.dart';

class ComerFueraVsCocinarLesson extends StatelessWidget {
  const ComerFueraVsCocinarLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Comer fuera vs. Cocinar'),
        previousPageTitle: 'Aprendizaje',
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '5 min · Lección actual',
              style: TextStyle(fontSize: 12, color: AppColors.systemOrange),
            ),
            const SizedBox(height: 16),
            const Text(
              'Comer fuera vs. Cocinar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Una de las decisiones más impactantes en tu presupuesto diario es si comer fuera o preparar tus meals en casa. Analicemos el costo real de cada opción.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text(
              'Análisis de Costos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Comer fuera: \$10-15 por meal\nCocinar en casa: \$3-5 por meal\nAhorro potencial: \$5-10 por meal\nSi comes fuera 5 veces por semana: \$200-400/mes extra',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Beneficios de Cocinar en Casa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Control total sobre ingredientes y porciones\n• Menos procesado y aditivos\n• Habilidades valiosas para la vida\n• Tiempo de calidad con familia o pareja',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Consejos para Empezar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Planifica tus meals semanales\n• Prepara ingredientes los domingos\n• Empieza con recetas simples\n• Usa ollas de cocción lenta para días ocupados',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
