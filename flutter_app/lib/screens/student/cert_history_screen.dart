import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class CertHistoryScreen extends StatelessWidget {
  const CertHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSession>().student!;
    final certs = s.workshopHistory;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('My Certificates')),
      body: certs.isEmpty
          ? const EmptyState(title: 'No certificates yet',
              subtitle: 'Your trainer will add certificates after completed workshops')
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: certs.length,
              itemBuilder: (_, i) {
                final w = certs[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WhiteCard(
                    onTap: () => context.push('/student/course-detail/$i'),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(w.workshopName,
                            style: const TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w500, letterSpacing: 0.5,
                                color: AppColors.ink))),
                        Text(w.certificateNumber,
                            style: const TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w700, letterSpacing: 1,
                                color: AppColors.primary)),
                      ]),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 13, color: AppColors.muted),
                        const SizedBox(width: 6),
                        Text(w.completionDate, style: const TextStyle(fontSize: 12,
                            letterSpacing: 0.5, color: AppColors.muted)),
                        const Spacer(),
                        const Icon(Icons.person_outline,
                            size: 13, color: AppColors.muted),
                        const SizedBox(width: 6),
                        Text(w.trainerName, style: const TextStyle(fontSize: 12,
                            letterSpacing: 0.5, color: AppColors.muted)),
                      ]),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
