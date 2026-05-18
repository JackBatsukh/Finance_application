// lib/screens/wallet/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../services/app_provider.dart';
import '../../models/transaction_model.dart';
import 'bill_detail_screen.dart';

class PendingBill {
  final String id;
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final double price;
  final double tax;
  final DateTime date;
  bool isPaid;

  PendingBill({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.price,
    required this.tax,
    required this.date,
    this.isPaid = false,
  });

  double get total => price + tax;
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCard = 0;
  int _billIdCounter = 1;

  final List<PendingBill> _pendingBills = [];

  final List<Map<String, dynamic>> _cards = [
    {
      'number': '**** **** **** 4242',
      'holder': 'BAYAR J.',
      'expiry': '12/27',
      'type': 'visa',
      'gradient': [const Color(0xFF2D9B83), const Color(0xFF1E6E5C)],
    },
    {
      'number': '**** **** **** 8810',
      'holder': 'BAYAR J.',
      'expiry': '08/26',
      'type': 'mastercard',
      'gradient': [const Color(0xFF6C63FF), const Color(0xFF3B37B0)],
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

  // ── Төлбөрийн ангилал сонгох ──────────────────────────────────
  void _showPaymentCategories() {
    final categories = [
      {'icon': Icons.bolt, 'label': 'Цахилгаан', 'color': Colors.yellow[700]!, 'price': 45.00, 'tax': 4.50},
      {'icon': Icons.water_drop, 'label': 'Ус', 'color': Colors.blue, 'price': 18.00, 'tax': 1.80},
      {'icon': Icons.wifi, 'label': 'Интернет', 'color': Colors.indigo, 'price': 29.99, 'tax': 3.00},
      {'icon': Icons.phone_android, 'label': 'Утас', 'color': Colors.green, 'price': 15.00, 'tax': 1.50},
      {'icon': Icons.local_gas_station, 'label': 'Газ', 'color': Colors.orange, 'price': 55.00, 'tax': 5.50},
      {'icon': Icons.tv, 'label': 'Youtube', 'color': Colors.red, 'price': 11.99, 'tax': 1.99},
      {'icon': Icons.directions_bus, 'label': 'Тээвэр', 'color': Colors.teal, 'price': 20.00, 'tax': 2.00},
      {'icon': Icons.more_horiz, 'label': 'Бусад', 'color': Colors.grey, 'price': 10.00, 'tax': 1.00},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            const SizedBox(height: 16),
            Row(children: [
              _iconBox(Icons.payment_rounded, Colors.orange),
              const SizedBox(width: 12),
              Text('Төлбөрийн төрөл сонгох',
                  style: GoogleFonts.notoSans(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.82,
              physics: const NeverScrollableScrollPhysics(),
              children: categories.map((c) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    final bill = PendingBill(
                      id: 'BILL${_billIdCounter++}',
                      title: c['label'] as String,
                      category: c['label'] as String,
                      icon: c['icon'] as IconData,
                      color: c['color'] as Color,
                      price: c['price'] as double,
                      tax: c['tax'] as double,
                      date: DateTime.now(),
                    );
                    setState(() => _pendingBills.add(bill));
                    _tabController.animateTo(1);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${c['label']} хүлээгдэж буй жагсаалтад нэмэгдлээ'),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (c['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(c['icon'] as IconData,
                          color: c['color'] as Color, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(c['label'] as String,
                        style: GoogleFonts.notoSans(fontSize: 11),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ]),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopUp() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24, right: 24, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _handle(),
            const SizedBox(height: 20),
            Row(children: [
              _iconBox(Icons.add_circle_outline_rounded, AppColors.primary),
              const SizedBox(width: 12),
              Text('Түрүүвч Цэнэглэх',
                  style: GoogleFonts.notoSans(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              children: [10, 50, 100, 500].map((a) => GestureDetector(
                onTap: () => ctrl.text = a.toString(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text('\$$a',
                      style: GoogleFonts.notoSans(
                          color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final val = double.tryParse(ctrl.text);
                if (val == null || val <= 0) return;
                await context.read<AppProvider>().topUpWallet(val);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('✅ \$${val.toStringAsFixed(2)} цэнэглэгдлээ!'),
                    backgroundColor: AppColors.income,
                  ));
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

  void _showTransfer() {
    final toCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24, right: 24, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _handle(),
            const SizedBox(height: 20),
            Row(children: [
              _iconBox(Icons.send_rounded, Colors.blue),
              const SizedBox(width: 12),
              Text('Гүйлгээ Хийх',
                  style: GoogleFonts.notoSans(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 20),
            TextField(controller: toCtrl,
                decoration: const InputDecoration(
                    hintText: 'Хүлээн авагчийн и-мэйл',
                    prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
            TextField(controller: amtCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    hintText: 'Дүн', prefixText: '\$  ')),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Гүйлгээ илгээгдлээ'),
                        backgroundColor: Colors.blue));
              },
              child: Text('Илгээх',
                  style: GoogleFonts.notoSans(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCard() {
    final numCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expCtrl = TextEditingController();
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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _handle(),
              const SizedBox(height: 20),
              Row(children: [
                _iconBox(Icons.credit_card, Colors.orange),
                const SizedBox(width: 12),
                Text('Карт Холбох',
                    style: GoogleFonts.notoSans(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 16),
              Container(
                width: double.infinity, height: 100,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Шинэ Карт',
                              style: GoogleFonts.notoSans(
                                  color: Colors.white70, fontSize: 12)),
                          Text('**** **** **** ****',
                              style: GoogleFonts.notoSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ]),
                    const Icon(Icons.credit_card, color: Colors.white, size: 36),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(controller: numCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Картын дугаар',
                      prefixIcon: Icon(Icons.credit_card))),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl,
                  decoration: const InputDecoration(
                      hintText: 'Эзэмшигчийн нэр',
                      prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: expCtrl,
                    decoration: const InputDecoration(hintText: 'MM/YY'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: cvvCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'CVV'))),
              ]),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Карт холбогдлоо!'),
                          backgroundColor: Colors.orange));
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final user = provider.currentUser;
        final fmt = NumberFormat('#,##0.00', 'en_US');
        final allTxns = provider.transactions;
        final unpaid = _pendingBills.where((b) => !b.isPaid).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Түрүүвч',
                style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Balance Header ─────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(children: [
                  Text('Нийт Үлдэгдэл',
                      style: GoogleFonts.notoSans(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('\$${fmt.format(user?.walletBalance ?? 0)}',
                      style: GoogleFonts.notoSans(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: _balanceTile('↓ Орлого',
                        '\$${fmt.format(user?.totalIncome ?? 0)}',
                        AppColors.income, Icons.south_west_rounded)),
                    Container(width: 1, height: 44, color: Colors.white24),
                    Expanded(child: _balanceTile('↑ Зарлага',
                        '\$${fmt.format(user?.totalExpense ?? 0)}',
                        Colors.redAccent, Icons.north_east_rounded,
                        right: true)),
                  ]),
                ]),
              ),

              // ── Action Buttons ─────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionBtn(Icons.add_circle_outline_rounded, 'Цэнэглэх',
                        AppColors.primary, _showTopUp),
                    _actionBtn(Icons.send_rounded, 'Гүйлгээ',
                        Colors.blue, _showTransfer),
                    _actionBtn(Icons.payment_rounded, 'Төлбөр',
                        Colors.orange, _showPaymentCategories,
                        badge: unpaid.isNotEmpty ? unpaid.length : null),
                    _actionBtn(Icons.credit_card, 'Карт нэмэх',
                        Colors.purple, _showAddCard),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Cards ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Миний Картууд',
                        style: GoogleFonts.notoSans(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    GestureDetector(
                      onTap: _showAddCard,
                      child: Row(children: [
                        const Icon(Icons.add, color: AppColors.primary, size: 18),
                        Text(' Карт нэмэх',
                            style: GoogleFonts.notoSans(
                                color: AppColors.primary,
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _cards.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == _cards.length) {
                      return GestureDetector(
                        onTap: _showAddCard,
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3), width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.add_rounded,
                                    color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(height: 10),
                              Text('Карт Нэмэх',
                                  style: GoogleFonts.notoSans(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                      );
                    }
                    final card = _cards[i];
                    final isSel = _selectedCard == i;
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
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(
                              color: (card['gradient'][0] as Color).withOpacity(0.4),
                              blurRadius: isSel ? 16 : 8,
                              offset: const Offset(0, 6))],
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
                                        fontSize: 18, letterSpacing: 2)),
                                Icon(card['type'] == 'visa'
                                    ? Icons.credit_card : Icons.credit_score,
                                    color: Colors.white70, size: 28),
                              ],
                            ),
                            const Spacer(),
                            Text(card['number'],
                                style: GoogleFonts.notoSans(
                                    color: Colors.white, fontSize: 14,
                                    letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Эзэмшигч',
                                          style: GoogleFonts.notoSans(
                                              color: Colors.white54, fontSize: 10)),
                                      Text(card['holder'],
                                          style: GoogleFonts.notoSans(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12)),
                                    ]),
                                Column(crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Дуусах',
                                          style: GoogleFonts.notoSans(
                                              color: Colors.white54, fontSize: 10)),
                                      Text(card['expiry'],
                                          style: GoogleFonts.notoSans(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12)),
                                    ]),
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

              // ── Tabs ───────────────────────────────────────────
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.notoSans(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    const Tab(text: 'Гүйлгээнүүд'),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Хүлээгдэж буй'),
                          if (unpaid.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text('${unpaid.length}',
                                  style: GoogleFonts.notoSans(
                                      fontSize: 11, color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab Content ────────────────────────────────────
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  if (_tabController.index == 0) {
                    return _buildAllTransactions(allTxns, fmt);
                  } else {
                    return _buildPendingBills(unpaid);
                  }
                },
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  // ── All Transactions ──────────────────────────────────────────
  Widget _buildAllTransactions(List<TransactionModel> txns, NumberFormat fmt) {
    if (txns.isEmpty) {
      return _empty(Icons.receipt_long_outlined, 'Гүйлгээ байхгүй байна');
    }
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: txns.take(20).map((t) {
          final isIncome = t.type == TransactionType.income;
          final emoji = AppConstants.categoryIcons[t.category] ?? '💰';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: isIncome
                      ? AppColors.income.withOpacity(0.1)
                      : AppColors.expense.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(emoji,
                    style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      style: GoogleFonts.notoSans(
                          fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(DateFormat('MMM d, yyyy').format(t.date),
                      style: GoogleFonts.notoSans(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              )),
              Text('${isIncome ? '+' : '-'}\$${fmt.format(t.amount)}',
                  style: GoogleFonts.notoSans(
                      fontSize: 14, fontWeight: FontWeight.bold,
                      color: isIncome ? AppColors.income : AppColors.expense)),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── Pending Bills ─────────────────────────────────────────────
  Widget _buildPendingBills(List<PendingBill> bills) {
    if (bills.isEmpty) {
      return _empty(Icons.pending_outlined, 'Хүлээгдэж буй төлбөр байхгүй');
    }
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: bills.map((bill) {
          return GestureDetector(
            onTap: () => _openBillDetail(bill),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                boxShadow: [BoxShadow(
                    color: Colors.orange.withOpacity(0.06), blurRadius: 10)],
              ),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: bill.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(bill.icon, color: bill.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bill.title,
                        style: GoogleFonts.notoSans(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('\$${NumberFormat('#,##0.00').format(bill.total)} нийт',
                        style: GoogleFonts.notoSans(
                            fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Хүлээгдэж байна',
                          style: GoogleFonts.notoSans(
                              fontSize: 11, color: Colors.orange,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                )),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.textSecondary),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  // BillDetail руу шилжинэ
  void _openBillDetail(PendingBill bill) async {
    final paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BillDetailScreen(
          bill: bill,
          cards: _cards,
        ),
      ),
    );
    if (paid == true) {
      setState(() {
        final idx = _pendingBills.indexWhere((b) => b.id == bill.id);
        if (idx != -1) _pendingBills[idx].isPaid = true;
      });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────
  Widget _handle() => Center(
    child: Container(
      width: 40, height: 4,
      decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2)),
    ),
  );

  Widget _iconBox(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12)),
    child: Icon(icon, color: color, size: 22),
  );

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap,
      {int? badge}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Stack(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: color, size: 26),
          ),
          if (badge != null)
            Positioned(
              right: 0, top: 0,
              child: Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: Center(child: Text('$badge',
                    style: GoogleFonts.notoSans(
                        fontSize: 11, color: Colors.white,
                        fontWeight: FontWeight.bold))),
              ),
            ),
        ]),
        const SizedBox(height: 8),
        Text(label,
            style: GoogleFonts.notoSans(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ]),
    );
  }

  Widget _balanceTile(String label, String value, Color color, IconData icon,
      {bool right = false}) {
    return Padding(
      padding: EdgeInsets.only(left: right ? 16 : 4, right: right ? 4 : 16),
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
                  color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _empty(IconData icon, String text) {
    return Container(
      height: 200, color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(text,
                style: GoogleFonts.notoSans(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}