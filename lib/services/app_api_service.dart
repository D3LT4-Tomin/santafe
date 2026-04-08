import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction_model.dart';
import '../providers/data_provider.dart';

class AppApiService {
  // For Flutter web, use the actual machine IP instead of localhost
  static const String _baseUrl = 'http://192.168.202.4:8000';

  // ── User Profile for API ─────────────────────────────────────────────────────
  static Map<String, dynamic> _buildUserProfile(DataProvider data) {
    final now = DateTime.now();

    final expenses = data.currentMonthExpenses;
    final income = data.currentMonthIncome;

    // Calculate average monthly spend from historical data
    double avgMonthlySpend = expenses;
    double volatility = 0.1;

    return {
      'cc_num': 1234,
      'income_range': 2,
      'is_parent': 0,
      'has_partner': 0,
      'is_student': 0,
      'has_budget': 1,
      'spending_style_enc': 1,
      'financial_goal_enc': 2,
      'life_stage_enc': 1,
      'volatility': volatility,
      'avg_monthly_spend': avgMonthlySpend,
      'lag_1': expenses,
      'lag_2': expenses * 0.9,
      'lag_3': expenses * 0.8,
      'rolling_3m': expenses * 0.95,
      'month': now.month,
    };
  }

  // ── Endpoint 1: Get user cluster ────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUserCluster(DataProvider data) async {
    try {
      final profile = _buildUserProfile(data);
      final response = await http.post(
        Uri.parse('$_baseUrl/user/cluster'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching user cluster: $e');
    }
    return null;
  }

  // ── Endpoint 2: Classify transaction ────────────────────────────────────────
  static Future<Map<String, dynamic>?> classifyTransaction(
    TransactionModel transaction,
    DataProvider data,
  ) async {
    try {
      final payload = {
        'cc_num': 1234,
        'amt': transaction.amount.abs(),
        'category': transaction.category,
        'hour': transaction.createdAt.hour,
        'dayofweek': transaction.createdAt.weekday,
        'month': transaction.createdAt.month,
        'is_weekend': (transaction.createdAt.weekday >= 6) ? 1 : 0,
        'is_night':
            (transaction.createdAt.hour >= 20 ||
                transaction.createdAt.hour <= 6)
            ? 1
            : 0,
        'is_regreso_clases': 0,
        'is_decembrina': 0,
        'is_semana_santa': 0,
        'is_cuesta_enero': 0,
        'is_dia_madres': 0,
        'is_buen_fin': 0,
        'is_verano': 0,
        'income_range': 2,
        'life_stage_enc': 1,
        'is_parent': 0,
        'has_partner': 0,
        'is_student': 0,
        'spending_style_enc': 1,
        'has_budget': 1,
        'financial_goal_enc': 2,
        'avg_monthly_spend': data.currentMonthExpenses,
        'volatility': 0.1,
        'cat_mean': 150.0,
        'cat_median': 120.0,
        'cat_freq': 10,
        'z_score': 1.5,
        'pct_of_monthly': 0.05,
        'is_essential': 1,
        'is_discretionary': 0,
        'is_impulsive_cat': 0,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/transaction/classify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error classifying transaction: $e');
    }
    return null;
  }

  // ── Endpoint 3: Forecast next month ─────────────────────────────────────────
  static Future<Map<String, dynamic>?> forecastNextMonth(
    DataProvider data,
  ) async {
    try {
      final profile = _buildUserProfile(data);
      final response = await http.post(
        Uri.parse('$_baseUrl/forecast'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error forecasting next month: $e');
    }
    return null;
  }

  // ── Endpoint 4: Full user summary ───────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUserSummary(DataProvider data) async {
    try {
      final profile = _buildUserProfile(data);
      final response = await http.post(
        Uri.parse('$_baseUrl/user/summary'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching user summary: $e');
    }
    return null;
  }

  // ── Endpoint 5: Chat with context ───────────────────────────────────────────
  static Future<Map<String, dynamic>?> chatWithContext(
    DataProvider data,
    String message, {
    List<TransactionModel>? transactions,
  }) async {
    try {
      final profile = _buildUserProfile(data);
      final conversation = [
        {'role': 'user', 'content': message},
      ];

      final payload = {
        'cc_num': profile['cc_num'],
        'conversation': conversation,
        'income_range': profile['income_range'],
        'life_stage_enc': profile['life_stage_enc'],
        'is_parent': profile['is_parent'],
        'has_partner': profile['has_partner'],
        'is_student': profile['is_student'],
        'spending_style_enc': profile['spending_style_enc'],
        'has_budget': profile['has_budget'],
        'financial_goal_enc': profile['financial_goal_enc'],
        'avg_monthly_spend': profile['avg_monthly_spend'],
        'volatility': profile['volatility'],
        'transactions': transactions
            ?.map(
              (t) => {
                'cc_num': 1234,
                'amt': t.amount.abs(),
                'category': t.category,
                'hour': t.createdAt.hour,
                'dayofweek': t.createdAt.weekday,
                'month': t.createdAt.month,
              },
            )
            .toList(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/insights/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error in chat: $e');
    }
    return null;
  }

  // ── Endpoint 6: Generate insights ───────────────────────────────────────────
  static Future<Map<String, dynamic>?> generateInsights(
    DataProvider data,
    List<TransactionModel>? transactions,
  ) async {
    try {
      final profile = _buildUserProfile(data);

      final payload = {
        'cc_num': profile['cc_num'],
        'income_range': profile['income_range'],
        'is_parent': profile['is_parent'],
        'has_partner': profile['has_partner'],
        'is_student': profile['is_student'],
        'has_budget': profile['has_budget'],
        'spending_style_enc': profile['spending_style_enc'],
        'financial_goal_enc': profile['financial_goal_enc'],
        'life_stage_enc': profile['life_stage_enc'],
        'volatility': profile['volatility'],
        'avg_monthly_spend': profile['avg_monthly_spend'],
        'lag_1': profile['lag_1'],
        'lag_2': profile['lag_2'],
        'lag_3': profile['lag_3'],
        'rolling_3m': profile['rolling_3m'],
        'month': profile['month'],
        'transactions': transactions
            ?.map(
              (t) => {
                'cc_num': 1234,
                'amt': t.amount.abs(),
                'category': t.category,
                'hour': t.createdAt.hour,
                'dayofweek': t.createdAt.weekday,
                'month': t.createdAt.month,
              },
            )
            .toList(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/insights/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error generating insights: $e');
    }
    return null;
  }
}
