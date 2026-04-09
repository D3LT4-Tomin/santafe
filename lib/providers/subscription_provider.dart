import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/subscription_service.dart';
import '../services/auth_service.dart';

class SubscriptionProvider with ChangeNotifier {
  SubscriptionPlan _currentPlan = SubscriptionPlan.free;
  bool _isLoading = false;
  String? _error;

  SubscriptionPlan get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  bool get isPremium => _currentPlan == SubscriptionPlan.premium;
  String? get error => _error;

  SubscriptionLimits get limits => SubscriptionLimits.fromPlan(_currentPlan);

  Future<void> loadPlan() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPlan = await SubscriptionService.getPlan(user.uid);
    } catch (e) {
      _error = e.toString();
      _currentPlan = SubscriptionPlan.free;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updatePlan(SubscriptionPlan newPlan) async {
    final user = AuthService.currentUser;
    if (user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SubscriptionService.updatePlan(user.uid, newPlan);
      _currentPlan = newPlan;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkCanCreateAccount() async {
    final user = AuthService.currentUser;
    if (user == null) return false;

    try {
      return await SubscriptionService.canCreateAccount(user.uid);
    } catch (e) {
      return false;
    }
  }
}
