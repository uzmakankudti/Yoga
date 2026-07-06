import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/models.dart';

class TrainerRepository {
  final ApiClient _client;

  TrainerRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<TrainerModel> getMe() async =>
      TrainerModel.fromJson(await _client.get('/trainer/me') as Map<String, dynamic>);

  Future<TrainerModel> updateMe({String? name, String? phone, String? email}) async {
    final result = await _client.patch('/trainer/me', body: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    });
    return TrainerModel.fromJson(result as Map<String, dynamic>);
  }

  Future<List<StudentModel>> getStudents({String? search, String? workshop}) async {
    final result = await _client.get('/trainer/students', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (workshop != null && workshop.isNotEmpty) 'workshop': workshop,
    });
    return (result as List<dynamic>)
        .map((s) => StudentModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<StudentModel> getStudent(String id) async =>
      StudentModel.fromJson(await _client.get('/trainer/students/$id') as Map<String, dynamic>);

  Future<StudentModel> addStudent({
    required String name,
    required String email,
    required String workshop,
    String? completionDate,
    String? certificateNumber,
  }) async {
    final result = await _client.post('/trainer/students', body: {
      'name': name,
      'email': email,
      'workshopName': workshop,
      if (completionDate != null) 'completionDate': completionDate,
      if (certificateNumber != null) 'certificateNumber': certificateNumber,
    });
    return StudentModel.fromJson(result as Map<String, dynamic>);
  }

  Future<StudentModel> completeWorkshop({
    required String studentId,
    required String completionDate,
    required String certificateNumber,
  }) async {
    final result = await _client.post('/trainer/students/$studentId/complete-workshop', body: {
      'completionDate': completionDate,
      'certificateNumber': certificateNumber,
    });
    return StudentModel.fromJson(result as Map<String, dynamic>);
  }

  Future<StudentModel> upgradeStudent({
    required String studentId,
    required String workshopName,
    required String completionDate,
    required String certificateNumber,
  }) async {
    final result = await _client.post('/trainer/students/$studentId/upgrade', body: {
      'workshopName': workshopName,
      'completionDate': completionDate,
      'certificateNumber': certificateNumber,
    });
    return StudentModel.fromJson(result as Map<String, dynamic>);
  }

  Future<StudentModel?> findStudentByCert(String cert) async {
    try {
      final result = await _client.get('/trainer/students/by-cert/$cert');
      return StudentModel.fromJson(result as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
}
