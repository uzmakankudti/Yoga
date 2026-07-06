import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      // In production: check SharedPreferences for onboarding flag
      context.go('/onboarding');
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.primary,
    body: FadeTransition(
      opacity: _fade,
      child: Stack(children: [
        Positioned(
          bottom: -40, right: -60,
          child: Opacity(
            opacity: 0.18,
            child: Image.asset('assets/images/splash_bg_pose.png', height: 420),
          ),
        ),
        Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('YPV', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: 2)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Yoga Prana Vidya', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
              letterSpacing: 2, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Your yoga journey, recorded',
              style: TextStyle(fontSize: 13, letterSpacing: 1.5,
                  color: Colors.white.withOpacity(0.65))),
          const SizedBox(height: 60),
          SizedBox(width: 24, height: 24,
            child: CircularProgressIndicator(
              color: Colors.white.withOpacity(0.5), strokeWidth: 2)),
        ]),
        ),
      ]),
    ),
  );
}
