import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exception.dart';
import '../../models/models.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

final RegExp _kPhoneRegex = RegExp(r'^[6-9]\d{9}$');
final RegExp _kPhoneStartRegex = RegExp(r'^[6-9]');

List<TextInputFormatter> _phoneFormatters() => [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(10),
    ];

bool _isValidPhone(String text, {bool required = false}) {
  if (text.isEmpty) return !required;
  return _kPhoneRegex.hasMatch(text);
}

String? _phoneErrorText(String text) {
  if (text.isEmpty) return null;
  if (!_kPhoneStartRegex.hasMatch(text)) return 'Mobile number must start with 6, 7, 8, or 9.';
  if (text.length != 10) return 'Mobile number must be exactly 10 digits.';
  return null;
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override State<AdminDashboardScreen> createState() => _State();
}

class _State extends State<AdminDashboardScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    final session = context.read<AppSession>();
    if (session.adminTrainers.isEmpty && session.adminStudents.isEmpty && session.adminAdmins.isEmpty) {
      session.adminLoading = true;
      Future.microtask(session.loadAdminData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final isEmpty = session.adminTrainers.isEmpty && session.adminStudents.isEmpty && session.adminAdmins.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await session.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateSheet(context, _tab),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SessionGate(
        loading: session.adminLoading && isEmpty,
        error: isEmpty ? session.adminError : null,
        onRetry: () => session.loadAdminData(),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: SegmentTabs(
              tabs: const ['Trainers', 'Students', 'Admins'],
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: switch (_tab) {
              0 => _TrainerList(trainers: session.adminTrainers),
              1 => _StudentList(students: session.adminStudents, trainers: session.adminTrainers),
              _ => _AdminList(admins: session.adminAdmins),
            },
          ),
        ]),
      ),
    );
  }
}

// ── Trainers ───────────────────────────────────────────────────

class _TrainerList extends StatelessWidget {
  final List<TrainerModel> trainers;
  const _TrainerList({required this.trainers});

  @override
  Widget build(BuildContext context) {
    if (trainers.isEmpty) {
      return const EmptyState(title: 'No trainers yet', subtitle: 'Tap + to add one.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
      itemCount: trainers.length,
      itemBuilder: (_, i) {
        final t = trainers[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: WhiteCard(
            onTap: () => _showTrainerEditSheet(context, t),
            child: Row(children: [
              YPVAvatar(name: t.name, size: 40),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.name, style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text('${t.studentCount} students · ${t.phone}',
                    style: const TextStyle(fontSize: 12, letterSpacing: 0.5, color: AppColors.muted)),
              ])),
              LevelBadge(t.level),
              const SizedBox(width: 6),
              const Icon(Icons.edit_outlined, color: AppColors.muted, size: 18),
            ]),
          ),
        );
      },
    );
  }
}

// ── Students ───────────────────────────────────────────────────

class _StudentList extends StatelessWidget {
  final List<StudentModel> students;
  final List<TrainerModel> trainers;
  const _StudentList({required this.students, required this.trainers});

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const EmptyState(title: 'No students yet', subtitle: 'Tap + to add one.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
      itemCount: students.length,
      itemBuilder: (_, i) {
        final s = students[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: WhiteCard(
            onTap: () => _showStudentEditSheet(context, s, trainers),
            child: Row(children: [
              YPVAvatar(name: s.name, size: 40),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text('Trainer: ${s.trainerName}',
                    style: const TextStyle(fontSize: 12, letterSpacing: 0.5, color: AppColors.muted)),
              ])),
              LevelBadge(s.level),
              const SizedBox(width: 6),
              const Icon(Icons.edit_outlined, color: AppColors.muted, size: 18),
            ]),
          ),
        );
      },
    );
  }
}

// ── Admins ─────────────────────────────────────────────────────

class _AdminList extends StatelessWidget {
  final List<AdminModel> admins;
  const _AdminList({required this.admins});

  @override
  Widget build(BuildContext context) {
    if (admins.isEmpty) {
      return const EmptyState(title: 'No admins yet', subtitle: 'Tap + to add one.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
      itemCount: admins.length,
      itemBuilder: (_, i) {
        final a = admins[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: WhiteCard(
            onTap: () => _showAdminEditSheet(context, a),
            child: Row(children: [
              YPVAvatar(name: a.name, size: 40),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.name, style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text(a.email, style: const TextStyle(fontSize: 12, letterSpacing: 0.5, color: AppColors.muted)),
              ])),
              const Icon(Icons.edit_outlined, color: AppColors.muted, size: 18),
            ]),
          ),
        );
      },
    );
  }
}

// ── Create dispatcher ──────────────────────────────────────────

void _showCreateSheet(BuildContext context, int tab) {
  switch (tab) {
    case 0:
      _showTrainerCreateSheet(context);
    case 1:
      _showStudentCreateSheet(context, context.read<AppSession>().adminTrainers);
    default:
      _showAdminCreateSheet(context);
  }
}

