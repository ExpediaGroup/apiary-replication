/**
 * Copyright (C) 2019 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_sqs_queue" "shuntingyard_sqs_queue" {
  name = "${local.instance_alias}-sqs-queue"
}

resource "aws_sqs_queue_policy" "shuntingyard_sqs_queue_policy" {
  queue_url = "${aws_sqs_queue.shuntingyard_sqs_queue.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "AllowSNSSendMessage",
  "Statement": [
    {
      "Sid": "Allow Apiary Metadata Events",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.shuntingyard_sqs_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${var.metastore_events_sns_topic}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "sqs_hive_metastore_sns_subscription" {
  topic_arn = "${var.metastore_events_sns_topic}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.shuntingyard_sqs_queue.arn}"
}
