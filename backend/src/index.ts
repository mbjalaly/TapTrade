import dotenv from 'dotenv';
dotenv.config();

import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import routes from './routes';
import { startInactivityCron } from './services/inactivityCron';

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(morgan('dev'));

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.use(routes);

const port = Number(process.env.PORT || 3001);
app.listen(port, () => {
  console.log(`TapTrade API listening on http://localhost:${port}`);
  startInactivityCron();
});

