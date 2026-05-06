// lib/screens/wallet/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_theme.dart';
import '../../services/app_provider.dart';
import '../../models/transaction_model.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _showTopUp(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Түрүүвч Цэнэглэх',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Дүн оруулна уу',
                prefixText: '\$  ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Quick amounts
            Wrap(
              spacing: 8,
              children: [10, 50, 100, 500]
                  .map((amt) => ActionChip(
                        label: Text('\$$amt',
                            style: GoogleFonts.notoSans(fontSize: 13)),
                        onPressed: () =>
                            controller.text = amt.toString(),
                        backgroundColor:
                            AppColors.primary.withOpacity(0.1),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final val = double.tryParse(controller.text);
                if (val == null || val <= 0) return;
                await context.read<AppProvider>().topUpWallet(val);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Түрүүвч амжилттай цэнэглэгдлээ!'),
                      backgroundColor: AppColors.income,
                    ),
                  );
                }
              },
              child: Text('Цэнэглэх',
                  style: GoogleFonts.notoSans(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final user = provider.currentUser;
        final fmt = NumberFormat('#,##0.00', 'en_US');
        final transactions = provider.transactions;

        // Compute chart data (last 7 income/expense)
        final incomeData = <double>[];
        final expenseData = <double>[];
        for (int i = 6; i >= 0; i--) {
          final day = DateTime.now().subtract(Duration(days: i));
          final dayTxns = transactions.where((t) =>
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day);
          incomeData.add(dayTxns
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (s, t) => s + t.amount));
          expenseData.add(dayTxns
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (s, t) => s + t.amount));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Түрүүвч',
                style:
                    GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Нийт Үлдэгдэл',
                        style: GoogleFonts.notoSans(
                            color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${fmt.format(user?.walletBalance ?? 0)}',
                        style: GoogleFonts.notoSans(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              '↓ Нийт Орлого',
                              '\$${fmt.format(user?.totalIncome ?? 0)}',
                              AppColors.income,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              '↑ Нийт Зарлага',
                              '\$${fmt.format(user?.totalExpense ?? 0)}',
                              AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Top up button
                ElevatedButton.icon(
                  onPressed: () => _showTopUp(context),
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text('Түрүүвч Цэнэглэх',
                      style: GoogleFonts.notoSans(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 24),

                // Chart
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7 хоногийн график',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _legendDot(AppColors.income, 'Орлого'),
                          const SizedBox(width: 16),
                          _legendDot(AppColors.expense, 'Зарлага'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (v) => FlLine(
                                color: AppColors.border,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, meta) {
                                    final days = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];
                                    final idx = v.toInt();
                                    if (idx < 0 || idx >= days.length) return const SizedBox();
                                    return Text(days[idx],
                                        style: GoogleFonts.notoSans(
                                            fontSize: 10,
                                            color: AppColors.textSecondary));
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: incomeData
                                    .asMap()
                                    .entries
                                    .map((e) =>
                                        FlSpot(e.key.toDouble(), e.value))
                                    .toList(),
                                isCurved: true,
                                color: AppColors.income,
                                barWidth: 2.5,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.income.withOpacity(0.08),
                                ),
                              ),
                              LineChartBarData(
                                spots: expenseData
                                    .asMap()
                                    .entries
                                    .map((e) =>
                                        FlSpot(e.key.toDouble(), e.value))
                                    .toList(),
                                isCurved: true,
                                color: AppColors.expense,
                                barWidth: 2.5,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.expense.withOpacity(0.08),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.notoSans(
                  color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                GoogleFonts.notoSans(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
