import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { ApiError } from '../lib/apiError';
import { asyncHandler } from '../middleware/errorHandler';
import { requireAuth, requireAdmin } from '../middleware/auth';
import { prisma } from '../lib/prisma';
import { serializeAdmin, serializeStudent, serializeTrainer } from '../lib/serializers';
import { deriveLevelFromWorkshop } from '../lib/level';

export const adminRouter = Router();
adminRouter.use(requireAuth, requireAdmin);

function todayFormatted(): string {
  return new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
}

// ── Admins ─────────────────────────────────────────────────────

adminRouter.get(
  '/admins',
  asyncHandler(async (_req, res) => {
    const admins = await prisma.admin.findMany({ orderBy: { name: 'asc' } });
    res.json(admins.map(serializeAdmin));
  }),
);

adminRouter.post(
  '/admins',
  asyncHandler(async (req, res) => {
    const { name, email, password } = req.body as { name?: string; email?: string; password?: string };
    if (!name || !email || !password) throw new ApiError(400, 'name, email and password are required');

    const existing = await prisma.admin.findUnique({ where: { email } });
    if (existing) throw new ApiError(409, 'An admin with that email already exists');

    const admin = await prisma.admin.create({
      data: { name, email, passwordHash: await bcrypt.hash(password, 10) },
    });
    res.json(serializeAdmin(admin));
  }),
);

adminRouter.patch(
  '/admins/:id',
  asyncHandler(async (req, res) => {
    const { name, email, password } = req.body as { name?: string; email?: string; password?: string };
    const admin = await prisma.admin.findUnique({ where: { id: req.params.id } });
    if (!admin) throw new ApiError(404, 'Admin not found');

    const updated = await prisma.admin.update({
      where: { id: admin.id },
      data: {
        ...(name !== undefined ? { name } : {}),
        ...(email !== undefined ? { email } : {}),
        ...(password !== undefined ? { passwordHash: await bcrypt.hash(password, 10) } : {}),
      },
    });
    res.json(serializeAdmin(updated));
  }),
);

adminRouter.delete(
  '/admins/:id',
  asyncHandler(async (req, res) => {
    const admin = await prisma.admin.findUnique({ where: { id: req.params.id } });
    if (!admin) throw new ApiError(404, 'Admin not found');

    const adminCount = await prisma.admin.count();
    if (adminCount <= 1) throw new ApiError(409, 'Cannot delete the last remaining admin account');

    await prisma.admin.delete({ where: { id: admin.id } });
    res.json({ success: true });
  }),
);

// ── Trainers ───────────────────────────────────────────────────

adminRouter.get(
  '/trainers',
  asyncHandler(async (_req, res) => {
    const trainers = await prisma.trainer.findMany({ orderBy: { name: 'asc' } });
    const counts = await prisma.student.groupBy({ by: ['trainerId'], _count: { trainerId: true } });
    const countByTrainerId = new Map(counts.map((c) => [c.trainerId, c._count.trainerId]));
    res.json(trainers.map((t) => serializeTrainer(t, countByTrainerId.get(t.id) ?? 0)));
  }),
);

adminRouter.post(
  '/trainers',
  asyncHandler(async (req, res) => {
    const { name, phone, email, level } = req.body as {
      name?: string; phone?: string; email?: string; level?: string;
    };
    if (!name || !phone || !email || !level) {
      throw new ApiError(400, 'name, phone, email and level are required');
    }

    let trainer;
    try {
      trainer = await prisma.$transaction(async (tx) => {
        const user = await tx.user.create({ data: { phone, email, role: 'TRAINER' } });
        return tx.trainer.create({
          data: { userId: user.id, name, phone, email, level, registrationDate: todayFormatted() },
        });
      });
    } catch (e: any) {
      if (e?.code === 'P2002') throw new ApiError(409, 'That phone number or email is already in use');
      throw e;
    }

    res.json(serializeTrainer(trainer, 0));
  }),
);

