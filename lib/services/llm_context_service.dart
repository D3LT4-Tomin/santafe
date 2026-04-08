import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction_model.dart';
import '../providers/data_provider.dart';
import 'app_api_service.dart';

class LLMContextService {
  static const String _baseUrl = 'https://your-fastapi-server.com';

  static Future<Map<String, dynamic>> gatherContext(DataProvider data) async {
    final Map<String, dynamic> context = {
      'user_profile': _buildUserProfile(data),
      'current_month_stats': _buildCurrentMonthStats(data),
      'user_cluster': null,
      'forecast': null,
      'transaction_patterns': [],
    };

    try {
      final cluster = await AppApiService.getUserCluster(data);
      if (cluster != null) {
        context['user_cluster'] = cluster;
      }

      final forecast = await AppApiService.forecastNextMonth(data);
      if (forecast != null) {
        context['forecast'] = forecast;
      }
    } catch (e) {
      print('Error gathering API context: $e');
    }

    return context;
  }

  static Map<String, dynamic> _buildUserProfile(DataProvider data) {
    final now = DateTime.now();

    final expenses = data.currentMonthExpenses;
    final income = data.currentMonthIncome;

    return {
      'monthly_income': income,
      'monthly_expenses': expenses,
      'monthly_savings': income - expenses,
      'spending_trend': data.expenseTrendPercent,
      'savings_trend': data.savingsTrendPercent,
      'transaction_count': data.transactions.length,
      'transaction_categories': {
        'gastos': data.expensesByCategory,
        'ingresos': data.incomeByCategory,
      },
      'spending_by_origin': data.expensesByOrigin,
    };
  }

  static Map<String, dynamic> _buildCurrentMonthStats(DataProvider data) {
    final Map<String, double> byCategory = {};
    final Map<String, double> byOrigin = {};
    final Map<String, double> byMonth = {};
    final List<Map<String, dynamic>> recentTransactions = [];

    final transactions = data.transactions
        .where(
          (t) =>
              t.createdAt.year == DateTime.now().year &&
              t.createdAt.month == DateTime.now().month,
        )
        .toList();

    for (final t in transactions) {
      final category = t.category.isNotEmpty ? t.category : 'Otro';
      byCategory[category] = (byCategory[category] ?? 0) + t.amount.abs();

      final origin = t.origin.isNotEmpty ? t.origin : 'Otro';
      byOrigin[origin] = (byOrigin[origin] ?? 0) + t.amount.abs();
    }

    for (int i = 3; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i * 30));
      final monthExpenses = transactions
          .where((t) => t.createdAt.month == date.month)
          .fold(0.0, (sum, t) => sum + t.amount.abs());
      byMonth['mes_${date.month}'] = monthExpenses;
    }

    for (int i = 0; i < 10 && i < transactions.length; i++) {
      final t = transactions[i];
      recentTransactions.add({
        'amount': t.amount.abs(),
        'category': t.category,
        'origin': t.origin,
        'type': t.tipo,
        'date': t.createdAt.toIso8601String(),
      });
    }

    return {
      'by_category': byCategory,
      'by_origin': byOrigin,
      'monthly_trend': byMonth,
      'recent_transactions': recentTransactions,
    };
  }

  static Future<String> buildLLMPrompt(DataProvider data) async {
    final context = await gatherContext(data);

    final String prompt =
        '''
    Eres un asistante financiero experto para usuarios mexicanos.
    
    INFORMACIÓN DEL USUARIO:
    - Ingreso mensual: \$${context['user_profile']['monthly_income'].toStringAsFixed(0)}
    - Gasto mensual: \$${context['user_profile']['monthly_expenses'].toStringAsFixed(0)}
    - Ahorro mensual: \$${context['user_profile']['monthly_savings'].toStringAsFixed(0)}
    - Tendencia gastos: \${context['user_profile']['spending_trend'].toStringAsFixed(0)}% vs mes anterior
    - Tendencia ahorro: \${context['user_profile']['savings_trend'].toStringAsFixed(0)}% vs mes anterior
    
    CLUSTER DE USUARIO:
    ${context['user_cluster'] != null ? 'Perfil: ${context['user_cluster']['cluster_label']}' : 'Cargando perfil...'}
    
    PRONÓSTICO AI:
    ${context['forecast'] != null ? 'Previsión mes siguiente: \$${context['forecast']['predicted_spend'].toStringAsFixed(0)} (Tier: ${context['forecast']['spending_tier']})' : 'Cargando pronóstico...'}
    
    DISTRIBUCIÓN GASTOS POR CATEGORÍA:
    ${context['user_profile']['transaction_categories']['gastos']!.entries.map((e) => '- ${e.key}: \$${e.value.toStringAsFixed(0)} (${(e.value / context['user_profile']['monthly_expenses'] * 100).toStringAsFixed(1)}%)').join('\n    ')}
    
    DISTRIBUCIÓN GASTOS POR ORIGEN:
    ${context['user_profile']['spending_by_origin']!.entries.map((e) => '- ${e.key}: \$${e.value.toStringAsFixed(0)}').join('\n    ')}
    
    ANÁLISIS Y RECOMENDACIONES:
    Por favor, analiza este perfil financiero y proporciona:
    1. Un resumen conciso del estado financiero actual
    2. Insights sobre patrones de gasto
    3. Recomendaciones personalizadas basadas en el cluster de usuario
    4. Advertencias si hay gastos excesivos o oportunidades de ahorro
    5. Pronóstico basado en el modelo de predicción AI
    
    Responde en español, de forma amable y profesional.
    ''';

    return prompt;
  }

  static Future<String?> callLLMWithApiContext(DataProvider data) async {
    try {
      final context = await gatherContext(data);
      final prompt = await buildLLMPrompt(data);

      final response = await http.post(
        Uri.parse('$_baseUrl/llm/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'context': {
            'user_cluster': context['user_cluster'],
            'forecast': context['forecast'],
          },
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['response'];
      }
    } catch (e) {
      print('Error calling LLM: $e');
    }
    return null;
  }
}
