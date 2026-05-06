// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final double walletBalance;
  final double totalIncome;
  final double totalExpense;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.walletBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'walletBalance': walletBalance,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      walletBalance: (map['walletBalance'] ?? 0).toDouble(),
      totalIncome: (map['totalIncome'] ?? 0).toDouble(),
      totalExpense: (map['totalExpense'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  UserModel copyWith({
    String? name,
    double? walletBalance,
    double? totalIncome,
    double? totalExpense,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      walletBalance: walletBalance ?? this.walletBalance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      createdAt: createdAt,
    );
  }
}
