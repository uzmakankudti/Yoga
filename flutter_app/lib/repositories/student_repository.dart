import '../core/api_client.dart';
import '../models/models.dart';

class StudentRepository {
  final ApiClient _client;

  StudentRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<StudentModel> getMe() async =>
      StudentModel.fromJson(await _client.get('/student/me') as Map<String, dynamic>);

  Future<StudentModel> updateMe({String? name, String? phone, String? email}) async {
    final result = await _client.patch('/student/me', body: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    });
    return StudentModel.fromJson(result as Map<String, dynamic>);
  }
}
