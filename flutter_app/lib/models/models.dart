class WorkshopRecord {
  final String workshopName;
  final String completionDate;
  final String certificateNumber;
  final String trainerName;

  const WorkshopRecord({
    required this.workshopName,
    required this.completionDate,
    required this.certificateNumber,
    required this.trainerName,
  });

  factory WorkshopRecord.fromJson(Map<String, dynamic> json) => WorkshopRecord(
        workshopName: json['workshopName'] as String,
        completionDate: json['completionDate'] as String,
        certificateNumber: json['certificateNumber'] as String,
        trainerName: json['trainerName'] as String,
      );

  Map<String, dynamic> toJson() => {
        'workshopName': workshopName,
        'completionDate': completionDate,
        'certificateNumber': certificateNumber,
        'trainerName': trainerName,
      };
}

class StudentModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String level;
  final String trainerName;
  final List<WorkshopRecord> workshopHistory;
  final String? pendingWorkshop;

  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.level,
    required this.trainerName,
    required this.workshopHistory,
    this.pendingWorkshop,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        level: json['level'] as String,
        trainerName: json['trainerName'] as String,
        workshopHistory: (json['workshopHistory'] as List<dynamic>? ?? [])
            .map((w) => WorkshopRecord.fromJson(w as Map<String, dynamic>))
            .toList(),
        pendingWorkshop: json['pendingWorkshop'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'level': level,
        'trainerName': trainerName,
        'workshopHistory': workshopHistory.map((w) => w.toJson()).toList(),
        'pendingWorkshop': pendingWorkshop,
      };

  String get latestCert =>
      workshopHistory.isNotEmpty ? workshopHistory.first.certificateNumber : '—';

  int get workshopCount => workshopHistory.length;
}

class TrainerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String level;
  final String registrationDate;
  int studentCount;

  TrainerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.level,
    required this.registrationDate,
    required this.studentCount,
  });

  factory TrainerModel.fromJson(Map<String, dynamic> json) => TrainerModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        level: json['level'] as String,
        registrationDate: json['registrationDate'] as String,
        studentCount: json['studentCount'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'level': level,
        'registrationDate': registrationDate,
        'studentCount': studentCount,
      };
}

class AdminModel {
  final String id;
  final String name;
  final String email;

  const AdminModel({required this.id, required this.name, required this.email});

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

enum UserRole { trainer, student, admin }
