import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/learning_provider.dart';
import '../models/learning_model.dart';

class AhorroBasicoLesson extends StatelessWidget {
  const AhorroBasicoLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
                  color: AppColors.systemBackground.withValues(alpha: 0.8),
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
                  '6 min',
                  style: TextStyle(fontSize: 12, color: AppColors.systemGreen),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ahorro Básico',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'El ahorro es la base de toda salud financiera. Aprender a ahorrar aunque sea poco puede cambiar tu futuro.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'La regla 50/30/20',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 50% para necesidades (renta, servicios, comida)\n• 30% para deseos (entretenimiento, restaurantes)\n• 20% para ahorro e inversión',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tips para empezar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Págate primero: guarda antes de gastar\n2. Automatiza tu ahorro\n3. Empieza con lo que te sobre, aunque sea poco\n4. Incrementa 1% cada mes\n5. No toques lo que ahorras',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: bottomPadding + 20,
            child: GestureDetector(
              onTap: () {
                final lesson = LessonCatalog.getById('ahorro_basico');
                if (lesson != null) {
                  context.read<LearningProvider>().completeLesson(
                    'ahorro_basico',
                    lesson.points,
                  );
                }
                Navigator.of(context).pop();
              },
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.systemBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Terminar lección',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
