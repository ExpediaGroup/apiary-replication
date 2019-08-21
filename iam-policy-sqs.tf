/**
 * Copyright (C) 2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role_policy" "sqs_for_shuntingyard" {
  name = "sqs"
  role = "${aws_iam_role.shuntingyard_task.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ],
        "Resource": "${aws_sqs_queue.shuntingyard_sqs_queue.arn}"
    }
}
EOF
}
