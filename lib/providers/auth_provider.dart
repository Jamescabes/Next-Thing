import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../demo_config.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService? _authService;
  final FirestoreService? _firestoreService;

  AuthProvider()
      : _authService = kDemoMode ? null : AuthService(),
        _firestoreService = kDemoMode ? null : FirestoreService();

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get uid => kDemoMode ? 'demo-user-001' : _user?.uid;
  String? get email => kDemoMode ? 'demo@nextthing.app' : _user?.email;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void init() {
    if (kDemoMode) {
      // Start unauthenticated so login screen is visible in demo
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    _authService!.authStateChanges.listen((user) {
      _user = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    if (kDemoMode) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService!.signInWithGoogle();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión con Google. Intenta de nuevo.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (kDemoMode) {
      _setLoading(true);
      await Future.delayed(const Duration(milliseconds: 800));
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    }
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService!.signInWithEmail(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e.code);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService!.signUpWithEmail(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e.code);
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    if (kDemoMode) return;
    await _authService!.signOut();
  }

  Future<bool> deleteAccount() async {
    if (kDemoMode) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      final uid = _authService!.uid;
      if (uid != null) {
        await _firestoreService!.deleteAllUserData(uid);
      }
      await _authService!.deleteAccount();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e.code);
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'invalid-email':
        return 'Correo electrónico inválido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento.';
      case 'requires-recent-login':
        return 'Debes iniciar sesión nuevamente para eliminar tu cuenta.';
      default:
        return 'Ocurrió un error. Intenta de nuevo.';
    }
  }
}
