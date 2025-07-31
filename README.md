# Kinesis Chat API

A Node.js REST API that streams chat messages to AWS Kinesis Data Streams, triggering Lambda functions for real-time message processing.

## 🚀 Features

- **Real-time Message Streaming**: Send chat messages to AWS Kinesis Data Streams
- **Lambda Integration**: Kinesis events automatically trigger AWS Lambda functions
- **RESTful API**: Simple HTTP endpoints for message publishing
- **ES6 Modules**: Modern JavaScript with ES modules support
- **Environment Configuration**: Secure credential management with dotenv

## 🏗️ Architecture

```
Client → REST API → AWS Kinesis → Lambda Function → Processing/Storage

```

1. **REST API**: Receives chat messages via HTTP POST
2. **Kinesis Stream**: Buffers and streams messages in real-time
3. **Lambda Trigger**: Automatically processes incoming stream records
4. **Downstream Processing**: Handle messages for storage, notifications, etc.

<img width="1281" height="545" alt="image" src="https://github.com/user-attachments/assets/dc10cced-cb81-4370-8e4d-9aa551da739c" />

## 📋 Prerequisites

- Node.js 18+
- AWS Account with Kinesis and Lambda access
- AWS IAM user with `kinesis:PutRecord` permissions

## 🛠️ Installation

1. Clone the repository:

```bash
git clone https://github.com/walaa-volidis/kinesis-chat-api.git
cd kinesis-chat-api
```

2. Install dependencies:

```bash
npm install
```

3. Configure environment variables:

```bash
cp .env.example .env
# Edit .env with your AWS credentials and stream details
```

4. Start the server:

```bash
npm start
```

## ⚙️ Configuration

Create a `.env` file with the following variables:

```env
AWS_REGION=us-east-2
KINESIS_STREAM_NAME=chat-message-stream
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
PORT=3000
```

## 📡 API Endpoints

### Send Message

```http
POST /api/send
Content-Type: application/json

{
  "sender": "username",
  "message": "Hello, world!"
}
```

**Response:**

```json
{
  "message": "Message sent to Kinesis",
  "data": {
    "ShardId": "shardId-000000000000",
    "SequenceNumber": "49642..."
  }
}
```

## 🧪 Testing

Test the API with curl:

```bash

# Using PowerShell
Invoke-WebRequest -Uri "http://localhost:3000/api/send" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"sender":"walaa","message":"Hello from Walaa!"}'
```

## 🔧 AWS Setup

### 1. Create Kinesis Stream

```bash
aws kinesis create-stream --stream-name chat-message-stream --shard-count 1
```

### 2. Create Lambda Function

Set up a Lambda function to process Kinesis records:

### 3. Configure Lambda Trigger

Add the Kinesis stream as a trigger for your Lambda function.

### 4. Lambda Execution Role Policy

When setting up your Lambda function to process Kinesis events, ensure the Lambda execution role has the following IAM policy attached:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:*:YOUR_ACCOUNT_ID:*"
    },
    {
      "Effect": "Allow",
      "Action": ["logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource": [
        "arn:aws:logs:*:YOUR_ACCOUNT_ID:log-group:/aws/lambda/YOUR_LAMBDA_FUNCTION_NAME:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:DescribeStream",
        "kinesis:DescribeStreamSummary",
        "kinesis:ListShards",
        "kinesis:ListStreams"
      ],
      "Resource": "arn:aws:kinesis:*:YOUR_ACCOUNT_ID:stream/chat-message-stream"
    }
  ]
}
```

> **Note**: Replace `YOUR_ACCOUNT_ID` with your actual AWS account ID and `YOUR_LAMBDA_FUNCTION_NAME` with your Lambda function name.

## 🔐 IAM Permissions

Required IAM policy for the API user:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["kinesis:PutRecord", "kinesis:PutRecords"],
      "Resource": "arn:aws:kinesis:*:*:stream/chat-message-stream"
    }
  ]
}
```

## 🔗 Related

- [AWS Kinesis Documentation](https://docs.aws.amazon.com/kinesis/)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [AWS SDK for JavaScript](https://docs.aws.amazon.com/sdk-for-javascript/)
