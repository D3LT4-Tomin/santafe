import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlan { free, premium }

class SubscriptionLimits {
  final int maxAccounts;
  final int maxTransactions;
  final bool advancedFeatures;

  const SubscriptionLimits({
    required this.maxAccounts,
    required this.maxTransactions,
    required this.advancedFeatures,
  });

  static const SubscriptionLimits free = SubscriptionLimits(
    maxAccounts: 3,
    maxTransactions: 100,
    advancedFeatures: false,
  );

  static const SubscriptionLimits premium = SubscriptionLimits(
    maxAccounts: 10,
    maxTransactions: -1,
    advancedFeatures: true,
  );

  static SubscriptionLimits fromPlan(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.premium:
        return premium;
      case SubscriptionPlan.free:
        return free;
    }
  }
}

class UserModel {
  final String? id;
  final String email;
  final String? displayName;
  final double totalBalance;
  final DateTime createdAt;
  final SubscriptionPlan subscriptionPlan;

  UserModel({
    this.id,
    required this.email,
    this.displayName,
    this.totalBalance = 0,
    required this.createdAt,
    this.subscriptionPlan = SubscriptionPlan.free,
  });

  SubscriptionLimits get limits =>
      SubscriptionLimits.fromPlan(subscriptionPlan);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    SubscriptionPlan plan = SubscriptionPlan.free;
    if (data['subscriptionPlan'] != null) {
      try {
        plan = SubscriptionPlan.values.firstWhere(
          (e) => e.name == data['subscriptionPlan'],
          orElse: () => SubscriptionPlan.free,
        );
      } catch (e) {
        plan = SubscriptionPlan.free;
      }
    }

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      totalBalance: (data['totalBalance'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subscriptionPlan: plan,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'totalBalance': totalBalance,
      'createdAt': Timestamp.fromDate(createdAt),
      'subscriptionPlan': subscriptionPlan.name,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    double? totalBalance,
    DateTime? createdAt,
    SubscriptionPlan? subscriptionPlan,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      totalBalance: totalBalance ?? this.totalBalance,
      createdAt: createdAt ?? this.createdAt,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
    );
  }
}
