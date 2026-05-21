
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { super.initState(); _go(); }
  Future<void> _go() async {
    await Future.delayed(const Duration(seconds: 2));
    final ok = await ApiService.hasValidSession();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, ok ? '/dashboard' : '/login');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: SafeArea(
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 78, height: 78, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.school_outlined, color: AppColors.blue, size: 42)),
            const SizedBox(height: 34),
            const Text('Learnova', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 34)),
            const SizedBox(height: 18),
            const Text('Learn smart. Organize better.', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 170),
            const Text('•••', style: TextStyle(color: Colors.white, fontSize: 26, letterSpacing: 6)),
          ]),
        ),
      ),
    );
  }
}
