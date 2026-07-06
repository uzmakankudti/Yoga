import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final t = session.trainer!;
    final recent = session.students.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => session.loadTrainerSession(),
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // ── Greeting row ───────────────────────────────
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(timeOfDayGreeting(), style: const TextStyle(fontSize: 12,
                      letterSpacing: 0.5, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Text('Namaste, ${t.name.split(' ').first} 🙏',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
                          letterSpacing: 0.5, color: AppColors.ink)),
                ])),
                GestureDetector(
                  onTap: () => context.go('/trainer/settings'),
                  child: Column(children: [
                    YPVAvatar(name: t.name, size: 44),
                    const SizedBox(height: 4),
                    LevelBadge(t.level),
                  ]),
                ),
              ]),
              const SizedBox(height: 20),

              // ── KPI tiles ──────────────────────────────────
              Row(children: [
                Expanded(child: StatTile(label: 'Total Students',
                    value: '${t.studentCount}', bg: AppColors.primaryTint2, valueColor: AppColors.primary)),
                const SizedBox(width: 10),
                Expanded(child: StatTile(label: 'Workshops', value: '28',
                    bg: AppColors.tealTile, valueColor: AppColors.teal)),
                const SizedBox(width: 10),
                Expanded(child: StatTile(label: 'This Month', value: '3',
                    bg: AppColors.blueTile, valueColor: AppColors.blue)),
              ]),
              const SizedBox(height: 20),

              // ── Quick actions ──────────────────────────────
              Row(children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/trainer/add-student'),
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: const Text('Add Student'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: t.level == 'Level 1'
                          ? null
                          : () => context.push('/trainer/upgrade-student'),
                      child: const Text('Upgrade'),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // ── Recent students ────────────────────────────
              SectionHeader(title: 'Recent Students', action: 'View all',
                  onAction: () => context.go('/trainer/students')),
              const SizedBox(height: 12),
              ...recent.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WhiteCard(
                  onTap: () => context.push('/trainer/student-detail/${s.id}'),
                  child: Row(children: [
                    YPVAvatar(name: s.name, size: 40),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.name, style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
                      const SizedBox(height: 4),
                      Text(s.workshopHistory.isNotEmpty
                          ? '${s.workshopHistory.first.workshopName} · ${s.workshopHistory.first.completionDate}'
                          : s.pendingWorkshop != null
                              ? 'Pending: ${s.pendingWorkshop}'
                              : 'No workshops yet',
                          style: const TextStyle(fontSize: 12, letterSpacing: 0.5, color: AppColors.muted)),
                    ])),
                    const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
                  ]),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
