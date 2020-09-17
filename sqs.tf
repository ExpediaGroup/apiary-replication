/**
 * Copyright (C) 2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_sqs_queue" "shuntingyard_sqs_queue" {
  name = "${local.instance_alias}-sqs-queue"

  tags = "${var.shuntingyard_tags}"
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

# default filter
data "template_file" "sqs_hive_metastore_sns_subscription_filter" {
  count  = "${length(var.exclude_event_list) == 0 ? 1 : 0}"
  template = <<EOF
  {
    "qualifiedTableName": [ $${tables_list} ]
  }
EOF

  vars {
    tables_list = "${join(",", formatlist("\"%s\"", var.selected_tables))}"
  }
}

resource "aws_sns_topic_subscription" "sqs_hive_metastore_sns_subscription" {
  count  = "${length(var.exclude_event_list) == 0 ? 1 : 0}"
  topic_arn     = "${var.metastore_events_sns_topic}"
  protocol      = "sqs"
  endpoint      = "${aws_sqs_queue.shuntingyard_sqs_queue.arn}"
  filter_policy = "${join("", data.template_file.sqs_hive_metastore_sns_subscription_filter.*.rendered)}"
}

# filter with metastore event type 
data "template_file" "sqs_hive_metastore_sns_subscription_event_filter" {
  count  = "${length(var.exclude_event_list) != 0 ? 1 : 0}"
  template = <<EOF
  {
    "qualifiedTableName": [ $${tables_list} ],
    "eventType": [
        {
          "anything-but": [ $${event_list} ]
        }
      ]
  }
EOF

  vars {
    tables_list = "${join(",", formatlist("\"%s\"", var.selected_tables))}"
  }
  vars {
    event_list = "${join(",", formatlist("\"%s\"", var.exclude_event_list))}"
  }
}


resource "aws_sns_topic_subscription" "sqs_hive_metastore_sns_event_filter_subscription" {
  count  = "${length(var.exclude_event_list) != 0 ? 1 : 0}"
  topic_arn     = "${var.metastore_events_sns_topic}"
  protocol      = "sqs"
  endpoint      = "${aws_sqs_queue.shuntingyard_sqs_queue.arn}"
  filter_policy = "${join("", data.template_file.sqs_hive_metastore_sns_subscription_event_filter.*.rendered)}"
}
