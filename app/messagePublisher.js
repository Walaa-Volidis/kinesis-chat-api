import kinesis from './kinesisClient.js';
import { PutRecordCommand } from '@aws-sdk/client-kinesis';
import { v4 as uuidv4 } from 'uuid';

const STREAM_NAME = process.env.KINESIS_STREAM_NAME;

export async function publishMessage({ sender, message }) {
  const data = {
    id: uuidv4(),
    timestamp: new Date().toISOString(),
    sender,
    message,
  };

  const params = {
    StreamName: STREAM_NAME,
    PartitionKey: sender,
    Data: Buffer.from(JSON.stringify(data)),
  };

  const command = new PutRecordCommand(params);
  const result = await kinesis.send(command);
  return { ...data, kinesisResult: result };
}
