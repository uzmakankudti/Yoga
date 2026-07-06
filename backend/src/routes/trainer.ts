import { Router } from 'express';
import { ApiError } from '../lib/apiError';
import { asyncHandler } from '../middleware/errorHandler';
import { requireAuth } from '../middleware/auth';
import { prisma } from '../lib/prisma';
import { serializeStudent, serializeTrainer } from '../lib/serializers';
import { canUpgrade, deriveLevelFromWorkshop } from '../lib/level';

export const trainerRouter = Router();
trainerRouter.use(requireAuth);

async function loadTrainerForUser(userId: string) {
  const trainer = await prisma.trainer.findUnique({ where: { userId } });
  if (!trainer) throw new ApiError(404, 'Trainer profile not found');
  return trainer;
}

trainerRouter.get(
  '/me',
  asyncHandler(async (req, res) => {
    const trainer = await loadTrainerForUser(req.userId!);
    const studentCount = await prisma.student.count({ where: { trainerId: trainer.id } });
    res.json(serializeTrainer(trainer, studentCount));
  }),
);

trainerRouter.patch(
  '/me',
  asyncHandler(async (req, res) => {
    const trainer = await loadTrainerForUser(req.userId!);
    const { name, phone, email } = req.body as { name?: string; phone?: string; email?: string };
    const updated = await prisma.trainer.update({
      where: { id: trainer.id },
      data: {
        ...(name !== undefined ? { name } : {}),
        ...(phone !== undefined ? { phone } : {}),
        ...(email !== undefined ? { email } : {}),
      },
    });
    const studentCount = await prisma.student.count({ where: { trainerId: trainer.id } });
    res.json(serializeTrainer(updated, studentCount));
  }),
);

trainerRouter.get(
  '/students',
  asyncHandler(async (req, res) => {
    const trainer = await loadTrainerForUser(req.userId!);
    const { search, workshop } = req.query as { search?: string; workshop?: string };

    const students = await prisma.student.findMany({
      where: {
        trainerId: trainer.id,
        ...(search
          ? {
              OR: [
                { name: { contains: search, mode: 'insensitive' } },
                { email: { contains: search, mode: 'insensitive' } },
              ],
            }
          : {}),
        ...(workshop ? { workshopHistory: { some: { workshopName: workshop } } } : {}),
      },
      include: { workshopHistory: true, trainer: true },
      orderBy: { name: 'asc' },
    });

    res.json(students.map(serializeStudent));
  }),
);

trainerRouter.get(
  '/students/by-cert/:cert',
  asyncHandler(async (req, res) => {
    const trainer = await loadTrainerForUser(req.userId!);
    const record = await prisma.workshopRecord.findUnique({
      where: { certificateNumber: req.params.cert },
      include: { student: { include: { workshopHistory: true, trainer: true } } },
    });
    if (!record || record.student.trainerId !== trainer.id) {
      throw new ApiError(404, 'No student found for this certificate number');
    }
    res.json(serializeStudent(record.student));
  }),
);

trainerRouter.get(
  '/students/:id',
  asyncHandler(async (req, res) => {
    const trainer = await loadTrainerForUser(req.userId!);
    const student = await prisma.student.findUnique({
      where: { id: req.params.id },
      include: { workshopHistory: true, trainer: true },
    });
    if (!student || student.trainerId !== trainer.id) {
      throw new ApiError(404, 'Student not found');
    }
    res.json(serializeStudent(student));
  }),
);

