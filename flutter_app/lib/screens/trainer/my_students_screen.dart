import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class MyStudentsScreen extends StatefulWidget {
  const MyStudentsScreen({super.key});
  @override State<MyStudentsScreen> createState() => _State();
}

class _State extends State<MyStudentsScreen> {
  String _query = '';
  String _workshopFilter = '';

  List<StudentModel> _filtered(List<StudentModel> students) => students.where((s) {
    final qMatch = s.name.toLowerCase().contains(_query.toLowerCase()) ||
        s.email.toLowerCase().contains(_query.toLowerCase());
    final wMatch = _workshopFilter.isEmpty ||
        s.workshopHistory.any((w) => w.workshopName == _workshopFilter);
    return qMatch && wMatch;
  }).toList();

  List<String> _workshopOptions(List<StudentModel> students) {
    final all = students
        .expand((s) => s.workshopHistory.map((w) => w.workshopName))
        .toSet()
        .toList()
      ..sort();
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<AppSession>().students;
    final filtered = _filtered(students);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('My Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(students),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: YPVSearchBar(hint: 'Search by name or email…', onChanged: (v) => setState(() => _query = v)),
        ),

        // Active filter chip
        if (_workshopFilter.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(children: [
              const Text('Filter: ', style: TextStyle(fontSize: 12, color: AppColors.muted)),
              Chip(
                label: Text(_workshopFilter,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                backgroundColor: AppColors.primaryTint,
                deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
                onDeleted: () => setState(() => _workshopFilter = ''),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
            ]),
          ),

        const SizedBox(height: 10),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(title: 'No students yet',
                  subtitle: 'Add your first student after a completed workshop',
                  buttonLabel: 'Add Student',
                  onButton: () => context.push('/trainer/add-student'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _StudentRow(student: filtered[i]),
                ),
        ),
      ]),
    );
  }

  void _showFilterSheet(List<StudentModel> students) {
    final options = _workshopOptions(students);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.line,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Filter by Workshop', style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.ink)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              PillChip(label: 'All', selected: _workshopFilter.isEmpty,
                  onTap: () { setState(() => _workshopFilter = ''); Navigator.pop(ctx); }),
              ...options.map((w) => PillChip(
                label: w, selected: _workshopFilter == w,
                onTap: () { setState(() => _workshopFilter = w); Navigator.pop(ctx); },
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final StudentModel student;
  const _StudentRow({required this.student});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: WhiteCard(
      onTap: () => context.push('/trainer/student-detail/${student.id}'),
      child: Row(children: [
        YPVAvatar(name: student.name, size: 42),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(student.name, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.ink)),
          const SizedBox(height: 4),
          Text(student.workshopHistory.isNotEmpty
              ? '${student.workshopHistory.first.workshopName} · ${student.workshopHistory.first.completionDate}'
              : student.pendingWorkshop != null
                  ? 'Pending: ${student.pendingWorkshop}'
                  : 'No workshops yet',
              style: const TextStyle(fontSize: 12, letterSpacing: 0.5, color: AppColors.muted)),
        ])),
        LevelBadge(student.level),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
      ]),
    ),
  );
}
