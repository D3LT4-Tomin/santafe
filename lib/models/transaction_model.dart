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

  TransactionModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.category,
    required this.origin,
    required this.tipo,
    required this.createdAt,
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
    );
  }
}
