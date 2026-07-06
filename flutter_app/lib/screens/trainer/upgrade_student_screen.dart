import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exception.dart';
import '../../models/models.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class UpgradeStudentScreen extends StatefulWidget {
  const UpgradeStudentScreen({super.key});
  @override State<UpgradeStudentScreen> createState() => _State();
}

class _State extends State<UpgradeStudentScreen> {
  final _certCtrl    = TextEditingController();
  final _newCertCtrl = TextEditingController();
  StudentModel? _found;
  bool _notFound = false;
  String _newWorkshop = '';
  DateTime? _newDate;
  bool _loading = false;
  bool _saving  = false;

  void _search() async {
    setState(() { _loading = true; _found = null; _notFound = false; });
    try {
      final s = await context.read<AppSession>().findStudentByCert(_certCtrl.text.trim());
      if (!mounted) return;
      setState(() { _loading = false; _found = s; _notFound = s == null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _notFound = true; });
      showYPVToast(context, e is ApiException ? e.message : 'Search failed');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime(2010), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!),
    );
    if (picked != null) setState(() => _newDate = picked);
  }

  bool get _upgradeValid => _found != null && _newWorkshop.isNotEmpty &&
      _newDate != null && _newCertCtrl.text.isNotEmpty;

  void _upgrade() async {
    setState(() => _saving = true);
    try {
      await context.read<AppSession>().upgradeStudent(
            studentId: _found!.id,
            workshopName: _newWorkshop,
            completionDate:
                '${_newDate!.day} ${_monthName(_newDate!.month)} ${_newDate!.year}',
            certificateNumber: _newCertCtrl.text,
          );
      if (!mounted) return;
      setState(() => _saving = false);
      showYPVToast(context, 'Student upgraded successfully ✓');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showYPVToast(context, e is ApiException ? e.message : 'Upgrade failed');
    }
  }

  @override
  void dispose() { _certCtrl.dispose(); _newCertCtrl.dispose(); super.dispose(); }

  String _monthName(int m) => const ['','Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'][m];

  @override
  Widget build(BuildContext context) {
    final trainer = context.watch<AppSession>().trainer;
    if (trainer?.level == 'Level 1') {
      return Scaffold(
        appBar: AppBar(title: const Text('Upgrade Student')),
        body: const EmptyState(
          title: 'Not available for Level 1 trainers',
          subtitle: 'Student level upgrades can only be performed by an Admin or a higher-level trainer.',
        ),
      );
    }
    return Scaffold(
    appBar: AppBar(title: const Text('Upgrade Student')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Step 1: Search ─────────────────────────────────
        WhiteCard(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('STEP 1 — FIND STUDENT',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    letterSpacing: 1.5, color: AppColors.primary)),
            const SizedBox(height: 14),
            TextField(
              controller: _certCtrl,
              onChanged: (_) => setState(() { _found = null; _notFound = false; }),
              decoration: const InputDecoration(
                labelText: 'Student Certificate Number',
                hintText: 'YPV-2024-001',
                suffixIcon: Icon(Icons.search, size: 18),
              ),
            ),
            if (_notFound) ...[
              const SizedBox(height: 8),
              const Text('No student found for this certificate number.',
                  style: TextStyle(fontSize: 12, color: AppColors.error, letterSpacing: 0.5)),
            ],
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, height: 44,
              child: ElevatedButton(
                onPressed: _certCtrl.text.isNotEmpty ? _search : null,
                child: _loading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Search'),
              ),
            ),
          ]),
        ),

        // ── Found student card ─────────────────────────────
        if (_found != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(4)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                YPVAvatar(name: _found!.name, size: 44),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_found!.name, style: const TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text(_found!.email, style: const TextStyle(fontSize: 12,
                      letterSpacing: 0.5, color: AppColors.muted)),
                ])),
                LevelBadge(_found!.level),
              ]),
              const SizedBox(height: 14),
              const Text('WORKSHOP HISTORY',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      letterSpacing: 1.5, color: AppColors.muted)),
              const SizedBox(height: 8),
              ..._found!.workshopHistory.map((w) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(child: Text('${w.workshopName} · ${w.completionDate}',
                      style: const TextStyle(fontSize: 12, letterSpacing: 0.5, color: AppColors.ink))),
                  Text(w.certificateNumber,
                      style: const TextStyle(fontSize: 12, letterSpacing: 0.5,
                          color: AppColors.primary, fontWeight: FontWeight.w600)),
                ]),
              )),
            ]),
          ),

          // ── Step 2: New record ─────────────────────────
          const SizedBox(height: 14),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('STEP 2 — ADD NEW RECORD',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      letterSpacing: 1.5, color: AppColors.primary)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _newWorkshop.isEmpty ? null : _newWorkshop,
                decoration: const InputDecoration(labelText: 'New Workshop *'),
                hint: const Text('Select workshop'),
                items: context.watch<AppSession>().workshopOptions.map((w) =>
                    DropdownMenuItem(value: w, child: Text(w))).toList(),
                onChanged: (v) => setState(() => _newWorkshop = v ?? ''),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: _newDate != null
                        ? '${_newDate!.day} ${_monthName(_newDate!.month)} ${_newDate!.year}' : ''),
                    decoration: const InputDecoration(
                      labelText: 'New Completion Date *',
                      hintText: 'Tap to select',
                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _newCertCtrl,
                onChanged: (_) => setState((){}),
                decoration: const InputDecoration(
                  labelText: 'New Certificate Number *',
                  hintText: 'YPV-2024-200',
                  helperText: 'Must be unique system-wide',
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Upgrade Student', loading: _saving,
                  onPressed: _upgradeValid ? _upgrade : null),
            ]),
          ),
        ],
        const SizedBox(height: 24),
      ],
    ),
  );
  }
}
