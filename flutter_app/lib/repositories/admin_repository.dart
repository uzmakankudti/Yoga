import '../core/api_client.dart';
import '../models/models.dart';

class AdminRepository {
  final ApiClient _client;

  AdminRepository({ApiClient? client}) : _client = client ?? ApiClient();

  // ── Admins ───────────────────────────────────────────────────
  Future<List<AdminModel>> getAdmins() async {
    final result = await _client.get('/admin/admins');
    return (result as List<dynamic>)
        .map((a) => AdminModel.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  Future<AdminModel> createAdmin({required String name, required String email, required String password}) async {
    final result = await _client.post('/admin/admins', body: {
      'name': name, 'email': email, 'password': password,
    });
    return AdminModel.fromJson(result as Map<String, dynamic>);
  }

  Future<AdminModel> updateAdmin({
    required String adminId,
    String? name,
    String? email,
    String? password,
  }) async {
    final result = await _client.patch('/admin/admins/$adminId', body: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
    });
    return AdminModel.fromJson(result as Map<String, dynamic>);
  }

  Future<void> deleteAdmin(String adminId) => _client.delete('/admin/admins/$adminId');

  // ── Trainers ─────────────────────────────────────────────────
  Future<List<TrainerModel>> getTrainers() async {
    final result = await _client.get('/admin/trainers');
    return (result as List<dynamic>)
        .map((t) => TrainerModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<TrainerModel> createTrainer({
    required String name,
    required String phone,
    required String email,
    required String level,
  }) async {
    final result = await _client.post('/admin/trainers', body: {
      'name': name, 'phone': phone, 'email': email, 'level': level,
    });
    return TrainerModel.fromJson(result as Map<String, dynamic>);
  }

  Future<TrainerModel> updateTrainer({
    required String trainerId,
    String? name,
    String? phone,
    String? email,
    String? level,
  }) async {
    final result = await _client.patch('/admin/trainers/$trainerId', body: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (level != null) 'level': level,
    });
    return TrainerModel.fromJson(result as Map<String, dynamic>);
  }

  Future<void> deleteTrainer(String trainerId) => _client.delete('/admin/trainers/$trainerId');

  // ── Students ─────────────────────────────────────────────────
  Future<List<StudentModel>> getStudents() async {
    final result = await _client.get('/admin/students');
    return (result as List<dynamic>)
        .map((s) => StudentModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<StudentModel> createStudent({
    required String name,
    required String email,
    required String trainerId,
    String? phone,
    String? workshopName,
  }) async {
    final result = await _client.post('/admin/students', body: {
      'name': name,
      'email': email,
      'trainerId': trainerId,
      if (phone != null) 'phone': phone,
      if (workshopName != null) 'workshopName': workshopName,
    });
    return StudentModel.fromJson(result as Map<String, dynamic>);
  }

  Future<StudentModel> updateStudent({
    required String studentId,
    String? name,
    String? email,
    String? phone,
    String? level,
    String? trainerId,
  }) async {
    final result = await _client.patch('/admin/students/$studentId', body: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (level != null) 'level': level,
      if (trainerId != null) 'trainerId': trainerId,
    });
    return StudentModel.fromJson(result as Map<String, dynamic>);
  }

  Future<void> deleteStudent(String studentId) => _client.delete('/admin/students/$studentId');
}
