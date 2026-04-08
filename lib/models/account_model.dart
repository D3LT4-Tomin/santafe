import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType { bank, cash, investment }

enum BankAccountSubtype { debit, credit }

class AccountModel {
  final String? id;
  final String name;
  final String? accountNumber;
  final double balance;
  final AccountType type;
  final String? logoUrl;
  final DateTime createdAt;
  final double? returnRate;
  final BankAccountSubtype? bankSubtype;
  final double? creditLimit;
  final int? cutOffDay;
  final int? paymentDay;

  AccountModel({
    this.id,
    required this.name,
    this.accountNumber,
    required this.balance,
    required this.type,
    this.logoUrl,
    required this.createdAt,
    this.returnRate,
    this.bankSubtype,
    this.creditLimit,
    this.cutOffDay,
    this.paymentDay,
  });

  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    BankAccountSubtype? subtype;
    if (data['bankSubtype'] != null) {
      subtype = BankAccountSubtype.values.firstWhere(
        (e) => e.name == data['bankSubtype'],
        orElse: () => BankAccountSubtype.debit,
      );
    }
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
      returnRate: data['returnRate']?.toDouble(),
      bankSubtype: subtype,
      creditLimit: data['creditLimit']?.toDouble(),
      cutOffDay: data['cutOffDay'] as int?,
      paymentDay: data['paymentDay'] as int?,
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
      'returnRate': returnRate,
      'bankSubtype': bankSubtype?.name,
      'creditLimit': creditLimit,
      'cutOffDay': cutOffDay,
      'paymentDay': paymentDay,
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
    double? returnRate,
    BankAccountSubtype? bankSubtype,
    double? creditLimit,
    int? cutOffDay,
    int? paymentDay,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      returnRate: returnRate ?? this.returnRate,
      bankSubtype: bankSubtype ?? this.bankSubtype,
      creditLimit: creditLimit ?? this.creditLimit,
      cutOffDay: cutOffDay ?? this.cutOffDay,
      paymentDay: paymentDay ?? this.paymentDay,
    );
  }

  double calculateNewBalance(double transactionAmount, String tipo) {
    if (tipo == 'egreso') {
      return balance - transactionAmount.abs();
    } else {
      return balance + transactionAmount.abs();
    }
  }
}
