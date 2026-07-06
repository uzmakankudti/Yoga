import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exception.dart';
import '../../models/models.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final s = session.students.firstWhere(
      (x) => x.id == studentId,
      orElse: () => session.students.first,
    );
    final isL2Plus = session.trainer!.level != 'Level 1';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          if (isL2Plus)
            TextButton.icon(
              onPressed: () => context.push('/trainer/upgrade-student'),
              icon: const Icon(Icons.upgrade, size: 18),
              label: const Text('Upgrade'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Header card ────────────────────────────────────
          WhiteCard(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              YPVAvatar(name: s.name, size: 56),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: const TextStyle(fontSize: 17,
                    fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text(s.email, style: const TextStyle(fontSize: 12,
                    letterSpacing: 0.5, color: AppColors.muted)),
                Text(s.phone, style: const TextStyle(fontSize: 12,
                    letterSpacing: 0.5, color: AppColors.muted)),
                const SizedBox(height: 8),
                LevelBadge(s.level),
              ])),
            ]),
          ),

          // ── Pending workshop ───────────────────────────────
          if (s.pendingWorkshop != null) ...[
            const SizedBox(height: 16),
            InfoBanner(
              bg: AppColors.tealTint,
              textColor: AppColors.teal,
              message: 'Pending: ${s.pendingWorkshop} — not yet completed.',
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Mark as Completed',
              color: AppColors.teal,
              onPressed: () => _showMarkCompleteSheet(context, s),
            ),
          ],
          const SizedBox(height: 16),

          // ── Workshop history ───────────────────────────────
          const Text('WORKSHOP HISTORY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  letterSpacing: 1.5, color: AppColors.muted)),
          const SizedBox(height: 10),
          if (s.workshopHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No completed workshops yet.',
                  style: TextStyle(fontSize: 13, letterSpacing: 0.5, color: AppColors.muted)),
            ),
          ...s.workshopHistory.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: WhiteCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(w.workshopName, style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppColors.muted),
                  const SizedBox(width: 8),
                  Text(w.completionDate, style: const TextStyle(fontSize: 12,
                      letterSpacing: 0.5, color: AppColors.muted)),
                  const Spacer(),
                  const Icon(Icons.workspace_premium_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(w.certificateNumber, style: const TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w600, letterSpacing: 0.5,
                      color: AppColors.primary)),
                ]),
              ]),
            ),
          )),

          if (isL2Plus) ...[
            const SizedBox(height: 8),
            SecondaryButton(
              label: 'Upgrade this Student',
              onPressed: () => context.push('/trainer/upgrade-student'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showMarkCompleteSheet(BuildContext context, StudentModel student) {
    final certCtrl = TextEditingController();
    DateTime? date;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          String monthName(int m) => const ['','Jan','Feb','Mar','Apr','May','Jun',
              'Jul','Aug','Sep','Oct','Nov','Dec'][m];

          Future<void> pickDate() async {
            final picked = await showDatePicker(
              context: sheetContext, initialDate: DateTime.now(),
              firstDate: DateTime(2010), lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(primary: AppColors.primary)),
                  child: child!),
            );
            if (picked != null) setSheetState(() => date = picked);
          }

          final valid = date != null && certCtrl.text.isNotEmpty;

          Future<void> submit() async {
            setSheetState(() => saving = true);
            try {
              await context.read<AppSession>().completeWorkshop(
                    studentId: student.id,
                    completionDate: '${date!.day} ${monthName(date!.month)} ${date!.year}',
                    certificateNumber: certCtrl.text,
                  );
              if (!sheetContext.mounted) return;
              Navigator.pop(sheetContext);
              showYPVToast(context, 'Workshop marked as completed ✓');
            } catch (e) {
              setSheetState(() => saving = false);
              showYPVToast(sheetContext, e is ApiException ? e.message : 'Failed to mark completed');
            }
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.line,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Mark "${student.pendingWorkshop}" as Completed',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      letterSpacing: 0.5, color: AppColors.ink)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: pickDate,
                child: AbsorbPointer(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: date != null ? '${date!.day} ${monthName(date!.month)} ${date!.year}' : ''),
                    decoration: const InputDecoration(
                      labelText: 'Completion Date *',
                      hintText: 'Tap to select',
                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: certCtrl,
                onChanged: (_) => setSheetState((){}),
                decoration: const InputDecoration(
                  labelText: 'Certificate Number *',
                  hintText: 'YPV-2024-001',
                  helperText: 'Must be unique system-wide',
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Confirm Completion', loading: saving,
                  onPressed: valid ? submit : null),
            ]),
          );
        },
      ),
    );
  }
}