trainerRouter.post(
  '/students',
  asyncHandler(async (req, res) => {
    const trainer = await loadTrainerForUser(req.userId!);
    const { name, email, workshopName, completionDate, certificateNumber } = req.body as {
      name?: string;
      email?: string;
      workshopName?: string;
      completionDate?: string;
      certificateNumber?: string;
    };
    if (!name || !email || !workshopName) {
      throw new ApiError(400, 'name, email and workshopName are required');
    }
    // Completion details are optional at registration time: a student can be
    // added while still working toward their first workshop.
    if ((completionDate && !certificateNumber) || (!completionDate && certificateNumber)) {
      throw new ApiError(400, 'completionDate and certificateNumber must be provided together');
    }
    const isComplete = Boolean(completionDate && certificateNumber);

    if (isComplete) {
      const existingCert = await prisma.workshopRecord.findUnique({ where: { certificateNumber } });
      if (existingCert) throw new ApiError(409, 'Certificate number already in use');
    }

    let student;
    try {
      student = await prisma.$transaction(async (tx) => {
        // A linked User row is required so this student can later log in via
        // OTP — without it, /otp/verify has no account to resolve to.
        const user = await tx.user.create({ data: { email, role: 'STUDENT' } });
        return tx.student.create({
          data: {
            userId: user.id,
            name,
            email,
            level: deriveLevelFromWorkshop(workshopName),
            trainerId: trainer.id,
            pendingWorkshop: isComplete ? null : workshopName,
            workshopHistory: isComplete
              ? { create: [{ workshopName, completionDate: completionDate!, certificateNumber: certificateNumber!, trainerName: trainer.name }] }
              : undefined,
          },
          include: { workshopHistory: true, trainer: true },
        });
      });
    } catch (e: any) {
      if (e?.code === 'P2002') throw new ApiError(409, 'That email is already registered to another account');
      throw e;
    }

    res.json(serializeStudent(student));
  }),
);

trainerRouter.post(
  '/students/:id/complete-workshop',
  asyncHandler(async (req, res) => {
    const trainer = await loadTrainerForUser(req.userId!);
    const existing = await prisma.student.findUnique({ where: { id: req.params.id } });
    if (!existing || existing.trainerId !== trainer.id) {
      throw new ApiError(404, 'Student not found');
    }
    if (!existing.pendingWorkshop) {
      throw new ApiError(400, 'This student has no pending workshop to mark complete');
    }

    const { completionDate, certificateNumber } = req.body as {
      completionDate?: string;
      certificateNumber?: string;
    };
    if (!completionDate || !certificateNumber) {
      throw new ApiError(400, 'completionDate and certificateNumber are required');
    }

    const existingCert = await prisma.workshopRecord.findUnique({ where: { certificateNumber } });
    if (existingCert) throw new ApiError(409, 'Certificate number already in use');

    const student = await prisma.student.update({
      where: { id: existing.id },
      data: {
        level: deriveLevelFromWorkshop(existing.pendingWorkshop, existing.level),
        pendingWorkshop: null,
        workshopHistory: {
          create: [{
            workshopName: existing.pendingWorkshop,
            completionDate,
            certificateNumber,
            trainerName: trainer.name,
          }],
        },
      },
      include: { workshopHistory: true, trainer: true },
    });

    res.json(serializeStudent(student));
  }),
);

trainerRouter.post(
  '/students/:id/upgrade',
  asyncHandler(async (req, res) => {
    const trainer = await loadTrainerForUser(req.userId!);
    const existing = await prisma.student.findUnique({ where: { id: req.params.id } });
    if (!existing || existing.trainerId !== trainer.id) {
      throw new ApiError(404, 'Student not found');
    }

    const { workshopName, completionDate, certificateNumber } = req.body as {
      workshopName?: string;
      completionDate?: string;
      certificateNumber?: string;
    };
    if (!workshopName || !completionDate || !certificateNumber) {
      throw new ApiError(400, 'workshopName, completionDate and certificateNumber are required');
    }

    const targetLevel = deriveLevelFromWorkshop(workshopName, existing.level);
    const permission = canUpgrade(trainer.level, existing.level, targetLevel);
    if (!permission.allowed) {
      throw new ApiError(403, permission.reason ?? 'Not allowed to upgrade this student');
    }

    const existingCert = await prisma.workshopRecord.findUnique({ where: { certificateNumber } });
    if (existingCert) throw new ApiError(409, 'Certificate number already in use');

    const student = await prisma.student.update({
      where: { id: existing.id },
      data: {
        level: deriveLevelFromWorkshop(workshopName, existing.level),
        workshopHistory: {
          create: [{ workshopName, completionDate, certificateNumber, trainerName: trainer.name }],
        },
      },
      include: { workshopHistory: true, trainer: true },
    });

    res.json(serializeStudent(student));
  }),
);
