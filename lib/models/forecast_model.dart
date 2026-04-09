class MonthlyData {
  final String monthLabel;
  final double amount;
  final double? pctChange;
  final bool isPredicted;

  const MonthlyData({
    required this.monthLabel,
    required this.amount,
    this.pctChange,
    this.isPredicted = false,
  });
}

class UserForecast {
  final double predictedSpend;
  final double predictedSavings;
  final String spendingTier;
  final int cluster;

  const UserForecast({
    required this.predictedSpend,
    required this.predictedSavings,
    required this.spendingTier,
    required this.cluster,
  });

  factory UserForecast.fromJson(Map<String, dynamic> json, double avgSavings) {
    return UserForecast(
      predictedSpend: (json['predicted_spend'] ?? 0).toDouble(),
      predictedSavings: avgSavings,
      spendingTier: json['spending_tier'] ?? 'desconocido',
      cluster: json['cluster'] ?? 0,
    );
  }
}
