import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class StudentSettingsScreen extends StatelessWidget {
  const StudentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSession>().student!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Avatar header ──────────────────────────────────
          WhiteCard(
            child: Column(children: [
              YPVAvatar(name: s.name, size: 72),
              const SizedBox(height: 12),
              Text(s.name, style: const TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
              const SizedBox(height: 6),
              LevelBadge(s.level),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Profile details ────────────────────────────────
          WhiteCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(children: [
              DetailRow(label: 'Email', value: s.email),
              const Divider(),
              DetailRow(label: 'Phone', value: s.phone),
              const Divider(),
              DetailRow(label: 'Current Level', value: s.level,
                  valueColor: AppColors.primary),
              const Divider(),
              DetailRow(label: 'Trainer', value: s.trainerName),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Settings ───────────────────────────────────────
          WhiteCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              ListTile(
                title: const Text('Help / Support',
                    style: TextStyle(fontSize: 14, letterSpacing: 0.5, color: AppColors.ink)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
                onTap: () {},
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              const Divider(),
              ListTile(
                title: const Text('App Version',
                    style: TextStyle(fontSize: 14, letterSpacing: 0.5, color: AppColors.ink)),
                trailing: const Text('v1.0.0',
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              const Divider(),
              ListTile(
                onTap: () => _confirmLogout(context),
                title: const Text('Logout', style: TextStyle(fontSize: 14,
                    letterSpacing: 0.5, color: AppColors.error,
                    fontWeight: FontWeight.w500)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ]),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.line,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Logout?', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w600, color: AppColors.ink)),
          const SizedBox(height: 8),
          const Text("You'll need to log in again with OTP.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted, letterSpacing: 0.5)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: SecondaryButton(label: 'Cancel',
                onPressed: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () async {
                  Navigator.pop(context);
                  await context.read<AppSession>().logout();
                  context.go('/login');
                },
                child: const Text('Logout'),
              ),
            )),
          ]),
        ]),
      ),
    );
  }
}
