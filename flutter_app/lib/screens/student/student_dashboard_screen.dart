import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final s = session.student!;
    final courses = s.workshopHistory;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => session.loadStudentSession(),
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // ── Greeting ───────────────────────────────────
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(timeOfDayGreeting(), style: const TextStyle(fontSize: 12,
                      letterSpacing: 0.5, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Text('Namaste, ${s.name.split(' ').first} 🙏',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
                          letterSpacing: 0.5, color: AppColors.ink)),
                ])),
                GestureDetector(
                  onTap: () => context.go('/student/settings'),
                  child: YPVAvatar(name: s.name, size: 44),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Level hero card ────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Your Current Level', style: TextStyle(fontSize: 12,
                      letterSpacing: 0.5, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(s.level, style: const TextStyle(fontSize: 28,
                      fontWeight: FontWeight.w500, letterSpacing: 0.5, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Trainer: ${s.trainerName}', style: const TextStyle(
                      fontSize: 12, letterSpacing: 0.5, color: Colors.white70)),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Summary stats ──────────────────────────────
              WhiteCard(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(children: [
                  _Stat(value: '${courses.length}', label: 'Completed\nCourses'),
                  _Divider(),
                  _Stat(value: '${courses.length}', label: 'Certificate\nNumbers'),
                  _Divider(),
                  _Stat(value: s.level, label: 'Current\nLevel', accent: true),
                ]),
              ),
              const SizedBox(height: 20),

              // ── Completed courses ──────────────────────────
              const SectionHeader(title: 'Completed Courses'),
              const SizedBox(height: 12),

              if (courses.isEmpty)
                const WhiteCard(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No courses yet. Your trainer will add your completed workshops.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, letterSpacing: 0.5,
                          color: AppColors.muted, height: 1.6))),
                )
              else
                ...courses.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: WhiteCard(
                    onTap: () => context.push('/student/course-detail/${e.key}'),
                    child: Row(children: [
                      Container(width: 42, height: 42, decoration: BoxDecoration(
                          color: AppColors.primaryTint, borderRadius: BorderRadius.circular(4)),
                        child: const Icon(Icons.self_improvement, color: AppColors.primary, size: 24)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.value.workshopName, style: const TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
                        const SizedBox(height: 4),
                        Text('${e.value.completionDate} · ',
                            style: const TextStyle(fontSize: 12, letterSpacing: 0.5, color: AppColors.muted)),
                        Text(e.value.certificateNumber,
                            style: const TextStyle(fontSize: 12, letterSpacing: 0.5,
                                color: AppColors.primary, fontWeight: FontWeight.w500)),
                      ])),
                      const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
                    ]),
                  ),
                )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  final bool accent;
  const _Stat({required this.value, required this.label, this.accent = false});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: accent ? 16 : 20,
        fontWeight: FontWeight.w600, letterSpacing: 0.5,
        color: accent ? AppColors.primary : AppColors.ink)),
    const SizedBox(height: 4),
    Text(label, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, letterSpacing: 0.5,
            color: AppColors.muted, height: 1.3)),
  ]));
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: AppColors.line);
}
