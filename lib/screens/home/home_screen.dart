// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../services/app_provider.dart';
import '../../models/transaction_model.dart';
import '../transactions/transaction_list_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _balanceVisible = true;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const TransactionListScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Нүүр'),
                _buildNavItem(1, Icons.receipt_long_rounded, 'Гүйлгээ'),
                _buildNavItem(2, Icons.account_balance_wallet_rounded, 'Түрүүвч'),
                _buildNavItem(3, Icons.person_rounded, 'Профайл'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen()),
              ),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final user = provider.currentUser;
        final transactions = provider.transactions;
        final recentTxns = transactions.take(5).toList();
        final fmt = NumberFormat('#,##0.00', 'en_US');

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Өглөөний мэнд?',
                              style: GoogleFonts.notoSans(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            Text(
                              user?.name ?? 'Хэрэглэгч',
                              style: GoogleFonts.notoSans(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _currentIndex = 3),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Balance card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Нийт үлдэгдэл ⌃',
                                style: GoogleFonts.notoSans(
                                    color: Colors.white70, fontSize: 13),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _balanceVisible =
                                            !_balanceVisible),
                                    child: Icon(
                                      _balanceVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.more_horiz,
                                      color: Colors.white70, size: 20),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _balanceVisible
                                ? '\$${fmt.format(user?.walletBalance ?? 0)}'
                                : '••••••',
                            style: GoogleFonts.notoSans(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildBalanceStat(
                                  '↓ Орлого',
                                  '\$${fmt.format(user?.totalIncome ?? 0)}',
                                  AppColors.income,
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white30),
                              Expanded(
                                child: _buildBalanceStat(
                                  '↑ Зарлага',
                                  '\$${fmt.format(user?.totalExpense ?? 0)}',
                                  AppColors.expense,
                                  rightAligned: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Transactions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Гүйлгээний Түүх',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 1),
                      child: Text(
                        'Бүгдийг харах',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (recentTxns.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 60, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          'Гүйлгээ байхгүй байна',
                          style: GoogleFonts.notoSans(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TransactionTile(transaction: recentTxns[i]),
                  ),
                  childCount: recentTxns.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildBalanceStat(String label, String value, Color color,
      {bool rightAligned = false}) {
    return Padding(
      padding: EdgeInsets.only(
          left: rightAligned ? 16 : 0, right: rightAligned ? 0 : 16),
      child: Column(
        crossAxisAlignment: rightAligned
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.notoSans(
                  color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
