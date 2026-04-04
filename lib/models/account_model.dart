import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType { bank, cash, investment }

class AccountModel {
  final String? id;
  final String name;
  final String? accountNumber;
  final double balance;
  final AccountType type;
  final String? logoUrl;
  final DateTime createdAt;

  AccountModel({
    this.id,
    required this.name,
    this.accountNumber,
    required this.balance,
    required this.type,
    this.logoUrl,
    required this.createdAt,
  });

  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountModel(
      id: doc.id,
      name: data['name'] ?? '',
      accountNumber: data['accountNumber'],
      balance: (data['balance'] ?? 0).toDouble(),
      type: AccountType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AccountType.bank,
      ),
      logoUrl: data['logoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'accountNumber': accountNumber,
      'balance': balance,
      'type': type.name,
      'logoUrl': logoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AccountModel copyWith({
    String? id,
    String? name,
    String? accountNumber,
    double? balance,
    AccountType? type,
    String? logoUrl,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
