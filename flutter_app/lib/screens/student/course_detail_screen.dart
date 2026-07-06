import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class CourseDetailScreen extends StatelessWidget {
  final int index;
  const CourseDetailScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSession>().student!;
    if (s.workshopHistory.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('Course Detail')),
        body: const EmptyState(title: 'No course data', subtitle: 'This course record is unavailable.'),
      );
    }
    final w = s.workshopHistory[index.clamp(0, s.workshopHistory.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Course Detail')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Hero banner ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(4)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(w.workshopName, style: const TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
                const SizedBox(height: 8),
                LevelBadge(s.level),
              ])),
              const Icon(Icons.self_improvement, size: 52, color: AppColors.primary),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Details card ───────────────────────────────────
          WhiteCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(children: [
              DetailRow(label: 'Completion Date', value: w.completionDate),
              const Divider(),
              DetailRow(label: 'Trainer', value: w.trainerName),
              const Divider(),
              DetailRow(label: 'Associated Level', value: s.level),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Certificate card ───────────────────────────────
          WhiteCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('CERTIFICATE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      letterSpacing: 1.5, color: AppColors.muted)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(4)),
                child: Center(
                  child: Text(w.certificateNumber,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                          letterSpacing: 3, color: AppColors.primary,
                          fontFamily: 'monospace')),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: w.certificateNumber));
                    showYPVToast(context, 'Certificate number copied');
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                )),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => showYPVToast(context, 'Download coming soon'),
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.muted,
                      side: const BorderSide(color: AppColors.line)),
                )),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
