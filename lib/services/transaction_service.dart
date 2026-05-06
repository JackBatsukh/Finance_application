// lib/services/transaction_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data()))
            .toList());
  }

  Future<TransactionModel> addTransaction({
    required String userId,
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String? note,
    String? receiptUrl,
  }) async {
    final id = _uuid.v4();
    final qrData =
        'TXN:$id|USER:$userId|TITLE:$title|AMT:$amount|TYPE:${type == TransactionType.income ? "income" : "expense"}|DATE:${date.toIso8601String()}';

    final transaction = TransactionModel(
      id: id,
      userId: userId,
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
      receiptUrl: receiptUrl,
      qrData: qrData,
    );

    await _firestore
        .collection('transactions')
        .doc(id)
        .set(transaction.toMap());

    // Update user balance
    await _updateUserBalance(userId, amount, type);

    return transaction;
  }

  Future<void> _updateUserBalance(
      String userId, double amount, TransactionType type) async {
    final userRef = _firestore.collection('users').doc(userId);

    return _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      double balance = (data['walletBalance'] ?? 0).toDouble();
      double totalIncome = (data['totalIncome'] ?? 0).toDouble();
      double totalExpense = (data['totalExpense'] ?? 0).toDouble();

      if (type == TransactionType.income) {
        balance += amount;
        totalIncome += amount;
      } else {
        balance -= amount;
        totalExpense += amount;
      }

      txn.update(userRef, {
        'walletBalance': balance,
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
      });
    });
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    await _firestore
        .collection('transactions')
        .doc(transaction.id)
        .delete();

    // Reverse balance update
    await _updateUserBalance(
      transaction.userId,
      transaction.amount,
      transaction.type == TransactionType.income
          ? TransactionType.expense
          : TransactionType.income,
    );
  }

  // Top up wallet
  Future<void> topUpWallet(String userId, double amount) async {
    final id = _uuid.v4();
    final transaction = TransactionModel(
      id: id,
      userId: userId,
      title: 'Түрүүвч цэнэглэлт',
      amount: amount,
      type: TransactionType.income,
      category: 'Түрүүвч',
      date: DateTime.now(),
      qrData:
          'TOPUP:$id|USER:$userId|AMT:$amount|DATE:${DateTime.now().toIso8601String()}',
    );

    await _firestore
        .collection('transactions')
        .doc(id)
        .set(transaction.toMap());

    await _updateUserBalance(userId, amount, TransactionType.income);
  }
}
