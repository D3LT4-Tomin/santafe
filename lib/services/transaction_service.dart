import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import 'firebase_service.dart';

class TransactionService {
  static Future<List<TransactionModel>> getTransactions(String userId) async {
    final snapshot = await FirebaseService.userTransactionsRef(
      userId,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  static Future<List<TransactionModel>> getTransactionsByCategory(
    String userId,
    String category,
  ) async {
    final snapshot = await FirebaseService.userTransactionsRef(userId)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  static Future<List<TransactionModel>> getTransactionsByTipo(
    String userId,
    String tipo,
  ) async {
    final snapshot = await FirebaseService.userTransactionsRef(userId)
        .where('tipo', isEqualTo: tipo)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  static Future<void> addTransaction(
    String userId,
    TransactionModel transaction,
  ) async {
    await FirebaseService.userTransactionsRef(
      userId,
    ).add(transaction.toFirestore());
  }

  static Future<void> updateTransaction(
    String userId,
    String transactionId,
    TransactionModel transaction,
  ) async {
    await FirebaseService.userTransactionsRef(
      userId,
    ).doc(transactionId).update(transaction.toFirestore());
  }

  static Future<void> deleteTransaction(
    String userId,
    String transactionId,
  ) async {
    await FirebaseService.userTransactionsRef(
      userId,
    ).doc(transactionId).delete();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchTransactions(
    String userId,
  ) {
    return FirebaseService.userTransactionsRef(
      userId,
    ).orderBy('createdAt', descending: true).snapshots();
  }
}
