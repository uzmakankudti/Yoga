import { Admin, Trainer, Student, WorkshopRecord } from '@prisma/client';

type StudentWithRelations = Student & {
  workshopHistory: WorkshopRecord[];
  trainer: Trainer;
};

export function serializeTrainer(trainer: Trainer, studentCount: number) {
  return {
    id: trainer.id,
    name: trainer.name,
    phone: trainer.phone,
    email: trainer.email,
    level: trainer.level,
    registrationDate: trainer.registrationDate,
    studentCount,
  };
}

export function serializeWorkshopRecord(record: WorkshopRecord) {
  return {
    workshopName: record.workshopName,
    completionDate: record.completionDate,
    certificateNumber: record.certificateNumber,
    trainerName: record.trainerName,
  };
}

export function serializeStudent(student: StudentWithRelations) {
  return {
    id: student.id,
    name: student.name,
    email: student.email,
    phone: student.phone ?? '',
    level: student.level,
    trainerName: student.trainer.name,
    workshopHistory: student.workshopHistory.map(serializeWorkshopRecord),
    pendingWorkshop: student.pendingWorkshop,
  };
}

export function serializeAdmin(admin: Admin) {
  return {
    id: admin.id,
    name: admin.name,
    email: admin.email,
  };
}
