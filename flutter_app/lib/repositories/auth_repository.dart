import '../core/api_client.dart';
import '../core/token_store.dart';
import '../models/models.dart';

class OtpVerifyResult {
  final UserRole? role;
  final String userId;

  OtpVerifyResult({required this.role, required this.userId});
}

class OtpRequestResult {
  final String requestId;
  // Dev-only: the backend echoes the OTP back since no real SMS/email
  // provider is wired up. Never rely on this field against a real backend.
  final String? devOtp;

  OtpRequestResult({required this.requestId, this.devOtp});
}

class AuthRepository {
  final ApiClient _client;
  final TokenStore _tokenStore;

  AuthRepository({ApiClient? client, TokenStore? tokenStore})
      : _client = client ?? ApiClient(),
        _tokenStore = tokenStore ?? TokenStore();

  Future<OtpRequestResult> requestOtp({required String identifier, required bool isPhone}) async {
    final result = await _client.post(
      '/auth/otp/request',
      auth: false,
      body: {'identifier': identifier, 'channel': isPhone ? 'phone' : 'email'},
    );
    return OtpRequestResult(
      requestId: result['requestId'] as String,
      devOtp: result['otp'] as String?,
    );
  }

  Future<OtpVerifyResult> verifyOtp({required String requestId, required String otp}) async {
    final result = await _client.post(
      '/auth/otp/verify',
      auth: false,
      body: {'requestId': requestId, 'otp': otp},
    );
    final roleStr = result['role'] as String?;
    final role = roleStr == 'trainer'
        ? UserRole.trainer
        : roleStr == 'student'
            ? UserRole.student
            : null;
    await _tokenStore.saveSession(
      accessToken: result['accessToken'] as String,
      refreshToken: result['refreshToken'] as String,
      role: roleStr,
      userId: result['userId'] as String,
    );
    return OtpVerifyResult(role: role, userId: result['userId'] as String);
  }

  Future<void> adminLogin({required String email, required String password}) async {
    final result = await _client.post(
      '/auth/admin/login',
      auth: false,
      body: {'email': email, 'password': password},
    );
    await _tokenStore.saveSession(
      accessToken: result['accessToken'] as String,
      refreshToken: result['refreshToken'] as String,
      role: result['role'] as String,
      userId: result['userId'] as String,
    );
  }

  Future<void> logout() => _tokenStore.clear();
}
