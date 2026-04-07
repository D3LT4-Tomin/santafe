import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/transaction_service.dart';
import '../services/account_service.dart';
import '../services/firebase_service.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../models/expense_data.dart';
import 'package:flutter/cupertino.dart';

class DataProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];
  bool _isLoading = true;
  bool _isSeeded = false;
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

  // ── Month Stats ──────────────────────────────────────────────────────────────

  DateTime get _currentMonthStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  DateTime get _previousMonthStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 1, 1);
  }

  DateTime get _previousMonthEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 0);
  }

  List<TransactionModel> get _currentMonthTransactions {
    return _transactions.where((t) {
      return t.createdAt.isAfter(_currentMonthStart) ||
          (t.createdAt.year == _currentMonthStart.year &&
              t.createdAt.month == _currentMonthStart.month);
    }).toList();
  }

  List<TransactionModel> get _previousMonthTransactions {
    return _transactions.where((t) {
      return t.createdAt.isAfter(_previousMonthStart) &&
          t.createdAt.isBefore(_previousMonthEnd.add(const Duration(days: 1)));
    }).toList();
  }

  double get currentMonthExpenses {
    return _currentMonthTransactions
        .where((t) => t.tipo == 'egreso')
        .fold(0.0, (total, t) => total + t.amount.abs());
  }

  double get currentMonthIncome {
    return _currentMonthTransactions
        .where((t) => t.tipo == 'ingreso')
        .fold(0.0, (total, t) => total + t.amount.abs());
  }

  double get currentMonthSavings {
    return currentMonthIncome - currentMonthExpenses;
  }

  double get previousMonthExpenses {
    return _previousMonthTransactions
        .where((t) => t.tipo == 'egreso')
        .fold(0.0, (total, t) => total + t.amount.abs());
  }

  double get previousMonthIncome {
    return _previousMonthTransactions
        .where((t) => t.tipo == 'ingreso')
        .fold(0.0, (total, t) => total + t.amount.abs());
  }

  double get previousMonthSavings {
    return previousMonthIncome - previousMonthExpenses;
  }

  int get expenseTrendPercent {
    if (previousMonthExpenses == 0) return 0;
    final diff = currentMonthExpenses - previousMonthExpenses;
    return ((diff / previousMonthExpenses) * 100).round();
  }

  int get savingsTrendPercent {
    if (previousMonthSavings == 0) return 0;
    final diff = currentMonthSavings - previousMonthSavings;
    return ((diff / previousMonthSavings.abs()) * 100).round();
  }

  // ── Origin breakdown ─────────────────────────────────────────────────────────

  Map<String, double> get expensesByOrigin {
    final Map<String, double> result = {};
    for (final t in _currentMonthTransactions.where(
      (t) => t.tipo == 'egreso',
    )) {
      final origin = t.origin.isNotEmpty ? t.origin : 'Otro';
      result[origin] = (result[origin] ?? 0) + t.amount.abs();
    }
    return result;
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> result = {};
    for (final t in _currentMonthTransactions.where(
      (t) => t.tipo == 'egreso',
    )) {
      final category = t.category.isNotEmpty ? t.category : 'Otro';
      result[category] = (result[category] ?? 0) + t.amount.abs();
    }
    return result;
  }

  Map<String, double> get incomeByCategory {
    final Map<String, double> result = {};
    for (final t in _currentMonthTransactions.where(
      (t) => t.tipo == 'ingreso',
    )) {
      final category = t.category.isNotEmpty ? t.category : 'Otro';
      result[category] = (result[category] ?? 0) + t.amount.abs();
    }
    return result;
  }

  void loadDataForUser(String userId) async {
    _isLoading = true;
    _transactionsLoaded = false;
    _accountsLoaded = false;
    notifyListeners();

    await _checkAndSeedData(userId);

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

  Future<void> _checkAndSeedData(String userId) async {
    try {
      final snapshot = await FirebaseService.userAccountsRef(
        userId,
      ).limit(1).get();
      // print('Accounts count: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty && !_isSeeded) {
        // print('No accounts found, running seed...');
        _isSeeded = true;
        await _seedData(userId);
      } else {
        // print('Accounts exist or already seeded, skipping seed');
        _isSeeded = true;
      }
    } catch (e) {
      // print('_checkAndSeedData failed: $e');
      _error = 'Failed to check seed data: $e';
      _isSeeded = true;
    }
  }

  Future<void> _seedData(String userId) async {
    // print('Starting seed data...');

    try {
      await FirebaseService.userAccountsRef(userId).add({
        'name': 'Cuenta Corriente',
        'accountNumber': '****4521',
        'balance': 1250.00,
        'type': 'bank',
        'logoUrl': null,
        'createdAt': Timestamp.now(),
      });

      await FirebaseService.userAccountsRef(userId).add({
        'name': 'Ahorros',
        'accountNumber': '****8932',
        'balance': 8500.00,
        'type': 'cash',
        'logoUrl': null,
        'createdAt': Timestamp.now(),
      });

      final accountsSnapshot = await FirebaseService.userAccountsRef(
        userId,
      ).get();
      final accounts = accountsSnapshot.docs;

      if (accounts.isEmpty) {
        // print('No accounts created, skipping transaction seed');
        _isSeeded = true;
        return;
      }

      final accountId1 = accounts[0].id;
      final accountName1 = accounts[0].data()['name'] as String;
      final accountId2 = accounts.length > 1 ? accounts[1].id : accountId1;
      final accountName2 = accounts.length > 1
          ? accounts[1].data()['name'] as String
          : accountName1;

      final allExpenses = [...kAllExpenses, ...kAdditionalExpenses];
      for (int i = 0; i < allExpenses.length; i++) {
        final expense = allExpenses[i];
        final amount = expense.tipo == 'egreso'
            ? -_parseAmount(expense.amount)
            : _parseAmount(expense.amount);

        final accountId = i % 2 == 0 ? accountId1 : accountId2;
        final accountName = i % 2 == 0 ? accountName1 : accountName2;

        await FirebaseService.userTransactionsRef(userId).add({
          'title': expense.title,
          'subtitle': expense.subtitle,
          'amount': amount,
          'category': expense.category,
          'origin': expense.origin,
          'tipo': expense.tipo,
          'createdAt': Timestamp.fromDate(
            _getDateFromSubtitle(expense.subtitle),
          ),
          'accountId': accountId,
          'accountName': accountName,
        });
      }

      // print('Seed data completed successfully');
      _isSeeded = true;
    } catch (e) {
      // print('Seed data failed: $e');
      _error = 'Failed to seed data: $e';
    }
  }

  double _parseAmount(String amountStr) {
    final cleaned = amountStr.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  DateTime _getDateFromSubtitle(String subtitle) {
    final now = DateTime.now();
    if (subtitle.contains('14:20') || subtitle.contains('08:45')) {
      return now;
    } else if (subtitle.contains('Ayer')) {
      return now.subtract(const Duration(days: 1));
    } else if (subtitle.contains('Lun')) {
      return now.subtract(const Duration(days: 2));
    } else if (subtitle.contains('Dom')) {
      return now.subtract(const Duration(days: 3));
    } else if (subtitle.contains('Sáb')) {
      return now.subtract(const Duration(days: 4));
    } else if (subtitle.contains('Vie')) {
      return now.subtract(const Duration(days: 5));
    } else if (subtitle.contains('Jue')) {
      return now.subtract(const Duration(days: 6));
    } else if (subtitle.contains('Mié')) {
      return now.subtract(const Duration(days: 7));
    } else if (subtitle.contains('Mar')) {
      return now.subtract(const Duration(days: 8));
    } else if (subtitle.contains('15 días')) {
      return now.subtract(const Duration(days: 15));
    } else if (subtitle.contains('12 días')) {
      return now.subtract(const Duration(days: 12));
    } else if (subtitle.contains('10 días')) {
      return now.subtract(const Duration(days: 10));
    } else if (subtitle.contains('5 días')) {
      return now.subtract(const Duration(days: 5));
    } else if (subtitle.contains('3 días')) {
      return now.subtract(const Duration(days: 3));
    }
    return now;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return;

    final transactionRef = await TransactionService.addTransaction(
      userId,
      transaction,
    );

    if (transaction.accountId != null) {
      await _updateAccountBalance(userId, transaction.accountId!, transaction);
    }
  }

  Future<void> _updateAccountBalance(
    String userId,
    String accountId,
    TransactionModel transaction,
  ) async {
    final accountRef = FirebaseService.userAccountsRef(userId).doc(accountId);

    try {
      final accountDoc = await accountRef.get();
      if (!accountDoc.exists) return;

      final currentBalance = (accountDoc.data()!['balance'] as num).toDouble();

      double newBalance;
      if (transaction.tipo == 'egreso') {
        newBalance = currentBalance - transaction.amount.abs();
      } else {
        newBalance = currentBalance + transaction.amount.abs();
      }

      await accountRef.update({'balance': newBalance});
    } catch (e) {
      // print('Error actualizando saldo: $e');
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
    _isSeeded = false;
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

  Future<void> deleteTransaction(String transactionId) async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return;

    await TransactionService.deleteTransaction(userId, transactionId);
  }
}
