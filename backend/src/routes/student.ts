import { Router } from 'express';
import { ApiError } from '../lib/apiError';
import { asyncHandler } from '../middleware/errorHandler';
import { requireAuth } from '../middleware/auth';
import { prisma } from '../lib/prisma';
import { serializeStudent } from '../lib/serializers';

export const studentRouter = Router();
studentRouter.use(requireAuth);

async function loadStudentForUser(userId: string) {
  const student = await prisma.student.findUnique({
    where: { userId },
    include: { workshopHistory: true, trainer: true },
  });
  if (!student) throw new ApiError(404, 'Student profile not found');
  return student;
}

studentRouter.get(
  '/me',
  asyncHandler(async (req, res) => {
    const student = await loadStudentForUser(req.userId!);
    res.json(serializeStudent(student));
  }),
);

studentRouter.patch(
  '/me',
  asyncHandler(async (req, res) => {
    const student = await loadStudentForUser(req.userId!);
    const { name, phone, email } = req.body as { name?: string; phone?: string; email?: string };
    const updated = await prisma.student.update({
      where: { id: student.id },
      data: {
        ...(name !== undefined ? { name } : {}),
        ...(phone !== undefined ? { phone } : {}),
        ...(email !== undefined ? { email } : {}),
      },
      include: { workshopHistory: true, trainer: true },
    });
    res.json(serializeStudent(updated));
  }),
);
