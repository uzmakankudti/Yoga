import 'dotenv/config';
import cors from 'cors';
import express from 'express';
import { env } from './config/env';
import { errorHandler } from './middleware/errorHandler';
import { authRouter } from './routes/auth';
import { trainerRouter } from './routes/trainer';
import { studentRouter } from './routes/student';
import { configRouter } from './routes/config';
import { adminRouter } from './routes/admin';

const app = express();

app.use(cors());
app.use(express.json());

app.get('/api/health', (_req, res) => res.json({ status: 'ok' }));

app.use('/api/auth', authRouter);
app.use('/api/trainer', trainerRouter);
app.use('/api/student', studentRouter);
app.use('/api/config', configRouter);
app.use('/api/admin', adminRouter);

app.use(errorHandler);

app.listen(env.port, () => {
  console.log(`YPV backend listening on http://localhost:${env.port}`);
});
