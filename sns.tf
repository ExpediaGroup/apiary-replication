/**
 * Copyright (C) 2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_sns_topic" "shuntingyard_ops_sns" {
  name = "${local.instance_alias}-operational-events"
}

resource "aws_sns_topic_subscription" "sqs_hive_metastore_sns_subscription" {
  topic_arn = "${var.metastore_events_sns_topic}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.shuntingyard_sqs_queue.arn}"
}
