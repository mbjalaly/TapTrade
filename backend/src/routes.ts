import { Router } from 'express';
import taptradeRoutes from './routes/taptrade';

const router = Router();

router.use(taptradeRoutes);

export default router;

