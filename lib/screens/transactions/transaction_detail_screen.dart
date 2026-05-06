// lib/screens/transactions/transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_theme.dart';
import '../../services/app_provider.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final color = isIncome ? AppColors.income : AppColors.expense;
    final emoji =
        AppConstants.categoryIcons[transaction.category] ?? '💰';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Гүйлгээний Дэлгэрэнгүй',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Устгах уу?',
                      style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
                  content: Text('Энэ гүйлгээг устгах уу?',
                      style: GoogleFonts.notoSans()),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Үгүй')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Тийм',
                            style: TextStyle(color: AppColors.expense))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<AppProvider>().deleteTransaction(transaction);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.9), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    transaction.title,
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isIncome ? '+' : '-'}\$${fmt.format(transaction.amount)}',
                    style: GoogleFonts.notoSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM d, yyyy').format(transaction.date),
                    style: GoogleFonts.notoSans(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Details card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow('Төрөл',
                      isIncome ? 'Орлого' : 'Зарлага', color),
                  const Divider(height: 24),
                  _buildDetailRow(
                      'Ангилал', transaction.category, AppColors.textPrimary),
                  const Divider(height: 24),
                  _buildDetailRow(
                      'ID',
                      transaction.id.substring(0, 12) + '...',
                      AppColors.textSecondary),
                  if (transaction.note != null) ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                        'Тэмдэглэл',
                        transaction.note!,
                        AppColors.textSecondary),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QR Code receipt
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Баримтын QR Код',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: transaction.qrData ??
                        'TXN:${transaction.id}',
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Баримт баталгаажуулахад ашиглана',
                    style: GoogleFonts.notoSans(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
              color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.notoSans(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
