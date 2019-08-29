/**
 * Copyright (C) 2019 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role_policy" "s3_for_shuntingyard" {
  name = "s3"
  role = "${aws_iam_role.shuntingyard_task.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:DeleteObjectVersion",
                "s3:Get*",
                "s3:List*",
                "s3:PutBucketLogging",
                "s3:PutBucketNotification",
                "s3:PutBucketVersioning",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:PutObjectTagging",
                "s3:PutObjectVersionAcl",
                "s3:PutObjectVersionTagging"
            ],
            "Resource": [
                          "${join("\",\"", formatlist("arn:aws:s3:::%s",var.allowed_s3_buckets))}",
                          "${join("\",\"", formatlist("arn:aws:s3:::%s/*",var.allowed_s3_buckets))}"
                        ]
        }
    ]
}
EOF
}