adminRouter.patch(
  '/trainers/:id',
  asyncHandler(async (req, res) => {
    const { name, phone, email, level } = req.body as {
      name?: string; phone?: string; email?: string; level?: string;
    };
    const trainer = await prisma.trainer.findUnique({ where: { id: req.params.id } });
    if (!trainer) throw new ApiError(404, 'Trainer not found');

    const updated = await prisma.trainer.update({
      where: { id: trainer.id },
      data: {
        ...(name !== undefined ? { name } : {}),
        ...(phone !== undefined ? { phone } : {}),
        ...(email !== undefined ? { email } : {}),
        ...(level !== undefined ? { level } : {}),
      },
    });
    const studentCount = await prisma.student.count({ where: { trainerId: trainer.id } });
    res.json(serializeTrainer(updated, studentCount));
  }),
);

adminRouter.delete(
  '/trainers/:id',
  asyncHandler(async (req, res) => {
    const trainer = await prisma.trainer.findUnique({ where: { id: req.params.id } });
    if (!trainer) throw new ApiError(404, 'Trainer not found');

    const studentCount = await prisma.student.count({ where: { trainerId: trainer.id } });
    if (studentCount > 0) {
      throw new ApiError(409, 'Reassign or remove this trainer\'s students before deleting them');
    }

    await prisma.trainer.delete({ where: { id: trainer.id } });
    res.json({ success: true });
  }),
);

// ── Students ───────────────────────────────────────────────────

adminRouter.get(
  '/students',
  asyncHandler(async (_req, res) => {
    const students = await prisma.student.findMany({
      include: { workshopHistory: true, trainer: true },
      orderBy: { name: 'asc' },
    });
    res.json(students.map(serializeStudent));
  }),
);

adminRouter.post(
  '/students',
  asyncHandler(async (req, res) => {
    const { name, email, phone, workshopName, trainerId } = req.body as {
      name?: string; email?: string; phone?: string; workshopName?: string; trainerId?: string;
    };
    if (!name || !email || !trainerId) throw new ApiError(400, 'name, email and trainerId are required');

    const trainer = await prisma.trainer.findUnique({ where: { id: trainerId } });
    if (!trainer) throw new ApiError(404, 'Trainer not found');

    let student;
    try {
      student = await prisma.$transaction(async (tx) => {
        const user = await tx.user.create({ data: { email, phone: phone || null, role: 'STUDENT' } });
        return tx.student.create({
          data: {
            userId: user.id,
            name,
            email,
            phone: phone || null,
            level: workshopName ? deriveLevelFromWorkshop(workshopName) : 'Level 1',
            trainerId: trainer.id,
            pendingWorkshop: workshopName ?? null,
          },
          include: { workshopHistory: true, trainer: true },
        });
      });
    } catch (e: any) {
      if (e?.code === 'P2002') throw new ApiError(409, 'That phone number or email is already in use');
      throw e;
    }

    res.json(serializeStudent(student));
  }),
);

adminRouter.patch(
  '/students/:id',
  asyncHandler(async (req, res) => {
    const { name, email, phone, level, trainerId } = req.body as {
      name?: string; email?: string; phone?: string; level?: string; trainerId?: string;
    };
    const student = await prisma.student.findUnique({ where: { id: req.params.id } });
    if (!student) throw new ApiError(404, 'Student not found');

    if (trainerId !== undefined) {
      const trainer = await prisma.trainer.findUnique({ where: { id: trainerId } });
      if (!trainer) throw new ApiError(404, 'Trainer not found');
    }

    const updated = await prisma.student.update({
      where: { id: student.id },
      data: {
        ...(name !== undefined ? { name } : {}),
        ...(email !== undefined ? { email } : {}),
        ...(phone !== undefined ? { phone } : {}),
        ...(level !== undefined ? { level } : {}),
        ...(trainerId !== undefined ? { trainerId } : {}),
      },
      include: { workshopHistory: true, trainer: true },
    });
    res.json(serializeStudent(updated));
  }),
);

adminRouter.delete(
  '/students/:id',
  asyncHandler(async (req, res) => {
    const student = await prisma.student.findUnique({ where: { id: req.params.id } });
    if (!student) throw new ApiError(404, 'Student not found');
    await prisma.$transaction([
      prisma.workshopRecord.deleteMany({ where: { studentId: student.id } }),
      prisma.student.delete({ where: { id: student.id } }),
    ]);
    res.json({ success: true });
  }),
);
