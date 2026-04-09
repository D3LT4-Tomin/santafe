import '../models/user_model.dart';
import 'firebase_service.dart';

class SubscriptionService {
  static Future<void> updatePlan(
    String userId,
    SubscriptionPlan newPlan,
  ) async {
    await FirebaseService.userDoc(
      userId,
    ).update({'subscriptionPlan': newPlan.name});
  }

  static Future<SubscriptionPlan> getPlan(String userId) async {
    final doc = await FirebaseService.userDoc(userId).get();
    if (!doc.exists) return SubscriptionPlan.free;

    final user = UserModel.fromFirestore(doc);
    return user.subscriptionPlan;
  }

  static Future<bool> canCreateAccount(String userId) async {
    final userDoc = await FirebaseService.userDoc(userId).get();
    if (!userDoc.exists) return true;

    final user = UserModel.fromFirestore(userDoc);
    final limit = user.limits.maxAccounts;

    final accountsSnapshot = await FirebaseService.userAccountsRef(
      userId,
    ).count().get();
    final currentCount = accountsSnapshot.count ?? 0;

    if (limit == -1) return true;
    return currentCount < limit;
  }

  static Future<int> getAccountCount(String userId) async {
    final snapshot = await FirebaseService.userAccountsRef(
      userId,
    ).count().get();
    return snapshot.count ?? 0;
  }
}
