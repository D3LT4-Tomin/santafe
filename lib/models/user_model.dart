import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String email;
  final String? displayName;
  final double totalBalance;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.email,
    this.displayName,
    this.totalBalance = 0,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      totalBalance: (data['totalBalance'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'totalBalance': totalBalance,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
