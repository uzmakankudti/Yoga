import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exception.dart';
import '../../state/app_session.dart';
import '../../widgets/common_widgets.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});
  @override State<AddStudentScreen> createState() => _State();
}

class _State extends State<AddStudentScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _workshop = '';
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  bool get _valid => _nameCtrl.text.isNotEmpty && _emailCtrl.text.isNotEmpty &&
      _workshop.isNotEmpty;

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AppSession>().addStudent(
            name: _nameCtrl.text,
            email: _emailCtrl.text,
            workshop: _workshop,
          );
      if (!mounted) return;
      setState(() => _loading = false);
      showYPVToast(context, 'Student added successfully ✓');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showYPVToast(context, e is ApiException ? e.message : 'Failed to add student');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add New Student')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const InfoBanner(
                message: 'Register the student now; you can mark their workshop as '
                    'completed (with completion date and certificate number) later from '
                    'their profile.',
              ),
              const SizedBox(height: 14),

              // Name
              TextFormField(
                controller: _nameCtrl,
                onChanged: (_) => setState((){}),
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                decoration: const InputDecoration(labelText: 'Student Full Name *',
                    hintText: 'Aisha Nair'),
              ),
              const SizedBox(height: 14),

              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState((){}),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (!v!.contains('@')) return 'Enter a valid email';
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Student Email ID *',
                    hintText: 'aisha@example.com', helperText: 'Must be unique'),
              ),
              const SizedBox(height: 14),

              // Workshop dropdown
              DropdownButtonFormField<String>(
                value: _workshop.isEmpty ? null : _workshop,
                decoration: const InputDecoration(labelText: 'Workshop Name *'),
                hint: const Text('Select workshop'),
                items: context.watch<AppSession>().workshopOptions.map((w) =>
                    DropdownMenuItem(value: w, child: Text(w))).toList(),
                onChanged: (v) => setState(() => _workshop = v ?? ''),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ]),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Save Student', loading: _loading,
              onPressed: _valid ? _save : null),
        ],
      ),
    ),
  );
}
