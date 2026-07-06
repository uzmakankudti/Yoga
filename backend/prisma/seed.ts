import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

const workshopOptions = [
  'Yoga Level 1',
  'Yoga Level 2',
  'Yoga Level 3',
  'Pranayama Basics',
  'Meditation Fundamentals',
  'AUWA Foundation',
  'Crystal/PSP Course',
  'HDP Level 1',
];

const levelOptions = [
  'Level 1',
  'Level 2',
  'Level 3',
  'AUWA',
  'Crystal/PSP',
  'HDP1',
  'Arhat Trainer',
];

async function main() {
  for (const name of workshopOptions) {
    await prisma.workshopOption.upsert({ where: { name }, update: {}, create: { name } });
  }
  for (const name of levelOptions) {
    await prisma.levelOption.upsert({ where: { name }, update: {}, create: { name } });
  }

  const adminCount = await prisma.admin.count();
  if (adminCount === 0) {
    await prisma.admin.create({
      data: {
        name: 'Admin',
        email: 'admin@gmail.com',
        passwordHash: await bcrypt.hash('1234', 10),
      },
    });
    console.log('Seeded bootstrap admin account (admin@gmail.com / 1234).');
  }

  console.log(`Seeded ${workshopOptions.length} workshop options and ${levelOptions.length} level options.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
