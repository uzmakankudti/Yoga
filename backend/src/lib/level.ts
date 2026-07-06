const WORKSHOP_TO_LEVEL: Record<string, string> = {
  'Yoga Level 1': 'Level 1',
  'Yoga Level 2': 'Level 2',
  'Yoga Level 3': 'Level 3',
  'AUWA Foundation': 'AUWA',
  'Crystal/PSP Course': 'Crystal/PSP',
  'HDP Level 1': 'HDP1',
};

export function deriveLevelFromWorkshop(workshopName: string, fallback = 'Level 1'): string {
  return WORKSHOP_TO_LEVEL[workshopName] ?? fallback;
}

const NEXT_LEVEL: Record<string, string> = {
  'Level 1': 'Level 2',
  'Level 2': 'Level 3',
};

/**
 * Tiered trainer upgrade permissions:
 * - T1 ("Level 1" trainer): can never upgrade a student.
 * - T2 ("Level 2" trainer): only Level 1 -> Level 2.
 * - T3 ("Level 3" trainer): only Level 1 -> Level 2 or Level 2 -> Level 3.
 * - Any other trainer level (AUWA/Crystal-PSP/HDP1/Arhat Trainer): unrestricted.
 */
export function canUpgrade(
  trainerLevel: string,
  studentCurrentLevel: string,
  targetLevel: string,
): { allowed: boolean; reason?: string } {
  if (trainerLevel === 'Level 1') {
    return { allowed: false, reason: 'T1 trainers cannot upgrade student levels' };
  }
  if (trainerLevel === 'Level 2') {
    if (studentCurrentLevel === 'Level 1' && targetLevel === 'Level 2') return { allowed: true };
    return { allowed: false, reason: 'T2 trainers can only upgrade Level 1 students to Level 2' };
  }
  if (trainerLevel === 'Level 3') {
    if (NEXT_LEVEL[studentCurrentLevel] === targetLevel) return { allowed: true };
    return { allowed: false, reason: 'T3 trainers can only upgrade Level 1→Level 2 or Level 2→Level 3 students' };
  }
  return { allowed: true };
}
