/**
 * Copyright (C) 2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role_policy" "secretsmanager_for_ecs_task_exec" {
  count = "${var.docker_registry_auth_secret_name != "" ? 1 : 0}"
  name  = "secretsmanager-exec"
  role  = "${aws_iam_role.shuntingyard_task_exec.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": [ "${join("\",\"", concat(data.aws_secretsmanager_secret.docker_registry.*.arn))}" ]
    }
}
EOF
}
