// Simple Lambda function to consume and print Kinesis data
export const handler = async (event) => {
  console.log('Kinesis Lambda triggered!');
  console.log(`Received ${event.Records.length} records`);

  try {
    for (let i = 0; i < event.Records.length; i++) {
      const record = event.Records[i];
      console.log('Record Info:', {
        sequenceNumber: record.kinesis.sequenceNumber,
        partitionKey: record.kinesis.partitionKey,
        timestamp: new Date(
          record.kinesis.approximateArrivalTimestamp * 1000
        ).toISOString(),
      });

      const rawData = record.kinesis.data;
      console.log('Raw Data:', rawData);

      try {
        const jsonData = JSON.parse(rawData);
        console.log('Parsed JSON Data:', JSON.stringify(jsonData, null, 2));

        if (jsonData.sender && jsonData.message) {
          console.log(
            `Chat: ${jsonData.sender} says: "${jsonData.message}"`
          );
        }
      } catch (parseError) {
        console.log('Data is not valid JSON, treating as plain text');
      }
    }

    console.log(
      `\nSuccessfully processed all ${event.Records.length} records`
    );

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: `Successfully processed ${event.Records.length} records`,
        timestamp: new Date().toISOString(),
      }),
    };
  } catch (error) {
    console.error('Error processing Kinesis records:', error);

    return {
      statusCode: 500,
      body: JSON.stringify({
        error: 'Failed to process Kinesis records',
        details: error.message,
      }),
    };
  }
};
