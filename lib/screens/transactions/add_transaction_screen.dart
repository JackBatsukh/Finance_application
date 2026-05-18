// lib/screens/transactions/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../services/app_provider.dart';
import '../../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _type = TransactionType.expense;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = AppConstants.expenseCategories[0];
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get _categories => _type == TransactionType.income
      ? AppConstants.incomeCategories
      : AppConstants.expenseCategories;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
          const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final provider = context.read<AppProvider>();

    // Зарлага бол урьдчилж үлдэгдэл шалгана
    if (_type == TransactionType.expense) {
      final balance = provider.currentUser?.walletBalance ?? 0;
      if (amount > balance) {
        _showInsufficientDialog(balance: balance, requested: amount);
        return;
      }
    }

    final result = await provider.addTransaction(
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('Гүйлгээ амжилттай нэмэгдлээ!',
                style: GoogleFonts.notoSans()),
          ]),
          backgroundColor: AppColors.income,
        ),
      );
      Navigator.pop(context);
    } else if (result.insufficientBalance) {
      _showInsufficientDialog(
        balance: provider.currentUser?.walletBalance ?? 0,
        requested: amount,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Алдаа гарлаа'),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  // ── Үлдэгдэл дутагдсан үед харуулах dialog ─────────────────
  void _showInsufficientDialog({
    required double balance,
    required double requested,
  }) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final shortage = requested - balance;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Red header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: const BoxDecoration(
                color: AppColors.expense,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text('Үлдэгдэл хүрэлцэхгүй!',
                    style: GoogleFonts.notoSans(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
              ]),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _dialogRow('💰 Данс дахь мөнгө',
                    '\$${fmt.format(balance)}', Colors.green),
                const SizedBox(height: 10),
                _dialogRow('💸 Хийх гэсэн зарлага',
                    '\$${fmt.format(requested)}', AppColors.expense),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AppColors.border),
                ),
                _dialogRow('⚠️ Дутагдал',
                    '\$${fmt.format(shortage)}', Colors.orange,
                    bold: true),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Түрүүвчээ цэнэглэж \$${fmt.format(shortage)}-г нэмсний дараа зарлагаа хийнэ үү.',
                        style: GoogleFonts.notoSans(
                            fontSize: 12, color: Colors.orange[800]),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 46),
                    ),
                    child: Text('Болих',
                        style: GoogleFonts.notoSans(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context); // AddTransaction хаана
                      // Wallet tab руу шилжихийн тулд event emit
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 46),
                    ),
                    child: Text('Цэнэглэх',
                        style: GoogleFonts.notoSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogRow(String label, String value, Color color,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.notoSans(
                fontSize: 13, color: AppColors.textSecondary)),
        Text(value,
            style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Гүйлгээ нэмэх',
            style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Орлого / Зарлага сонгох ───────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10)],
                ),
                child: Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _type = TransactionType.income;
                        _selectedCategory =
                        AppConstants.incomeCategories[0];
                      }),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _type == TransactionType.income
                              ? AppColors.income
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(16)),
                        ),
                        child: Text('↓ Орлого',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.bold,
                              color: _type == TransactionType.income
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _type = TransactionType.expense;
                        _selectedCategory =
                        AppConstants.expenseCategories[0];
                      }),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _type == TransactionType.expense
                              ? AppColors.expense
                              : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(16)),
                        ),
                        child: Text('↑ Зарлага',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.bold,
                              color: _type == TransactionType.expense
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            )),
                      ),
                    ),
                  ),
                ]),
              ),

              // Зарлага үед баланс харуулах
              if (_type == TransactionType.expense)
                Consumer<AppProvider>(
                  builder: (_, provider, __) {
                    final balance =
                        provider.currentUser?.walletBalance ?? 0;
                    final fmt = NumberFormat('#,##0.00', 'en_US');
                    return Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.income.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.income.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            color: AppColors.income, size: 18),
                        const SizedBox(width: 8),
                        Text('Боломжит үлдэгдэл: ',
                            style: GoogleFonts.notoSans(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                        Text('\$${fmt.format(balance)}',
                            style: GoogleFonts.notoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.income)),
                      ]),
                    );
                  },
                ),

              const SizedBox(height: 20),

              _label('Гарчиг'),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    hintText: 'Гүйлгээний гарчиг'),
                validator: (v) =>
                v!.isEmpty ? 'Гарчиг оруулна уу' : null,
              ),

              const SizedBox(height: 16),

              _label('Дүн (\$)'),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: const InputDecoration(
                    hintText: '0.00', prefixText: '\$  '),
                validator: (v) {
                  if (v!.isEmpty) return 'Дүн оруулна уу';
                  if (double.tryParse(v) == null) return 'Буруу тоо';
                  if (double.parse(v) <= 0)
                    return 'Дүн 0-ээс их байх ёстой';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Ангилал'),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Row(children: [
                        Text(
                            AppConstants.categoryIcons[c] ??
                                '📦',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Text(c,
                            style: GoogleFonts.notoSans(
                                fontSize: 14)),
                      ]),
                    ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCategory = v!),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _label('Огноо'),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('yyyy/MM/dd').format(_selectedDate),
                      style: GoogleFonts.notoSans(fontSize: 14),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 16),

              _label('Тэмдэглэл (заавал биш)'),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Нэмэлт тэмдэглэл...'),
              ),

              const SizedBox(height: 28),

              Consumer<AppProvider>(
                builder: (_, provider, __) => ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == TransactionType.income
                        ? AppColors.income
                        : AppColors.expense,
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : Text('Хадгалах',
                      style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
  );
}