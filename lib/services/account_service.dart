import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account_model.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'subscription_service.dart';

class AccountService {
  static Future<List<AccountModel>> getAccounts(String userId) async {
    final snapshot = await FirebaseService.userAccountsRef(userId).get();
    return snapshot.docs.map((doc) => AccountModel.fromFirestore(doc)).toList();
  }

  static Future<List<AccountModel>> getAccountsByType(
    String userId,
    AccountType type,
  ) async {
    final snapshot = await FirebaseService.userAccountsRef(
      userId,
    ).where('type', isEqualTo: type.name).get();

    return snapshot.docs.map((doc) => AccountModel.fromFirestore(doc)).toList();
  }

  static Future<void> addAccount(String userId, AccountModel account) async {
    // Verificar si el usuario puede crear más cuentas según su plan
    final canCreate = await SubscriptionService.canCreateAccount(userId);
    if (!canCreate) {
      throw Exception('Has alcanzado el límite de cuentas para tu plan actual');
    }

    await FirebaseService.userAccountsRef(userId).add(account.toFirestore());
  }

  static Future<void> updateAccount(
    String userId,
    String accountId,
    AccountModel account,
  ) async {
    await FirebaseService.userAccountsRef(
      userId,
    ).doc(accountId).update(account.toFirestore());
  }

  static Future<void> deleteAccount(String userId, String accountId) async {
    await FirebaseService.userAccountsRef(userId).doc(accountId).delete();
  }

  static Future<void> updateBalance(
    String userId,
    String accountId,
    double newBalance,
  ) async {
    await FirebaseService.userAccountsRef(
      userId,
    ).doc(accountId).update({'balance': newBalance});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchAccounts(
    String userId,
  ) {
    return FirebaseService.userAccountsRef(userId).snapshots();
  }
}
