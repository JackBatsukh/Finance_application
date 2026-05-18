// lib/screens/wallet/bill_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import 'bill_payment_confirm_screen.dart';
import 'wallet_screen.dart';

class BillDetailScreen extends StatefulWidget {
  final PendingBill bill;
  final List<Map<String, dynamic>> cards;

  const BillDetailScreen({
    super.key,
    required this.bill,
    required this.cards,
  });

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  String _selectedMethod = 'card'; // 'card' or 'wallet'
  int _selectedCardIdx = 0;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final bill = widget.bill;
    final dateStr = DateFormat('MMM d, yyyy').format(bill.date);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Bill Details',
            style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Bill Info Card ──────────────────────────────
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: bill.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(bill.icon, color: bill.color, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bill.title,
                                    style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text(dateStr,
                                    style: GoogleFonts.notoSans(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                              ]),
                        ]),

                        const SizedBox(height: 20),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 12),

                        _billRow('Үнэ', '\$${fmt.format(bill.price)}'),
                        const SizedBox(height: 10),
                        _billRow('Хурааmж', '\$${fmt.format(bill.tax)}'),
                        const SizedBox(height: 14),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 10),
                        _billRow('Нийт', '\$${fmt.format(bill.total)}',
                            bold: true, large: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Payment Method ──────────────────────────────
                  Text('Төлбөрийн хэрэгслэ сонго',
                      style: GoogleFonts.notoSans(
                          fontSize: 15, fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 14),

                  // Debit Card option
                  GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 'card'),
                    child: _methodTile(
                      isSelected: _selectedMethod == 'card',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.credit_card_rounded,
                                  color: Colors.blue, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Дебит Карт',
                                style: GoogleFonts.notoSans(
                                    fontWeight: FontWeight.w600, fontSize: 15))),
                            _radio(_selectedMethod == 'card'),
                          ]),

                          // Card selector (only when card selected)
                          if (_selectedMethod == 'card') ...[
                            const SizedBox(height: 14),
                            ...List.generate(widget.cards.length, (i) {
                              final card = widget.cards[i];
                              final isSel = _selectedCardIdx == i;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCardIdx = i),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: isSel ? LinearGradient(
                                        colors: List<Color>.from(card['gradient'])) : null,
                                    color: isSel ? null : AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: isSel
                                            ? Colors.transparent
                                            : AppColors.border),
                                  ),
                                  child: Row(children: [
                                    Icon(Icons.credit_card,
                                        size: 18,
                                        color: isSel ? Colors.white : AppColors.textSecondary),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(
                                      '${card['type'].toString().toUpperCase()}  ${card['number']}',
                                      style: GoogleFonts.notoSans(
                                          fontSize: 13,
                                          color: isSel ? Colors.white : AppColors.textPrimary,
                                          fontWeight: FontWeight.w500),
                                    )),
                                    if (isSel)
                                      const Icon(Icons.check_circle,
                                          color: Colors.white, size: 18),
                                  ]),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Wallet option
                  GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 'wallet'),
                    child: _methodTile(
                      isSelected: _selectedMethod == 'wallet',
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Түрүүвч',
                            style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.w600, fontSize: 15))),
                        _radio(_selectedMethod == 'wallet'),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Pay Button ─────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12, offset: const Offset(0, -3))],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BillPaymentConfirmScreen(
                      bill: bill,
                      paymentMethod: _selectedMethod,
                      selectedCard: _selectedMethod == 'card'
                          ? widget.cards[_selectedCardIdx]
                          : null,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Төлөх',
                  style: GoogleFonts.notoSans(
                      fontSize: 16, fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodTile({required bool isSelected, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: child,
    );
  }

  Widget _radio(bool selected) => Container(
    width: 22, height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: 2),
    ),
    child: selected
        ? Center(child: Container(
      width: 12, height: 12,
      decoration: const BoxDecoration(
          color: AppColors.primary, shape: BoxShape.circle),
    ))
        : null,
  );

  Widget _billRow(String label, String value,
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
                color: bold ? AppColors.textPrimary : AppColors.textSecondary)),
      ],
    );
  }
}