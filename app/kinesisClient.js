import { KinesisClient } from '@aws-sdk/client-kinesis';
import dotenv from 'dotenv';
dotenv.config();

const kinesis = new KinesisClient({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

export default kinesis;
