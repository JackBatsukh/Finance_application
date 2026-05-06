// lib/services/app_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import 'auth_service.dart';
import 'transaction_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TransactionService _transactionService = TransactionService();

  UserModel? _currentUser;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isLoggedIn =>
      _authService.currentUser != null && _currentUser != null;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  // Listen to user stream
  void listenToUser() {
    _authService.userStream().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Listen to transactions
  void listenToTransactions() {
    if (_authService.currentUser == null) return;
    _transactionService
        .getTransactions(_authService.currentUser!.uid)
        .listen((txns) {
      _transactions = txns;
      notifyListeners();
    });
  }

  Future<bool> register(String name, String email, String password) async {
    setLoading(true);
    setError(null);
    try {
      final user =
          await _authService.register(name: name, email: email, password: password);
      _currentUser = user;
      listenToUser();
      listenToTransactions();
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);
    try {
      final user = await _authService.login(email: email, password: password);
      _currentUser = user;
      listenToUser();
      listenToTransactions();
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _transactions = [];
    notifyListeners();
  }

  Future<bool> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    if (_authService.currentUser == null) return false;
    setLoading(true);
    try {
      await _transactionService.addTransaction(
        userId: _authService.currentUser!.uid,
        title: title,
        amount: amount,
        type: type,
        category: category,
        date: date,
        note: note,
      );
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<void> topUpWallet(double amount) async {
    if (_authService.currentUser == null) return;
    await _transactionService.topUpWallet(_authService.currentUser!.uid, amount);
  }

  Future<void> deleteTransaction(TransactionModel txn) async {
    await _transactionService.deleteTransaction(txn);
  }

  void initAuth() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _currentUser = await _authService.getCurrentUserModel();
        listenToUser();
        listenToTransactions();
      } else {
        _currentUser = null;
        _transactions = [];
      }
      notifyListeners();
    });
  }
}
