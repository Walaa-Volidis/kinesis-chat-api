import express from 'express';
import { publishMessage } from '../app/messagePublisher.js';

const router = express.Router();

router.post('/send', async (req, res) => {
  const { sender, message } = req.body;

  if (!sender || !message) {
    return res
      .status(400)
      .json({ error: 'Both sender and message are required' });
  }

  try {
    const result = await publishMessage({ sender, message });
    res.json({ message: 'Message sent to Kinesis', data: result });
  } catch (err) {
    console.error('Error sending message:', err);
    res.status(500).json({ error: 'Failed to send message' });
  }
});

export default router;
