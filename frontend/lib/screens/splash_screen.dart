import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/app_flow_handle_screens/auth_state_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthStateScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.splashGradient,
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 3),
            const BrandLogo(size: 68),
            const SizedBox(height: 26),
            const Text(
              'A S D   C A R E',
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Early Awareness. Informed Support.',
              style: TextStyle(color: AppColors.heading, fontSize: 14),
            ),
            const Spacer(flex: 4),
            _Dots(),
            const SizedBox(height: 16),
            const Text(
              'CLINICAL INTELLIGENCE',
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 11,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // prevents callback firing after widget is gone
    super.dispose();
  }
}

class _Dots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.heading,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
