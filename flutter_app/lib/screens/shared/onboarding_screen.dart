import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class _Slide {
  final String title;
  final String subtitle;
  final String image;
  const _Slide({required this.title, required this.subtitle, required this.image});
}

const _slides = [
  _Slide(
    title: 'Track your yoga journey',
    subtitle: 'Record every workshop and course in one secure place.',
    image: 'assets/images/pose_meditation.png',
  ),
  _Slide(
    title: 'Courses & certificates in one place',
    subtitle: 'All your certificate numbers, always accessible.',
    image: 'assets/images/pose_headstand.png',
  ),
  _Slide(
    title: 'Secure login — no password needed',
    subtitle: 'Sign in quickly and safely with a one-time OTP code.',
    image: 'assets/images/pose_prayer_standing.png',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.white,
    body: SafeArea(
      child: Column(children: [
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Skip', style: TextStyle(color: AppColors.muted,
                fontSize: 13, letterSpacing: 0.5)),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _slides.length,
            itemBuilder: (_, i) {
              final s = _slides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    height: 260,
                    child: Image.asset(s.image, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 36),
                  Text(s.title, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
                          letterSpacing: 0.5, color: AppColors.ink, height: 1.3)),
                  const SizedBox(height: 12),
                  Text(s.subtitle, textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, letterSpacing: 0.5,
                          color: AppColors.muted, height: 1.6)),
                ]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(children: [
            // Dots
            Row(mainAxisAlignment: MainAxisAlignment.center, children:
              List.generate(3, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _page ? 20 : 6, height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_page < 2 ? 'Next →' : 'Get Started'),
              ),
            ),
          ]),
        ),
      ]),
    ),
  );
}
