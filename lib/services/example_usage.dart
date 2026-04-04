import '../models/transaction_model.dart';
import '../models/account_model.dart';
import 'auth_service.dart';
import 'transaction_service.dart';
import 'account_service.dart';

class ExampleUsage {
  Future<void> example() async {
    // 1. Sign up
    final user = await AuthService.signUp(
      'test@example.com',
      'password123',
      'Test User',
    );

    if (user?.id != null) {
      final uid = user!.id!;

      // 2. Add accounts
      await AccountService.addAccount(
        uid,
        AccountModel(
          name: 'BBVA Nómina',
          accountNumber: '****5678',
          balance: 42850.00,
          type: AccountType.bank,
          logoUrl: 'https://bbva.com/favicon.ico',
          createdAt: DateTime.now(),
        ),
      );

      // 3. Add transactions
      await TransactionService.addTransaction(
        uid,
        TransactionModel(
          title: 'Tacos "El Güero"',
          subtitle: 'Comida · 14:20',
          amount: -85.00,
          category: 'Comida',
          origin: 'Efectivo',
          tipo: 'egreso',
          createdAt: DateTime.now(),
        ),
      );

      // 4. Get all transactions
      final transactions = await TransactionService.getTransactions(uid);

      // 5. Get accounts by type
      final banks = await AccountService.getAccountsByType(
        uid,
        AccountType.bank,
      );

      // 6. Watch real-time updates
      // TransactionService.watchTransactions(uid).listen((snapshot) {
      //   snapshot.docs.forEach((doc) => print(doc.data()));
      // });
    }

    // Sign out
    await AuthService.signOut();
  }
}
