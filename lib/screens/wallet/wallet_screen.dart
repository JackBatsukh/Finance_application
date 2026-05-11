// lib/screens/wallet/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_theme.dart';
import '../../services/app_provider.dart';
import '../../models/transaction_model.dart';
import '../../widgets/transaction_tile.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCard = 0;

  // Demo cards
  final List<Map<String, dynamic>> _cards = [
    {
      'number': '**** **** **** 4242',
      'holder': 'BAYARJAVKHLAN B.',
      'expiry': '12/27',
      'type': 'visa',
      'gradient': [Color(0xFF2D9B83), Color(0xFF1E6E5C)],
      'balance': 2548.00,
    },
    {
      'number': '**** **** **** 8810',
      'holder': 'BAYAR J.',
      'expiry': '08/26',
      'type': 'mastercard',
      'gradient': [Color(0xFF6C63FF), Color(0xFF3B37B0)],
      'balance': 820.50,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Top Up Sheet ──────────────────────────────────────────────
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
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Text('Түрүүвч Цэнэглэх',
                    style: GoogleFonts.notoSans(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: GoogleFonts.notoSans(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '\$  ',
                prefixStyle: GoogleFonts.notoSans(
                    fontSize: 24, fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [10, 50, 100, 500].map((amt) => GestureDetector(
                onTap: () => controller.text = amt.toString(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text('\$$amt',
                      style: GoogleFonts.notoSans(
                          color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              )).toList(),
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
                      content: Text('✅ \$${val.toStringAsFixed(2)} амжилттай цэнэглэгдлээ!'),
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

  // ── Transfer Sheet ────────────────────────────────────────────
  void _showTransfer(BuildContext context) {
    final amountCtrl = TextEditingController();
    final toCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.send_rounded, color: Colors.blue, size: 22),
              ),
              const SizedBox(width: 12),
              Text('Гүйлгээ Хийх', style: GoogleFonts.notoSans(
                  fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: toCtrl,
              decoration: const InputDecoration(
                hintText: 'Хүлээн авагчийн и-мэйл эсвэл дугаар',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Дүн',
                prefixText: '\$  ',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Гүйлгээ илгээгдлээ — хүлээгдэж байна'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: Text('Илгээх', style: GoogleFonts.notoSans(
                  fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add Card Sheet ────────────────────────────────────────────
  void _showAddCard(BuildContext context) {
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.border,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.credit_card, color: Colors.orange, size: 22),
                ),
                const SizedBox(width: 12),
                Text('Карт Холбох', style: GoogleFonts.notoSans(
                    fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 20),
              // Card preview
              Container(
                width: double.infinity,
                height: 100,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Шинэ Карт',
                            style: GoogleFonts.notoSans(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('**** **** **** ****',
                            style: GoogleFonts.notoSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Icon(Icons.credit_card, color: Colors.white, size: 36),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: numberCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Картын дугаар',
                  prefixIcon: Icon(Icons.credit_card),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Картын эзэмшигчийн нэр',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: expiryCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'MM/YY',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: cvvCtrl,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'CVV',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Карт амжилттай холбогдлоо!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: Text('Карт Холбох',
                    style: GoogleFonts.notoSans(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final user = provider.currentUser;
        final fmt = NumberFormat('#,##0.00', 'en_US');
        final allTxns = provider.transactions;
        final pending = allTxns.where((t) =>
            t.date.isAfter(DateTime.now().subtract(const Duration(hours: 2)))).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Түрүүвч',
                style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [

              // ── 1. BALANCE HEADER ──────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: Column(
                  children: [
                    Text('Нийт Үлдэгдэл',
                        style: GoogleFonts.notoSans(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      '\$${fmt.format(user?.walletBalance ?? 0)}',
                      style: GoogleFonts.notoSans(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_upward,
                            color: Colors.greenAccent, size: 14),
                        Text(' 3.2% энэ сар',
                            style: GoogleFonts.notoSans(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Income / Expense row
                    Row(
                      children: [
                        Expanded(child: _balanceTile(
                          '↓ Орлого',
                          '\$${fmt.format(user?.totalIncome ?? 0)}',
                          AppColors.income,
                          Icons.south_west_rounded,
                        )),
                        Container(width: 1, height: 44, color: Colors.white24),
                        Expanded(child: _balanceTile(
                          '↑ Зарлага',
                          '\$${fmt.format(user?.totalExpense ?? 0)}',
                          Colors.redAccent,
                          Icons.north_east_rounded,
                          right: true,
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              // ── 2. ACTION BUTTONS ──────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Цэнэглэх',
                      color: AppColors.primary,
                      onTap: () => _showTopUp(context),
                    ),
                    _actionButton(
                      icon: Icons.send_rounded,
                      label: 'Гүйлгээ',
                      color: Colors.blue,
                      onTap: () => _showTransfer(context),
                    ),
                    _actionButton(
                      icon: Icons.payment_rounded,
                      label: 'Төлбөр',
                      color: Colors.orange,
                      onTap: () => _showPayment(context),
                    ),
                    _actionButton(
                      icon: Icons.history_rounded,
                      label: 'Түүх',
                      color: Colors.purple,
                      onTap: () => _tabController.animateTo(0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── 3. CARDS SECTION ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Миний Картууд',
                        style: GoogleFonts.notoSans(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    GestureDetector(
                      onTap: () => _showAddCard(context),
                      child: Row(children: [
                        const Icon(Icons.add, color: AppColors.primary, size: 18),
                        Text(' Карт нэмэх',
                            style: GoogleFonts.notoSans(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                ),
              ),

              // Cards horizontal scroll
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _cards.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == _cards.length) {
                      // Add card button
                      return GestureDetector(
                        onTap: () => _showAddCard(context),
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 2,
                                style: BorderStyle.solid),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_rounded,
                                    color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(height: 10),
                              Text('Карт Нэмэх',
                                  style: GoogleFonts.notoSans(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      );
                    }
                    final card = _cards[i];
                    final isSelected = _selectedCard == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCard = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 220,
                        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: List<Color>.from(card['gradient']),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (card['gradient'][0] as Color).withOpacity(0.4),
                              blurRadius: isSelected ? 16 : 8,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(card['type'] == 'visa' ? 'VISA' : 'MC',
                                    style: GoogleFonts.notoSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        letterSpacing: 2)),
                                Icon(
                                  card['type'] == 'visa'
                                      ? Icons.credit_card
                                      : Icons.credit_score,
                                  color: Colors.white70, size: 28,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(card['number'],
                                style: GoogleFonts.notoSans(
                                    color: Colors.white,
                                    fontSize: 14,
                                    letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Эзэмшигч',
                                        style: GoogleFonts.notoSans(
                                            color: Colors.white54, fontSize: 10)),
                                    Text(card['holder'],
                                        style: GoogleFonts.notoSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Дуусах',
                                        style: GoogleFonts.notoSans(
                                            color: Colors.white54, fontSize: 10)),
                                    Text(card['expiry'],
                                        style: GoogleFonts.notoSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── 4. TRANSACTIONS TAB ────────────────────────────
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.notoSans(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_outlined, size: 16),
                          const SizedBox(width: 6),
                          const Text('Гүйлгээнүүд'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pending_outlined, size: 16),
                          const SizedBox(width: 6),
                          Text('Хүлээгдэж буй'
                              '${pending.isNotEmpty ? " (${pending.length})" : ""}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // TabBarView content (static height via ListView trick)
              _buildTabContent(allTxns, pending),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  // ── Tab content ───────────────────────────────────────────────
  Widget _buildTabContent(
      List<TransactionModel> all, List<TransactionModel> pending) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final isFirst = _tabController.index == 0;
        final list = isFirst ? all : pending;

        if (list.isEmpty) {
          return Container(
            height: 200,
            color: AppColors.background,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFirst
                        ? Icons.receipt_long_outlined
                        : Icons.pending_outlined,
                    size: 52,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isFirst
                        ? 'Гүйлгээ байхгүй байна'
                        : 'Хүлээгдэж буй гүйлгээ байхгүй',
                    style: GoogleFonts.notoSans(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: list
                .take(20)
                .map((t) => _buildTxnTile(t, isPending: !isFirst))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildTxnTile(TransactionModel t, {bool isPending = false}) {
    final isIncome = t.type == TransactionType.income;
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final emoji = AppConstants.categoryIcons[t.category] ?? '💰';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPending
            ? Border.all(color: Colors.orange.withOpacity(0.4))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isIncome
                      ? AppColors.income.withOpacity(0.1)
                      : AppColors.expense.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 22))),
              ),
              if (isPending)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy').format(t.date),
                      style: GoogleFonts.notoSans(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Хүлээгдэж байна',
                            style: GoogleFonts.notoSans(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}\$${fmt.format(t.amount)}',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Widget _balanceTile(
      String label, String value, Color color, IconData icon,
      {bool right = false}) {
    return Padding(
      padding: EdgeInsets.only(
          left: right ? 16 : 4, right: right ? 4 : 16),
      child: Column(
        crossAxisAlignment:
        right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            right ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label,
                  style: GoogleFonts.notoSans(
                      color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // ── Payment Sheet ─────────────────────────────────────────────
  void _showPayment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.payment_rounded,
                    color: Colors.orange, size: 22),
              ),
              const SizedBox(width: 12),
              Text('Төлбөр', style: GoogleFonts.notoSans(
                  fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 20),
            // Quick payment categories
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _payCategory(Icons.bolt, 'Цахилгаан', Colors.yellow[700]!),
                _payCategory(Icons.water_drop, 'Ус', Colors.blue),
                _payCategory(Icons.wifi, 'Интернет', Colors.indigo),
                _payCategory(Icons.phone_android, 'Утас', Colors.green),
                _payCategory(Icons.local_gas_station, 'Газ', Colors.orange),
                _payCategory(Icons.tv, 'ТВ', Colors.red),
                _payCategory(Icons.directions_bus, 'Тээвэр', Colors.teal),
                _payCategory(Icons.more_horiz, 'Бусад', Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _payCategory(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label төлбөр — удахгүй нэмэгдэнэ')),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.notoSans(fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}