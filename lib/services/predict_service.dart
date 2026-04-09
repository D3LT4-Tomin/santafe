import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/forecast_model.dart';
import '../models/transaction_model.dart';

class PredictService {
  static const String _baseUrl =
      'https://modelpredictionsapitomin-production.up.railway.app';

  static const List<String> _monthNames = [
    '',
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  static Future<UserForecast?> getForecast(
    List<TransactionModel> transactions,
  ) async {
    if (transactions.isEmpty) return null;

    final profile = _buildProfile(transactions);
    if (profile == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/forecast'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final avgSavings = _calculateAvgSavings(transactions);
        return UserForecast.fromJson(data, avgSavings);
      }
    } catch (e) {
      // PredictAPI no disponible, continuar sin forecast
    }
    return null;
  }

  static Map<String, dynamic>? _buildProfile(
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();
    final Map<String, double> monthlyExpenses = {};
    final Map<String, double> monthlyIncome = {};

    for (final t in transactions) {
      final key =
          '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}';
      if (t.tipo == 'egreso') {
        monthlyExpenses[key] = (monthlyExpenses[key] ?? 0) + t.amount.abs();
      } else {
        monthlyIncome[key] = (monthlyIncome[key] ?? 0) + t.amount.abs();
      }
    }

    if (monthlyExpenses.isEmpty) return null;

    final sortedKeys = monthlyExpenses.keys.toList()..sort();
    final monthlySpends = sortedKeys.map((k) => monthlyExpenses[k]!).toList();

    final avgMonthlySpend =
        monthlySpends.reduce((a, b) => a + b) / monthlySpends.length;
    final volatility = _calculateVolatility(monthlySpends);

    final lag1 = monthlySpends.isNotEmpty ? monthlySpends.last : 0.0;
    final lag2 = monthlySpends.length > 1
        ? monthlySpends[monthlySpends.length - 2]
        : lag1;
    final lag3 = monthlySpends.length > 2
        ? monthlySpends[monthlySpends.length - 3]
        : lag2;

    final rolling3m = monthlySpends.length >= 3
        ? monthlySpends
                  .sublist(monthlySpends.length - 3)
                  .reduce((a, b) => a + b) /
              3
        : avgMonthlySpend;

    final forecastMonth = now.month == 12 ? 1 : now.month + 1;

    return {
      'cc_num': 0,
      'income_range': 2,
      'is_parent': 0,
      'has_partner': 0,
      'is_student': 0,
      'has_budget': 0,
      'spending_style_enc': _spendingStyle(avgMonthlySpend),
      'financial_goal_enc': 0,
      'life_stage_enc': 1,
      'volatility': volatility,
      'avg_monthly_spend': avgMonthlySpend,
      'lag_1': lag1,
      'lag_2': lag2,
      'lag_3': lag3,
      'rolling_3m': rolling3m,
      'month': forecastMonth,
    };
  }

