import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  User? _firebaseUser;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<User?>? _authSubscription;

  UserModel? get user => _user;
  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseUser != null;
  String? get error => _error;

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (User? user) async {
        _firebaseUser = user;
        if (user != null) {
          try {
            _user = await AuthService.getUserData(user.uid);
            _error = null;
          } catch (_) {
            _user = null;
            _error = 'No se pudo cargar tu perfil de Firebase';
          }
        } else {
          _user = null;
          _error = null;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        _firebaseUser = null;
        _user = null;
        _error = _getAuthStreamErrorMessage(error);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  String _getAuthStreamErrorMessage(Object error) {
    final errorText = error.toString();
    if (errorText.contains('admin-restricted-operation') ||
        errorText.contains('operation-not-allowed')) {
      return 'Firebase Auth rechazó una operación deshabilitada en el proyecto. Revisa el método de inicio de sesión en Firebase Console.';
    }
    return 'Error al leer el estado de autenticación de Firebase';
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
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al iniciar sesión';
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
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al crear cuenta';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    _user = null;
    _firebaseUser = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  String _getErrorMessage(String code) {
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
      case 'admin-restricted-operation':
      case 'operation-not-allowed':
        return 'Firebase Auth tiene deshabilitada esta operación en el proyecto';
      default:
        return 'Error de autenticación';
    }
  }
}
