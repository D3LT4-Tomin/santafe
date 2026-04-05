import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  User? _firebaseUser;
  bool _isLoading = true;
  String? _error;

  UserModel? get user => _user;
  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseUser != null;
  String? get error => _error;

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        _user = await AuthService.getUserData(user.uid);
      } else {
        _user = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await AuthService.signIn(email, password);
      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Credenciales inválidas';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AUTH] signIn FirebaseAuthException: code=${e.code}, message=${e.message}',
      );
      _error = _getErrorMessage(e.code, e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, st) {
      debugPrint('[AUTH] signIn unexpected error: $e\n$st');
      _error = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String? displayName,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await AuthService.signUp(email, password, displayName);
      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Error al crear cuenta';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AUTH] signUp FirebaseAuthException: code=${e.code}, message=${e.message}',
      );
      _error = _getErrorMessage(e.code, e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, st) {
      debugPrint('[AUTH] signUp unexpected error: $e\n$st');
      _error = 'Error al crear cuenta: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    _user = null;
    _firebaseUser = null;
    notifyListeners();
  }

  Future<void> skipLogin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Bypass Firebase entirely to avoid macOS Keychain errors during dev
    await Future.delayed(const Duration(milliseconds: 500));

    _firebaseUser = null; // We don't need a real Firebase User object
    _user = UserModel(
      id: 'dev-user-123',
      email: 'dev@santafe.app',
      displayName: 'UX Designer',
      createdAt: DateTime.now(),
      totalBalance: 25400.50,
    );

    _isLoading = false;
    notifyListeners();
  }

  String _getErrorMessage(String code, [String? message]) {
    debugPrint('[AUTH] Error code: $code, message: $message');
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      default:
        return 'Error de autenticación';
    }
  }
}