  static double _calculateVolatility(List<double> values) {
    if (values.length < 2) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) /
        values.length;
    return math.sqrt(variance) / mean;
  }

  static int _spendingStyle(double avgSpend) {
    if (avgSpend < 3000) return 0;
    if (avgSpend < 8000) return 1;
    if (avgSpend < 15000) return 2;
    return 3;
  }

  static double _calculateAvgSavings(List<TransactionModel> transactions) {
    final Map<String, double> monthlyExpenses = {};
    final Map<String, double> monthlyIncome = {};

    for (final t in transactions) {
      final key =
          '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}';
      if (t.tipo == 'egreso') {
        monthlyExpenses[key] = (monthlyExpenses[key] ?? 0) + t.amount.abs();
      } else {
        monthlyIncome[key] = (monthlyIncome[key] ?? 0) + t.amount.abs();
      }
    }

    double totalSavings = 0;
    int months = 0;
    for (final key in monthlyIncome.keys) {
      final income = monthlyIncome[key] ?? 0;
      final expense = monthlyExpenses[key] ?? 0;
      totalSavings += income - expense;
      months++;
    }

    return months > 0 ? totalSavings / months : 0;
  }

  static List<MonthlyData> buildExpensesHistory(
    List<TransactionModel> transactions,
    UserForecast? forecast,
    int maxMonths,
  ) {
    return _buildMonthlyHistory(
      transactions,
      isExpense: true,
      forecast: forecast,
    );
  }

  static List<MonthlyData> buildSavingsHistory(
    List<TransactionModel> transactions,
    UserForecast? forecast,
    int maxMonths,
  ) {
    return _buildMonthlyHistory(
      transactions,
      isExpense: false,
      forecast: forecast,
    );
  }

  static List<MonthlyData> _buildMonthlyHistory(
    List<TransactionModel> transactions, {
    required bool isExpense,
    UserForecast? forecast,
  }) {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentIndex = currentYear * 12 + currentMonth;

    // Calcular totales por mes y encontrar todos los meses
    final Map<String, double> monthlyTotals = {};
    final Map<String, int> monthIndexes = {};

    for (final t in transactions) {
      if (isExpense) {
        // Gastos: tipo egreso pero NO categoría Ahorro
        if (t.tipo != 'egreso' || t.category == 'Ahorro') continue;
      } else {
        // Ahorros: categoría específica "Ahorro"
        if (t.category != 'Ahorro') continue;
      }

      final year = t.createdAt.year;
      final month = t.createdAt.month;
      final key = '$year-${month.toString().padLeft(2, '0')}';
      final index = year * 12 + month;

      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + t.amount.abs();
      monthIndexes[key] = index;
    }

    if (monthlyTotals.isEmpty) {
      if (forecast != null) {
        final int nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
        return [
          MonthlyData(
            monthLabel: _monthNames[nextMonth],
            amount: isExpense
                ? forecast.predictedSpend
                : forecast.predictedSavings,
            isPredicted: true,
          ),
        ];
      }
      return [];
    }

    // Ordenar meses de más antiguo a más reciente
    final sortedKeys = monthIndexes.keys.toList()
      ..sort((a, b) => monthIndexes[a]!.compareTo(monthIndexes[b]!));

    // Encontrar todos los meses antes del actual (pasados)
    final List<String> pastMonthKeys = [];
    final String? currentMonthKey =
        '$currentYear-${currentMonth.toString().padLeft(2, '0')}';

    for (final key in sortedKeys) {
      final index = monthIndexes[key]!;
      if (index < currentIndex) {
        pastMonthKeys.add(key);
      }
    }

    // Mostrar máximo 3 meses pasados (los más recientes)
    final maxPastMonthsToShow = pastMonthKeys.length > 3
        ? 3
        : pastMonthKeys.length;
    final monthsToShow = pastMonthKeys.length > 3
        ? pastMonthKeys.sublist(pastMonthKeys.length - maxPastMonthsToShow)
        : pastMonthKeys;

    final List<MonthlyData> result = [];

    // Agregar meses pasados con % vs mes siguiente
    for (int i = 0; i < monthsToShow.length; i++) {
      final key = monthsToShow[i];
      final parts = key.split('-');
      final monthNum = int.parse(parts[1]);
      final amount = monthlyTotals[key]!;

      double? pctChange;
      // Calcular % vs siguiente mes (mes después o el actual)
      if (i < monthsToShow.length - 1) {
        final nextKey = monthsToShow[i + 1];
        final nextAmount = monthlyTotals[nextKey]!;
        if (amount > 0) {
          pctChange = ((nextAmount - amount) / amount) * 100;
        }
      } else if (currentMonthKey != null &&
          monthlyTotals.containsKey(currentMonthKey)) {
        final currentAmount = monthlyTotals[currentMonthKey]!;
        if (amount > 0) {
          pctChange = ((currentAmount - amount) / amount) * 100;
        }
      }

      result.add(
        MonthlyData(
          monthLabel: _monthNames[monthNum],
          amount: amount,
          pctChange: pctChange,
          isPredicted: false,
        ),
      );
    }

    // Agregar mes actual (si existe y no está en pastMonths)
    if (currentMonthKey != null &&
        monthlyTotals.containsKey(currentMonthKey) &&
        !monthsToShow.contains(currentMonthKey)) {
      result.add(
        MonthlyData(
          monthLabel: _monthNames[currentMonth],
          amount: monthlyTotals[currentMonthKey]!,
          isPredicted: false,
        ),
      );
    }

    // Pronóstico del próximo mes
    if (forecast != null) {
      final int nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
      final double predictedAmount = isExpense
          ? forecast.predictedSpend
          : forecast.predictedSavings;

      // % vs el último mes real disponible
      final double? baseAmount = result.isNotEmpty ? result.last.amount : null;

      double? pctChange;
      if (baseAmount != null && baseAmount > 0) {
        pctChange = ((predictedAmount - baseAmount) / baseAmount) * 100;
      }

      result.add(
        MonthlyData(
          monthLabel: _monthNames[nextMonth],
          amount: predictedAmount,
          pctChange: pctChange,
          isPredicted: true,
        ),
      );
    }

    return result;
  }
}