// ── Bottom sheet scaffold helper ───────────────────────────────

Widget _sheetTitle(String text) => Text(text, style: const TextStyle(fontSize: 16,
    fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.ink));

Widget _sheetHandle() => Center(child: Container(width: 40, height: 4,
    decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2))));

void _showSheet(BuildContext context, Widget Function(BuildContext, StateSetter) builder) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [_sheetHandle(), const SizedBox(height: 16), builder(sheetContext, setSheetState)]),
        ),
      ),
    ),
  );
}

// ── Trainer create / edit ──────────────────────────────────────

void _showTrainerCreateSheet(BuildContext context) {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  String level = '';
  bool saving = false;

  _showSheet(context, (sheetContext, setSheetState) {
    final levelOptions = context.watch<AppSession>().levelOptions;
    final valid = nameCtrl.text.isNotEmpty && _isValidPhone(phoneCtrl.text, required: true) &&
        emailCtrl.text.isNotEmpty && level.isNotEmpty;

    Future<void> submit() async {
      setSheetState(() => saving = true);
      try {
        await context.read<AppSession>().createTrainer(
              name: nameCtrl.text, phone: phoneCtrl.text, email: emailCtrl.text, level: level,
            );
        if (!sheetContext.mounted) return;
        Navigator.pop(sheetContext);
        showYPVToast(context, 'Trainer added ✓');
      } catch (e) {
        setSheetState(() => saving = false);
        showYPVToast(sheetContext, e is ApiException ? e.message : 'Failed to add trainer');
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sheetTitle('Add Trainer'),
      const SizedBox(height: 16),
      TextField(controller: nameCtrl, onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Full Name *')),
      const SizedBox(height: 14),
      TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
          inputFormatters: _phoneFormatters(),
          onChanged: (_) => setSheetState((){}),
          decoration: InputDecoration(labelText: 'Phone Number *',
              errorText: _phoneErrorText(phoneCtrl.text))),
      const SizedBox(height: 14),
      TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Email *')),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        value: level.isEmpty ? null : level,
        decoration: const InputDecoration(labelText: 'Level *'),
        hint: const Text('Select level'),
        items: levelOptions.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
        onChanged: (v) => setSheetState(() => level = v ?? ''),
      ),
      const SizedBox(height: 20),
      PrimaryButton(label: 'Add Trainer', loading: saving, onPressed: valid ? submit : null),
    ]);
  });
}

void _showTrainerEditSheet(BuildContext context, TrainerModel trainer) {
  final nameCtrl = TextEditingController(text: trainer.name);
  final phoneCtrl = TextEditingController(text: trainer.phone);
  final emailCtrl = TextEditingController(text: trainer.email);
  String level = trainer.level;
  bool saving = false;
  bool deleting = false;

  _showSheet(context, (sheetContext, setSheetState) {
    final levelOptions = context.watch<AppSession>().levelOptions;
    final valid = _isValidPhone(phoneCtrl.text, required: true);

    Future<void> submit() async {
      setSheetState(() => saving = true);
      try {
        await context.read<AppSession>().updateTrainer(
              trainerId: trainer.id, name: nameCtrl.text, phone: phoneCtrl.text,
              email: emailCtrl.text, level: level,
            );
        if (!sheetContext.mounted) return;
        Navigator.pop(sheetContext);
        showYPVToast(context, 'Trainer updated ✓');
      } catch (e) {
        setSheetState(() => saving = false);
        showYPVToast(sheetContext, e is ApiException ? e.message : 'Failed to update trainer');
      }
    }

    Future<void> delete() async {
      setSheetState(() => deleting = true);
      try {
        await context.read<AppSession>().deleteTrainer(trainer.id);
        if (!sheetContext.mounted) return;
        Navigator.pop(sheetContext);
        showYPVToast(context, 'Trainer deleted ✓');
      } catch (e) {
        setSheetState(() => deleting = false);
        showYPVToast(sheetContext, e is ApiException ? e.message : 'Failed to delete trainer');
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sheetTitle('Edit Trainer'),
      const SizedBox(height: 16),
      TextField(controller: nameCtrl, onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Full Name')),
      const SizedBox(height: 14),
      TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
          inputFormatters: _phoneFormatters(),
          onChanged: (_) => setSheetState((){}),
          decoration: InputDecoration(labelText: 'Phone Number',
              errorText: _phoneErrorText(phoneCtrl.text))),
      const SizedBox(height: 14),
      TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Email')),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        value: levelOptions.contains(level) ? level : null,
        decoration: const InputDecoration(labelText: 'Level'),
        items: levelOptions.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
        onChanged: (v) => setSheetState(() => level = v ?? level),
      ),
      const SizedBox(height: 20),
      PrimaryButton(label: 'Save', loading: saving, onPressed: valid ? submit : null),
      const SizedBox(height: 10),
      SecondaryButton(label: 'Delete Trainer', color: AppColors.error,
          onPressed: deleting ? null : delete),
    ]);
  });
}

