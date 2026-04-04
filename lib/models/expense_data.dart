import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

// ─── Expense Data Model ───────────────────────────────────────────────────────
class ExpenseData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final String category;
  final String origin;
  final String tipo;

  const ExpenseData(
    this.icon,
    this.iconColor,
    this.title,
    this.subtitle,
    this.amount,
    this.category,
    this.origin,
    this.tipo,
  );
}

const kFilterCategories = [
  'Todos',
  'Comida',
  'Transporte',
  'Suscripción',
  'Salud',
  'Entretenimiento',
  'Servicios',
  'Varios',
];

const kFilterOrigins = [
  'Todos',
  'Efectivo',
  'Tarjeta Débito',
  'Tarjeta Crédito',
  'Transferencia',
  'Depósito',
];

const kFilterTipos = ['Todos', 'egreso', 'ingreso'];
