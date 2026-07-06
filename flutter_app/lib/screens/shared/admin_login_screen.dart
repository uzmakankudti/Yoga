import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exception.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override State<AdminLoginScreen> createState() => _State();
}

class _State extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  bool get _valid => _emailCtrl.text.isNotEmpty && _passwordCtrl.text.isNotEmpty;

  void _login() async {
    setState(() => _loading = true);
    try {
      await context.read<AppSession>().auth.adminLogin(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
          );
      if (!mounted) return;
      setState(() => _loading = false);
      context.go('/admin/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showYPVToast(context, e is ApiException ? e.message : 'Login failed');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passwordCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.white,
    appBar: AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: BackButton(color: AppColors.ink, onPressed: () => context.go('/login')),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 24),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(16)),
            child: const Center(
              child: Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Admin Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
              letterSpacing: 0.5, color: AppColors.ink)),
          const SizedBox(height: 28),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Admin Email',
              hintText: 'admin@gmail.com',
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, size: 18),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Login', loading: _loading,
              onPressed: _valid ? _login : null),
          const SizedBox(height: 24),
        ]),
      ),
    ),
  );
}
