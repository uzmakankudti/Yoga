import 'package:flutter/foundation.dart';
import '../core/api_exception.dart';
import '../core/token_store.dart';
import '../models/models.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/config_repository.dart';
import '../repositories/student_repository.dart';
import '../repositories/trainer_repository.dart';

class AppSession extends ChangeNotifier {
  final AuthRepository _authRepo;
  final TrainerRepository _trainerRepo;
  final StudentRepository _studentRepo;
  final ConfigRepository _configRepo;
  final AdminRepository _adminRepo;
  final TokenStore _tokenStore;

  AppSession({
    AuthRepository? authRepo,
    TrainerRepository? trainerRepo,
    StudentRepository? studentRepo,
    ConfigRepository? configRepo,
    AdminRepository? adminRepo,
    TokenStore? tokenStore,
  })  : _authRepo = authRepo ?? AuthRepository(),
        _trainerRepo = trainerRepo ?? TrainerRepository(),
        _studentRepo = studentRepo ?? StudentRepository(),
        _configRepo = configRepo ?? ConfigRepository(),
        _adminRepo = adminRepo ?? AdminRepository(),
        _tokenStore = tokenStore ?? TokenStore();

  AuthRepository get auth => _authRepo;

  UserRole? role;
  TrainerModel? trainer;
  StudentModel? student;
  List<StudentModel> students = [];
  List<String> workshopOptions = [];
  List<String> levelOptions = [];

  List<TrainerModel> adminTrainers = [];
  List<StudentModel> adminStudents = [];
  List<AdminModel> adminAdmins = [];

  bool trainerLoading = false;
  bool studentLoading = false;
  bool studentsLoading = false;
  bool configLoading = false;
  bool adminLoading = false;

  String? trainerError;
  String? studentError;
  String? studentsError;
  String? configError;
  String? adminError;

  String _errorMessage(Object e) => e is ApiException ? e.message : 'Something went wrong';

