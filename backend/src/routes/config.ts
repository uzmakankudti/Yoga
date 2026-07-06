import { Router } from 'express';
import { asyncHandler } from '../middleware/errorHandler';
import { requireAuth } from '../middleware/auth';
import { prisma } from '../lib/prisma';
import { deriveLevelFromWorkshop } from '../lib/level';

export const configRouter = Router();
configRouter.use(requireAuth);

configRouter.get(
  '/workshops',
  asyncHandler(async (req, res) => {
    const options = await prisma.workshopOption.findMany({ orderBy: { name: 'asc' } });
    let names = options.map((o) => o.name);

    // Look up the trainer record directly rather than trusting the JWT's
    // `role` claim, which is set at OTP-verify time and goes stale the
    // moment someone registers as a trainer within the same token's life.
    const trainer = await prisma.trainer.findUnique({ where: { userId: req.userId! } });
    // A Level 1 trainer may only run Level 1 workshops, so only Level 1
    // students get registered/upgraded by them.
    if (trainer?.level === 'Level 1') {
      names = names.filter((name) => deriveLevelFromWorkshop(name) === 'Level 1');
    }

    res.json(names);
  }),
);

configRouter.get(
  '/levels',
  asyncHandler(async (_req, res) => {
    const options = await prisma.levelOption.findMany({ orderBy: { name: 'asc' } });
    res.json(options.map((o) => o.name));
  }),
);
