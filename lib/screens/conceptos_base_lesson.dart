import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/header_row.dart';

class ConceptosBaseLesson extends StatelessWidget {
  const ConceptosBaseLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Conceptos Base'),
        previousPageTitle: 'Aprendizaje',
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Fundamentos del Dinero',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Entender el dinero es el primer paso hacia la libertad financiera. En esta lección, aprenderás los conceptos básicos que todo persona debería conocer sobre finanzas personales.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text(
              '¿Qué es el Dinero?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'El dinero es un medio de intercambio que aceptamos como pago por bienes y servicios. Su valor viene de la confianza que tenemos en que otros lo aceptarán a su vez.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ingresos vs Gastos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu salud financiera depende de la relación entre lo que ganas y lo que gastas. El objetivo es tener más ingresos que gastos para poder ahorrar e invertir.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