  Future<void> loadConfig() async {
    configLoading = true;
    configError = null;
    notifyListeners();
    try {
      workshopOptions = await _configRepo.getWorkshopOptions();
      levelOptions = await _configRepo.getLevelOptions();
    } catch (e) {
      configError = _errorMessage(e);
    } finally {
      configLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTrainerSession() async {
    role = UserRole.trainer;
    trainerLoading = true;
    trainerError = null;
    notifyListeners();
    try {
      trainer = await _trainerRepo.getMe();
    } catch (e) {
      trainerError = _errorMessage(e);
    } finally {
      trainerLoading = false;
      notifyListeners();
    }
    await Future.wait([refreshStudents(), loadConfig()]);
  }

  Future<void> refreshStudents({String? search, String? workshop}) async {
    studentsLoading = true;
    studentsError = null;
    notifyListeners();
    try {
      students = await _trainerRepo.getStudents(search: search, workshop: workshop);
      if (trainer != null) trainer!.studentCount = students.length;
    } catch (e) {
      studentsError = _errorMessage(e);
    } finally {
      studentsLoading = false;
      notifyListeners();
    }
  }

  Future<StudentModel?> getStudent(String id) async {
    try {
      return await _trainerRepo.getStudent(id);
    } catch (_) {
      return students.where((s) => s.id == id).firstOrNull;
    }
  }

  Future<StudentModel?> findStudentByCert(String cert) => _trainerRepo.findStudentByCert(cert);

  Future<StudentModel> addStudent({
    required String name,
    required String email,
    required String workshop,
    String? completionDate,
    String? certificateNumber,
  }) async {
    final created = await _trainerRepo.addStudent(
      name: name,
      email: email,
      workshop: workshop,
      completionDate: completionDate,
      certificateNumber: certificateNumber,
    );
    students = [...students, created];
    if (trainer != null) trainer!.studentCount = students.length;
    notifyListeners();
    return created;
  }

  Future<StudentModel> completeWorkshop({
    required String studentId,
    required String completionDate,
    required String certificateNumber,
  }) async {
    final updated = await _trainerRepo.completeWorkshop(
      studentId: studentId,
      completionDate: completionDate,
      certificateNumber: certificateNumber,
    );
    students = students.map((s) => s.id == updated.id ? updated : s).toList();
    notifyListeners();
    return updated;
  }

  Future<StudentModel> upgradeStudent({
    required String studentId,
    required String workshopName,
    required String completionDate,
    required String certificateNumber,
  }) async {
    final updated = await _trainerRepo.upgradeStudent(
      studentId: studentId,
      workshopName: workshopName,
      completionDate: completionDate,
      certificateNumber: certificateNumber,
    );
    students = students.map((s) => s.id == updated.id ? updated : s).toList();
    notifyListeners();
    return updated;
  }

  Future<void> loadStudentSession() async {
    role = UserRole.student;
    studentLoading = true;
    studentError = null;
    notifyListeners();
    try {
      student = await _studentRepo.getMe();
    } catch (e) {
      studentError = _errorMessage(e);
    } finally {
      studentLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAdminData() async {
    role = UserRole.admin;
    adminLoading = true;
    adminError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _adminRepo.getTrainers(),
        _adminRepo.getStudents(),
        _adminRepo.getAdmins(),
      ]);
      adminTrainers = results[0] as List<TrainerModel>;
      adminStudents = results[1] as List<StudentModel>;
      adminAdmins = results[2] as List<AdminModel>;
    } catch (e) {
      adminError = _errorMessage(e);
    } finally {
      adminLoading = false;
      notifyListeners();
    }
    if (levelOptions.isEmpty) await loadConfig();
  }

  Future<AdminModel> createAdmin({required String name, required String email, required String password}) async {
    final created = await _adminRepo.createAdmin(name: name, email: email, password: password);
    adminAdmins = [...adminAdmins, created];
    notifyListeners();
    return created;
  }

  Future<void> updateAdmin({required String adminId, String? name, String? email, String? password}) async {
    final updated = await _adminRepo.updateAdmin(adminId: adminId, name: name, email: email, password: password);
    adminAdmins = adminAdmins.map((a) => a.id == updated.id ? updated : a).toList();
    notifyListeners();
  }

  Future<void> deleteAdmin(String adminId) async {
    await _adminRepo.deleteAdmin(adminId);
    adminAdmins = adminAdmins.where((a) => a.id != adminId).toList();
    notifyListeners();
  }

  Future<TrainerModel> createTrainer({
    required String name,
    required String phone,
    required String email,
    required String level,
  }) async {
    final created = await _adminRepo.createTrainer(name: name, phone: phone, email: email, level: level);
    adminTrainers = [...adminTrainers, created];
    notifyListeners();
    return created;
  }

  Future<void> updateTrainer({
    required String trainerId,
    String? name,
    String? phone,
    String? email,
    String? level,
  }) async {
    final updated = await _adminRepo.updateTrainer(
      trainerId: trainerId, name: name, phone: phone, email: email, level: level,
    );
    adminTrainers = adminTrainers.map((t) => t.id == updated.id ? updated : t).toList();
    notifyListeners();
  }

  Future<void> deleteTrainer(String trainerId) async {
    await _adminRepo.deleteTrainer(trainerId);
    adminTrainers = adminTrainers.where((t) => t.id != trainerId).toList();
    notifyListeners();
  }

  Future<StudentModel> createAdminStudent({
    required String name,
    required String email,
    required String trainerId,
    String? phone,
    String? workshopName,
  }) async {
    final created = await _adminRepo.createStudent(
      name: name, email: email, trainerId: trainerId, phone: phone, workshopName: workshopName,
    );
    adminStudents = [...adminStudents, created];
    notifyListeners();
    return created;
  }

  Future<void> updateAdminStudent({
    required String studentId,
    String? name,
    String? email,
    String? phone,
    String? level,
    String? trainerId,
  }) async {
    final updated = await _adminRepo.updateStudent(
      studentId: studentId, name: name, email: email, phone: phone, level: level, trainerId: trainerId,
    );
    adminStudents = adminStudents.map((s) => s.id == updated.id ? updated : s).toList();
    notifyListeners();
  }

  Future<void> deleteAdminStudent(String studentId) async {
    await _adminRepo.deleteStudent(studentId);
    adminStudents = adminStudents.where((s) => s.id != studentId).toList();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepo.logout();
    role = null;
    trainer = null;
    student = null;
    students = [];
    adminTrainers = [];
    adminStudents = [];
    adminAdmins = [];
    notifyListeners();
  }

  Future<String?> currentRoleFromStorage() => _tokenStore.getRole();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
