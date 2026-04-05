import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String? id;
  final String title;
  final String subtitle;
  final double amount;
  final String category;
  final String origin;
  final String tipo;
  final DateTime createdAt;
  final String? accountId;
  final String? accountName;

  TransactionModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.category,
    required this.origin,
    required this.tipo,
    required this.createdAt,
    this.accountId,
    this.accountName,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      origin: data['origin'] ?? '',
      tipo: data['tipo'] ?? 'egreso',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      accountId: data['accountId'],
      accountName: data['accountName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'category': category,
      'origin': origin,
      'tipo': tipo,
      'createdAt': Timestamp.fromDate(createdAt),
      'accountId': accountId,
      'accountName': accountName,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? amount,
    String? category,
    String? origin,
    String? tipo,
    DateTime? createdAt,
    String? accountId,
    String? accountName,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      origin: origin ?? this.origin,
      tipo: tipo ?? this.tipo,
      createdAt: createdAt ?? this.createdAt,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
    );
  }
}
