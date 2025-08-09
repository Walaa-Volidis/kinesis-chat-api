import kinesis from './kinesisClient.js';
import { PutRecordCommand } from '@aws-sdk/client-kinesis';
import { v4 as uuidv4 } from 'uuid';
import { createHash } from 'crypto';

const STREAM_NAME = process.env.KINESIS_STREAM_NAME;

function createPartitionKey(sender, messageId) {
  return createHash('md5')
    .update(`${sender}-${messageId}`)
    .digest('hex')
    .substring(0, 16);
}

export async function publishMessage({ sender, message }) {
  const data = {
    id: uuidv4(),
    timestamp: new Date().toISOString(),
    sender,
    message,
  };

  const params = {
    StreamName: STREAM_NAME,
    PartitionKey: createPartitionKey(sender, data.id),
    Data: JSON.stringify(data),
  };

  const command = new PutRecordCommand(params);
  const result = kinesis
    .send(command)
    .catch((err) => console.error('Kinesis publish failed:', err));
  return { ...data, kinesisResult: result };
}
