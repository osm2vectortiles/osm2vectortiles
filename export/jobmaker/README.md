## SQS

The AWS SQS Queue needs to be created manually before hand.
Create an IAM user with the following policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1445369143000",
            "Effect": "Allow",
            "Action": [
                "sqs:ChangeMessageVisibility",
                "sqs:DeleteMessage",
                "sqs:ReceiveMessage",
                "sqs:SendMessage",
                "sqs:GetQueueUrl",
                "sqs:GetQueueAttributes"
            ],
            "Resource": [
                "arn:aws:sqs:eu-central-1:875198274136:osm2vectortiles_jobs"
            ]
        }
    ]
}
```

Now specify the queue name, the zone and access key with secret
for the job process.

| Env                     | Default               | Description             |
|-------------------------|-----------------------|-------------------------|
| `AWS_REGION`            | `eu-central-1`        | Region of SQS queue     |
| `AWS_ACCESS_KEY`        | ``                    | Public access key       |
| `AWS_SECRET_ACCESS_KEY` | ``                    | Secret access key       |
| `TASK_ZOOM_LEVEL`       | `8`                   | Zoom level of tasks     |
| `QUEUE_NAME`            | `osm2vectortiles_jobs`| Name of SQS queue       |
