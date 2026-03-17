import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Expense Data Model ───────────────────────────────────────────────────────
class ExpenseData {
  final IconData icon;
  final Color    iconColor;
  final String   title;
  final String   subtitle;
  final String   amount;
  final String   category;

  const ExpenseData(
    this.icon,
    this.iconColor,
    this.title,
    this.subtitle,
    this.amount,
    this.category,
  );
}

// ─── Static Expense List ──────────────────────────────────────────────────────
const kAllExpenses = [
  ExpenseData(CupertinoIcons.cart_fill,            AppColors.systemOrange, 'Tacos "El Güero"',      'Comida · 14:20',         '-\$85.00',    'Comida'),
  ExpenseData(CupertinoIcons.bus,                  AppColors.systemIndigo, 'Recarga Metro rey',      'Transporte · 08:45',     '-\$100.00',   'Transporte'),
  ExpenseData(CupertinoIcons.bag_fill,             AppColors.systemGreen,  'OXXO Monterrey',         'Varios · Ayer',          '-\$42.50',    'Varios'),
  ExpenseData(CupertinoIcons.film,                 AppColors.systemPurple, 'Netflix',                'Suscripción · Ayer',     '-\$159.00',   'Suscripción'),
  ExpenseData(CupertinoIcons.car_fill,             AppColors.systemRed,    'Uber — Centro',          'Transporte · Ayer',      '-\$68.00',    'Transporte'),
  ExpenseData(CupertinoIcons.gamecontroller_fill,  AppColors.systemIndigo, 'Steam',                  'Entretenimiento · Lun',  '-\$219.00',   'Entretenimiento'),
  ExpenseData(CupertinoIcons.heart_fill,           AppColors.systemRed,    'Farmacia Guadalajara',   'Salud · Lun',            '-\$320.00',   'Salud'),
  ExpenseData(CupertinoIcons.music_note,           AppColors.systemPurple, 'Spotify',                'Suscripción · Dom',      '-\$99.00',    'Suscripción'),
  ExpenseData(CupertinoIcons.bolt_fill,            AppColors.systemOrange, 'CFE Recarga',            'Servicios · Dom',        '-\$200.00',   'Servicios'),
  ExpenseData(CupertinoIcons.star_fill,            AppColors.systemGreen,  'Starbucks Tecnológico',  'Comida · Dom',           '-\$95.00',    'Comida'),
  ExpenseData(CupertinoIcons.airplane,             AppColors.systemBlue,   'Aeroméxico — MTY→CDMX', 'Viaje · Sáb',            '-\$1,850.00', 'Varios'),
  ExpenseData(CupertinoIcons.flame_fill,           AppColors.systemGreen,  'Gimnasio Sport City',    'Salud · Sáb',            '-\$650.00',   'Salud'),
  ExpenseData(CupertinoIcons.tv_fill,              AppColors.systemIndigo, 'Disney+',                'Suscripción · Vie',      '-\$139.00',   'Suscripción'),
  ExpenseData(CupertinoIcons.cart_fill,            AppColors.systemOrange, 'Walmart Galerías',       'Despensa · Vie',         '-\$734.50',   'Comida'),
  ExpenseData(CupertinoIcons.car_fill,             AppColors.systemRed,    'Gasolinería Pemex',      'Transporte · Jue',       '-\$450.00',   'Transporte'),
  ExpenseData(CupertinoIcons.book_fill,            AppColors.systemPurple, 'Audible',                'Suscripción · Jue',      '-\$169.00',   'Suscripción'),
  ExpenseData(CupertinoIcons.bag_fill,             AppColors.systemGreen,  '7-Eleven Constitución',  'Varios · Mié',           '-\$37.00',    'Varios'),
  ExpenseData(CupertinoIcons.heart_fill,           AppColors.systemRed,    'Dentista Dr. Garza',     'Salud · Mié',            '-\$800.00',   'Salud'),
  ExpenseData(CupertinoIcons.bolt_fill,            AppColors.systemOrange, 'Telmex Internet',        'Servicios · Mar',        '-\$399.00',   'Servicios'),
  ExpenseData(CupertinoIcons.building_2_fill,      AppColors.systemGreen,  'La Burguesía',           'Comida · Mar',           '-\$312.00',   'Comida'),
];

const kFilterCategories = [
  'Todos', 'Comida', 'Transporte', 'Suscripción',
  'Salud', 'Entretenimiento', 'Servicios', 'Varios',
];
