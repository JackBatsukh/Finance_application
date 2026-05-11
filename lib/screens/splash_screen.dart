// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../services/app_provider.dart';
import 'onboarding_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // 3 минут = 180 секунд
  static const int _sessionMinutes = 3;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim =
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);
    _fadeAnim =
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _logoController.forward().then((_) => _textController.forward());

    // Анимейшн дууссаны дараа шалгана
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final provider = context.read<AppProvider>();
    final prefs = await SharedPreferences.getInstance();

    // Сүүлийн нэвтрэлтийн цагийг авна
    final lastLoginMs = prefs.getInt('last_login_time');
    final now = DateTime.now().millisecondsSinceEpoch;
    final sessionMs = _sessionMinutes * 60 * 1000;

    final isWithinSession =
        lastLoginMs != null && (now - lastLoginMs) < sessionMs;

    // Firebase auth state шалгана
    final isFirebaseLoggedIn = provider.isFirebaseLoggedIn;

    if (isFirebaseLoggedIn && isWithinSession) {
      // ✅ Нэвтэрсэн + 3 минут дотор → шууд Home руу
      await provider.reloadUser();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } else {
      // ❌ Нэвтрээгүй эсвэл session дууссан → Onboarding руу
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _textController,
                  child: Column(
                    children: [
                      Text(
                        'Тавтай морилно уу!',
                        style: GoogleFonts.notoSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Орлого, зарлагаа хянах тань туслана',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
              FadeTransition(
                opacity: _textController,
                child: const CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white54),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}