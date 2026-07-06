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

String? _phoneErrorText(String text) {
  if (text.isEmpty) return null;
  if (!_kPhoneStartRegex.hasMatch(text)) return 'Mobile number must start with 6, 7, 8, or 9.';
  if (text.length != 10) return 'Mobile number must be exactly 10 digits.';
  return null;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  int _step = 1; // 1 = enter identifier, 2 = enter OTP
  String _otp = '';
  bool _loading = false;
  int _countdown = 0;
  String? _requestId;
  String? _devOtp;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose();
    super.dispose();
  }

  String get _identifier =>
      _tabCtrl.index == 0 ? _phoneCtrl.text : _emailCtrl.text;

  bool get _canSendOtp => _tabCtrl.index == 0
      ? _kPhoneRegex.hasMatch(_phoneCtrl.text)
      : _emailCtrl.text.isNotEmpty;

  void _sendOTP() async {
    if (!_canSendOtp) return;
    setState(() => _loading = true);
    try {
      final result = await context.read<AppSession>().auth.requestOtp(
            identifier: _identifier,
            isPhone: _tabCtrl.index == 0,
          );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _step = 2;
        _countdown = 30;
        _requestId = result.requestId;
        _devOtp = result.devOtp;
      });
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showYPVToast(context, e is ApiException ? e.message : 'Failed to send OTP');
    }
  }

  void _startCountdown() async {
    while (_countdown > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _countdown--);
    }
  }

  void _verify() async {
    if (_otp.length < 6 || _requestId == null) return;
    setState(() => _loading = true);
    try {
      final result = await context
          .read<AppSession>()
          .auth
          .verifyOtp(requestId: _requestId!, otp: _otp);
      if (!mounted) return;
      setState(() => _loading = false);
      switch (result.role) {
        case UserRole.trainer:
          context.go('/trainer/home');
        case UserRole.student:
          context.go('/student/home');
        case UserRole.admin:
          context.go('/admin/home');
        case null:
          showYPVToast(context, 'No account found. Please contact your administrator.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showYPVToast(context, e is ApiException ? e.message : 'Failed to verify OTP');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.white,
    appBar: _step == 2
        ? AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: BackButton(
              color: AppColors.ink,
              onPressed: () => setState(() { _step = 1; _otp = ''; _devOtp = null; }),
            ),
          )
        : null,
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (_step == 1)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: Image.asset('assets/images/login_banner.jpg',
                  width: double.infinity, height: 160, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(height: _step == 1 ? 24 : 48),
          Image.asset('assets/images/ypv_logo.jpg', width: 72, height: 72),
          const SizedBox(height: 20),
          Text(_step == 1 ? 'Login' : 'Enter OTP',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500,
                  letterSpacing: 0.5, color: AppColors.ink)),
          const SizedBox(height: 6),
          if (_step == 2)
            Text('Sent to ${_tabCtrl.index == 0 ? "+91 ****${_identifier.length > 4 ? _identifier.substring(_identifier.length - 4) : '****'}" : "${_identifier.substring(0,3)}***"}',
                style: const TextStyle(fontSize: 13, letterSpacing: 0.5, color: AppColors.muted)),
          if (_step == 2 && _devOtp != null) ...[
            const SizedBox(height: 12),
            InfoBanner(message: 'Dev mode — no SMS/email sent. Your OTP is $_devOtp'),
          ],
          const SizedBox(height: 28),

          if (_step == 1) ...[
            // Tab selector
            Container(
              height: 44, padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.bg,
                  borderRadius: BorderRadius.circular(10)),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                        blurRadius: 4, offset: const Offset(0, 1))]),
                labelColor: AppColors.ink,
                unselectedLabelColor: AppColors.muted,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                    letterSpacing: 0.5),
                unselectedLabelStyle: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                tabs: const [Tab(text: 'Phone'), Tab(text: 'Email')],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '98765 43210',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                      errorText: _phoneErrorText(_phoneCtrl.text),
                    ),
                  ),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'name@email.com',
                      prefixIcon: Icon(Icons.email_outlined, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Send OTP', loading: _loading,
                onPressed: _canSendOtp ? _sendOTP : null),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/admin-login'),
              child: const Text('Admin Login',
                  style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 0.5)),
            ),
          ] else ...[
            // OTP step
            OtpInput(onChanged: (v) => setState(() => _otp = v)),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Verify & Continue', loading: _loading,
                onPressed: _otp.length == 6 ? _verify : null),
            const SizedBox(height: 12),
            _countdown > 0
              ? Text('Resend in 0:${_countdown.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 13, letterSpacing: 0.5, color: AppColors.muted))
              : TextButton(
                  onPressed: () { setState(() { _otp = ''; _countdown = 30; }); _startCountdown(); },
                  child: const Text('Resend OTP',
                      style: TextStyle(color: AppColors.primary, fontSize: 13))),
            TextButton(
              onPressed: () => setState(() { _step = 1; _otp = ''; }),
              child: const Text('Change number / email',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ),
          ],
          const SizedBox(height: 24),
            ]),
          ),
        ]),
      ),
    ),
  );
}
