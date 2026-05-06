// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../services/app_provider.dart';
import '../onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final user = provider.currentUser;
        final fmt = NumberFormat('#,##0.00', 'en_US');

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Профайл',
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
                // Avatar & name
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            (user?.name.isNotEmpty == true)
                                ? user!.name[0].toUpperCase()
                                : 'U',
                            style: GoogleFonts.notoSans(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? '',
                        style: GoogleFonts.notoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: GoogleFonts.notoSans(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statBox('Нийт Орлого',
                              '\$${fmt.format(user?.totalIncome ?? 0)}',
                              AppColors.income),
                          Container(
                              width: 1, height: 40, color: AppColors.border),
                          _statBox('Нийт Зарлага',
                              '\$${fmt.format(user?.totalExpense ?? 0)}',
                              AppColors.expense),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Settings items
                _menuSection([
                  _menuTile(Icons.person_outline, 'Профайл засах', () {}),
                  _menuTile(
                      Icons.notifications_outlined, 'Мэдэгдэл тохиргоо', () {}),
                  _menuTile(Icons.shield_outlined, 'Нууцлал & Аюулгүй байдал',
                      () {}),
                ]),

                const SizedBox(height: 12),

                _menuSection([
                  _menuTile(Icons.help_outline, 'Тусламж & Дэмжлэг', () {}),
                  _menuTile(Icons.info_outline, 'Аппийн тухай', () {}),
                ]),

                const SizedBox(height: 12),

                // Sign out
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded,
                        color: AppColors.expense),
                    title: Text(
                      'Гарах',
                      style: GoogleFonts.notoSans(
                        color: AppColors.expense,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await provider.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OnboardingScreen()),
                          (r) => false,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.notoSans(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.notoSans(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  Widget _menuSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title,
          style: GoogleFonts.notoSans(
              fontSize: 14, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