// ── Student create / edit ──────────────────────────────────────

void _showStudentCreateSheet(BuildContext context, List<TrainerModel> trainers) {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  String workshop = '';
  String trainerId = '';
  bool saving = false;

  _showSheet(context, (sheetContext, setSheetState) {
    final workshopOptions = context.watch<AppSession>().workshopOptions;
    final valid = nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty && trainerId.isNotEmpty &&
        _isValidPhone(phoneCtrl.text);

    Future<void> submit() async {
      setSheetState(() => saving = true);
      try {
        await context.read<AppSession>().createAdminStudent(
              name: nameCtrl.text, email: emailCtrl.text, trainerId: trainerId,
              phone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
              workshopName: workshop.isEmpty ? null : workshop,
            );
        if (!sheetContext.mounted) return;
        Navigator.pop(sheetContext);
        showYPVToast(context, 'Student added ✓');
      } catch (e) {
        setSheetState(() => saving = false);
        showYPVToast(sheetContext, e is ApiException ? e.message : 'Failed to add student');
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sheetTitle('Add Student'),
      const SizedBox(height: 16),
      TextField(controller: nameCtrl, onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Full Name *')),
      const SizedBox(height: 14),
      TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Email *')),
      const SizedBox(height: 14),
      TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
          inputFormatters: _phoneFormatters(),
          onChanged: (_) => setSheetState((){}),
          decoration: InputDecoration(labelText: 'Phone Number',
              errorText: _phoneErrorText(phoneCtrl.text))),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        value: trainerId.isEmpty ? null : trainerId,
        decoration: const InputDecoration(labelText: 'Trainer *'),
        hint: const Text('Assign to trainer'),
        items: trainers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
        onChanged: (v) => setSheetState(() => trainerId = v ?? ''),
      ),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        value: workshop.isEmpty ? null : workshop,
        decoration: const InputDecoration(labelText: 'Workshop (optional)'),
        hint: const Text('Select workshop'),
        items: workshopOptions.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
        onChanged: (v) => setSheetState(() => workshop = v ?? ''),
      ),
      const SizedBox(height: 20),
      PrimaryButton(label: 'Add Student', loading: saving, onPressed: valid ? submit : null),
    ]);
  });
}

void _showStudentEditSheet(BuildContext context, StudentModel student, List<TrainerModel> trainers) {
  final nameCtrl = TextEditingController(text: student.name);
  final emailCtrl = TextEditingController(text: student.email);
  final phoneCtrl = TextEditingController(text: student.phone);
  String level = student.level;
  String trainerId = trainers.firstWhere(
    (t) => t.name == student.trainerName,
    orElse: () => trainers.isNotEmpty ? trainers.first : TrainerModel(
        id: '', name: '', phone: '', email: '', level: '', registrationDate: '', studentCount: 0),
  ).id;
  bool saving = false;
  bool deleting = false;

  _showSheet(context, (sheetContext, setSheetState) {
    final levelOptions = context.watch<AppSession>().levelOptions;
    final trainersForLevel = trainers.where((t) => t.level == level).toList();
    final valid = _isValidPhone(phoneCtrl.text) &&
        trainerId.isNotEmpty && trainersForLevel.any((t) => t.id == trainerId);

    void onLevelChanged(String newLevel) {
      setSheetState(() {
        level = newLevel;
        // The trainer must be re-selected from the trainers at the new level —
        // a Level 1 trainer can't be assigned a Level 2 student, etc.
        if (!trainers.any((t) => t.id == trainerId && t.level == newLevel)) {
          trainerId = '';
        }
      });
    }

    Future<void> submit() async {
      setSheetState(() => saving = true);
      try {
        await context.read<AppSession>().updateAdminStudent(
              studentId: student.id, name: nameCtrl.text, email: emailCtrl.text,
              phone: phoneCtrl.text, level: level, trainerId: trainerId,
            );
        if (!sheetContext.mounted) return;
        Navigator.pop(sheetContext);
        showYPVToast(context, 'Student updated ✓');
      } catch (e) {
        setSheetState(() => saving = false);
        showYPVToast(sheetContext, e is ApiException ? e.message : 'Failed to update student');
      }
    }

    Future<void> delete() async {
      setSheetState(() => deleting = true);
      try {
        await context.read<AppSession>().deleteAdminStudent(student.id);
        if (!sheetContext.mounted) return;
        Navigator.pop(sheetContext);
        showYPVToast(context, 'Student deleted ✓');
      } catch (e) {
        setSheetState(() => deleting = false);
        showYPVToast(sheetContext, e is ApiException ? e.message : 'Failed to delete student');
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sheetTitle('Edit Student'),
      const SizedBox(height: 16),
      TextField(controller: nameCtrl, onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Full Name')),
      const SizedBox(height: 14),
      TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Email')),
      const SizedBox(height: 14),
      TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
          inputFormatters: _phoneFormatters(),
          onChanged: (_) => setSheetState((){}),
          decoration: InputDecoration(labelText: 'Phone Number',
              errorText: _phoneErrorText(phoneCtrl.text))),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        value: levelOptions.contains(level) ? level : null,
        decoration: const InputDecoration(labelText: 'Level'),
        items: levelOptions.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
        onChanged: (v) => onLevelChanged(v ?? level),
      ),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        value: trainersForLevel.any((t) => t.id == trainerId) ? trainerId : null,
        decoration: InputDecoration(
          labelText: 'Trainer (must match level $level) *',
          helperText: trainersForLevel.isEmpty ? 'No trainers available at this level' : null,
          helperStyle: const TextStyle(color: AppColors.error),
        ),
        hint: const Text('Select trainer'),
        items: trainersForLevel.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
        onChanged: (v) => setSheetState(() => trainerId = v ?? trainerId),
      ),
      const SizedBox(height: 20),
      PrimaryButton(label: 'Save', loading: saving, onPressed: valid ? submit : null),
      const SizedBox(height: 10),
      SecondaryButton(label: 'Delete Student', color: AppColors.error,
          onPressed: deleting ? null : delete),
    ]);
  });
}

