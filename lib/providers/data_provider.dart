import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/transaction_service.dart';
import '../services/account_service.dart';
import '../services/firebase_service.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import 'package:flutter/cupertino.dart';

class DataProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _transactionsSub;
  StreamSubscription? _accountsSub;
  bool _transactionsLoaded = false;
  bool _accountsLoaded = false;

  List<TransactionModel> get transactions => _transactions;
  List<AccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance {
    if (_accounts.isEmpty) return 0;
    return _accounts.fold(0.0, (total, account) => total + account.balance);
  }

  double get weeklyIncome {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _transactions
        .where((t) => t.tipo == 'ingreso' && t.createdAt.isAfter(weekAgo))
        .fold(0.0, (total, t) => total + t.amount);
  }

  void loadDataForUser(String userId) async {
    _isLoading = true;
    _transactionsLoaded = false;
    _accountsLoaded = false;
    notifyListeners();

    _loadTransactions(userId);
    _loadAccounts(userId);

    Future.delayed(const Duration(seconds: 5), () {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _loadTransactions(String userId) {
    _transactionsSub?.cancel();
    _transactionsLoaded = false;
    _transactionsSub = TransactionService.watchTransactions(userId).listen(
      (QuerySnapshot snapshot) {
        _transactions = snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList();
        _transactionsLoaded = true;
        _checkAllLoaded();
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _loadAccounts(String userId) {
    _accountsSub?.cancel();
    _accountsLoaded = false;
    _accountsSub = AccountService.watchAccounts(userId).listen(
      (QuerySnapshot snapshot) {
        _accounts = snapshot.docs
            .map((doc) => AccountModel.fromFirestore(doc))
            .toList();
        _accountsLoaded = true;
        _checkAllLoaded();
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _checkAllLoaded() {
    if (_transactionsLoaded && _accountsLoaded) {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _transactionsSub?.cancel();
    _accountsSub?.cancel();
    super.dispose();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final userId = FirebaseService.currentUserId;
    if (userId != null) {
      await TransactionService.addTransaction(userId, transaction);
    }
  }

  Future<void> addAccount(AccountModel account) async {
    final userId = FirebaseService.currentUserId;
    if (userId != null) {
      await AccountService.addAccount(userId, account);
    }
  }

  void clearData() {
    _transactions = [];
    _accounts = [];
    _isLoading = true;
    notifyListeners();
  }

  List<TransactionModel> getFilteredTransactions({
    String? category,
    String? origin,
    String? tipo,
  }) {
    return _transactions.where((t) {
      if (category != null && category != 'Todos' && t.category != category) {
        return false;
      }
      if (origin != null && origin != 'Todos' && t.origin != origin) {
        return false;
      }
      if (tipo != null && tipo != 'Todos' && t.tipo != tipo) {
        return false;
      }
      return true;
    }).toList();
  }
}
