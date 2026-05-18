// lib/screens/wallet/bill_payment_confirm_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../utils/app_theme.dart';
import '../../services/app_provider.dart';
import '../../models/transaction_model.dart';
import 'wallet_screen.dart';

class BillPaymentConfirmScreen extends StatefulWidget {
  final PendingBill bill;
  final String paymentMethod;
  final Map<String, dynamic>? selectedCard;

  const BillPaymentConfirmScreen({
    super.key,
    required this.bill,
    required this.paymentMethod,
    this.selectedCard,
  });

  @override
  State<BillPaymentConfirmScreen> createState() =>
      _BillPaymentConfirmScreenState();
}

class _BillPaymentConfirmScreenState extends State<BillPaymentConfirmScreen> {
  bool _isPaid = false;
  bool _isProcessing = false;
  late String _receiptId;
  late DateTime _paidAt;

  @override
  void initState() {
    super.initState();
    _receiptId = const Uuid().v4().substring(0, 16).toUpperCase();
    _paidAt = DateTime.now();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    final provider = context.read<AppProvider>();

    // Үлдэгдэл шалгана
    final balance = provider.currentUser?.walletBalance ?? 0;
    if (widget.bill.total > balance) {
      setState(() => _isProcessing = false);
      final fmt = NumberFormat('#,##0.00', 'en_US');
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.warning_rounded, color: AppColors.expense),
            const SizedBox(width: 8),
            Text('Үлдэгдэл дутмаг',
                style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('Данс', '\$${fmt.format(balance)}', Colors.green),
              const SizedBox(height: 8),
              _infoRow('Төлбөр', '\$${fmt.format(widget.bill.total)}',
                  AppColors.expense),
              const SizedBox(height: 8),
              _infoRow('Дутагдал',
                  '\$${fmt.format(widget.bill.total - balance)}',
                  Colors.orange),
              const SizedBox(height: 12),
              Text('Түрүүвчээ цэнэглэсний дараа дахин оролдоно уу.',
                  style: GoogleFonts.notoSans(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: Text('Ойлголоо',
                  style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    // Firebase-д хадгална
    await provider.addTransaction(
      title: widget.bill.title,
      amount: widget.bill.total,
      type: TransactionType.expense,
      category: widget.bill.category,
      date: DateTime.now(),
      note: 'Төлбөр — ${widget.paymentMethod == 'card' ? 'Дебит Карт' : 'Түрүүвч'}',
    );

    setState(() {
      _isProcessing = false;
      _isPaid = true;
      _paidAt = DateTime.now();
    });
  }

  Widget _infoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.notoSans(color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isPaid ? _buildReceipt() : _buildConfirm();
  }

  // ── Дэлгэц 2: Баталгаажуулалт ────────────────────────────────
  Widget _buildConfirm() {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final bill = widget.bill;
    final isCard = widget.paymentMethod == 'card';
    final card = widget.selectedCard;
    final methodLabel = isCard
        ? '${card!['type'].toString().toUpperCase()}  ${card['number']}'
        : 'Түрүүвч';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Bill Payment',
            style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [

              // Bill icon
              const SizedBox(height: 8),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: bill.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(bill.icon, color: bill.color, size: 34),
              ),
              const SizedBox(height: 16),

              // "You will pay X for one month with Y"
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.notoSans(
                      fontSize: 15, color: AppColors.textPrimary),
                  children: [
                    const TextSpan(text: 'Та '),
                    TextSpan(
                      text: bill.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                    TextSpan(
                      text: isCard
                          ? '\n${card!['type'].toString().toUpperCase()} картаар төлнө'
                          : '\nТүрүүвчнөөс төлнө',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount breakdown card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(children: [
                  _row('Үнэ', '\$${fmt.format(bill.price)}'),
                  const SizedBox(height: 10),
                  _row('Хурааmж', '\$${fmt.format(bill.tax)}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.border),
                  ),
                  _row('Нийт', '\$${fmt.format(bill.total)}',
                      bold: true, large: true),
                ]),
              ),

              const SizedBox(height: 16),

              // Payment method info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: [
                  Icon(
                    isCard
                        ? Icons.credit_card_rounded
                        : Icons.account_balance_wallet_rounded,
                    color: isCard ? Colors.blue : AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isCard ? 'Дебит Карт' : 'Түрүүвч',
                          style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.w600, fontSize: 13,
                              color: AppColors.textSecondary)),
                      Text(methodLabel,
                          style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  )),
                ]),
              ),
            ]),
          ),
        ),

        // ── Баталгаажуулах товч ───────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12, offset: const Offset(0, -3))],
          ),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: _isProcessing
                ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : Text('Баталгаажуулах',
                style: GoogleFonts.notoSans(
                    fontSize: 16, fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      ]),
    );
  }

  // ── Дэлгэц 3: QR Баримт ──────────────────────────────────────
  Widget _buildReceipt() {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final bill = widget.bill;
    final isCard = widget.paymentMethod == 'card';
    final timeStr = DateFormat('hh:mm a').format(_paidAt);
    final dateStr = DateFormat('MMM d, yyyy').format(_paidAt);

    final qrData =
        'RECEIPT:$_receiptId|TITLE:${bill.title}|PRICE:${bill.price}|TAX:${bill.tax}|TOTAL:${bill.total}|METHOD:${isCard ? 'Дебит Карт' : 'Түрүүвч'}|DATE:${_paidAt.toIso8601String()}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Bill Payment',
            style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [

              // ── Success header ────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(children: [
                  // Success icon
                  Container(
                    width: 56, height: 56,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text('Амжилттай Төлөгдлөө',
                      style: GoogleFonts.notoSans(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(bill.title,
                      style: GoogleFonts.notoSans(
                          fontSize: 14, color: AppColors.textSecondary)),
                ]),
              ),

              const SizedBox(height: 16),

              // ── Receipt detail ────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(children: [

                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Гүйлгээний дэлгэрэнгүй',
                            style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const Icon(Icons.keyboard_arrow_up_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      _receiptRow('Төлбөрийн харгалзаа',
                          isCard ? 'Дебит Карт' : 'Түрүүвч'),
                      _receiptRow('Төлөв', 'Хийгдсэн',
                          valueColor: AppColors.primary),
                      _receiptRow('Цаг', timeStr),
                      _receiptRow('Огноо', dateStr),
                      _receiptRow('Гүйлгээний дугаар', _receiptId,
                          hasQr: true),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(color: AppColors.border),
                      ),

                      _receiptRow('Үнэ', '\$${fmt.format(bill.price)}'),
                      const SizedBox(height: 8),
                      _receiptRow('Хурааmж', '- \$${fmt.format(bill.tax)}'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.border),
                      ),
                      _receiptRow('Нийт', '\$${fmt.format(bill.total)}',
                          bold: true),

                      const SizedBox(height: 20),

                      // ── QR Code ─────────────────────────────
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 160,
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),

              const SizedBox(height: 16),
            ]),
          ),
        ),

        // ── Share Receipt + Done ──────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          color: Colors.white,
          child: Column(children: [
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Баримт хуваалцлаа')));
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Share Receipt',
                  style: GoogleFonts.notoSans(
                      fontSize: 15, fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // BillDetail + ConfirmScreen хоёрыг хаагаад WalletScreen руу буцна
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Дуусгах',
                  style: GoogleFonts.notoSans(
                      fontSize: 15, fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Widget _row(String label, String value,
      {bool bold = false, bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.notoSans(
                fontSize: large ? 15 : 14,
                color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: GoogleFonts.notoSans(
                fontSize: large ? 16 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _receiptRow(String label, String value,
      {Color? valueColor, bool bold = false, bool hasQr = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.notoSans(
                  fontSize: 13, color: AppColors.textSecondary)),
          Row(children: [
            Text(value,
                style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary)),
            if (hasQr) ...[
              const SizedBox(width: 6),
              const Icon(Icons.qr_code_2_rounded,
                  size: 18, color: AppColors.primary),
            ],
          ]),
        ],
      ),
    );
  }
}