// ── Admin create / edit ─────────────────────────────────────────

void _showAdminCreateSheet(BuildContext context) {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool saving = false;

  _showSheet(context, (sheetContext, setSheetState) {
    final valid = nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty && passwordCtrl.text.isNotEmpty;

    Future<void> submit() async {
      setSheetState(() => saving = true);
      try {
        await context.read<AppSession>().createAdmin(
              name: nameCtrl.text, email: emailCtrl.text, password: passwordCtrl.text,
            );
        if (!sheetContext.mounted) return;
        Navigator.pop(sheetContext);
        showYPVToast(context, 'Admin added ✓');
      } catch (e) {
        setSheetState(() => saving = false);
        showYPVToast(sheetContext, e is ApiException ? e.message : 'Failed to add admin');
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sheetTitle('Add Admin'),
      const SizedBox(height: 16),
      TextField(controller: nameCtrl, onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Full Name *')),
      const SizedBox(height: 14),
      TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Email *')),
      const SizedBox(height: 14),
      TextField(controller: passwordCtrl, obscureText: true,
          onChanged: (_) => setSheetState((){}),
          decoration: const InputDecoration(labelText: 'Password *')),
      const SizedBox(height: 20),
      PrimaryButton(label: 'Add Admin', loading: saving, onPressed: valid ? submit : null),
    ]);
  });
}

void _showAdminEditSheet(BuildContext context, AdminModel admin) {
  final nameCtrl = TextEditingController(text: admin.name);
  final emailCtrl = TextEditingController(text: admin.email);
  final passwordCtrl = TextEditingController();
  bool saving = false;
  bool deleting = false;

  _showSheet(context, (sheetContext, setSheetState) {
    Future<void> submit() async {
      setSheetState(() => saving = true);
      try {
        await context.read<AppSession>().updateAdmin(
              adminId: admin.id, name: nameCtrl.text, email: emailCtrl.text,
              password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
            );
        if (!sheetContext.mounted) return;
        Navigator.pop(sheetContext);
        showYPVToast(context, 'Admin updated ✓');
      } catch (e) {
        setSheetState(() => saving = false);
        showYPVToast(sheetContext, e is ApiException ? e.message : 'Failed to update admin');
      }
    }

    Future<void> delete() async {
      setSheetState(() => deleting = true);
      try {
        await context.read<AppSession>().deleteAdmin(admin.id);
        if (!sheetContext.mounted) return;
        Navigator.pop(sheetContext);
        showYPVToast(context, 'Admin deleted ✓');
      } catch (e) {
        setSheetState(() => deleting = false);
        showYPVToast(sheetContext, e is ApiException ? e.message : 'Failed to delete admin');
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sheetTitle('Edit Admin'),
      const SizedBox(height: 16),
      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
      const SizedBox(height: 14),
      TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email')),
      const SizedBox(height: 14),
      TextField(controller: passwordCtrl, obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password', hintText: 'Leave blank to keep current')),
      const SizedBox(height: 20),
      PrimaryButton(label: 'Save', loading: saving, onPressed: submit),
      const SizedBox(height: 10),
      SecondaryButton(label: 'Delete Admin', color: AppColors.error,
          onPressed: deleting ? null : delete),
    ]);
  });
}
