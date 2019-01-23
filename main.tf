/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_sqs_queue" "shuntingyard_sqs_queue" {
   name = "${local.instance_alias}-sqs-queue"
}

resource "aws_sns_topic_subscription" "sqs_hive_metastore_sns_subscription" {
  topic_arn = "${var.metastore_events_sns_topic}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.shuntingyard_sqs_queue.arn}"
}

resource "aws_ecs_cluster" "shuntingyard" {
  name = "${local.instance_alias}"
}

resource "aws_iam_role" "shuntingyard_task_exec" {
  name = "${local.instance_alias}-ecs-task-exec-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task_exec_managed" {
  role       = "${aws_iam_role.shuntingyard_task_exec.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "shuntingyard_task" {
  name = "${local.instance_alias}-ecs-task-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# resource "aws_iam_role_policy_attachment" "task_managed" {
#   role       = "${aws_iam_role.shuntingyard_task.id}"
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }

resource "aws_iam_role_policy" "s3_for_shuntingyard" {
  name  = "s3"
  role  = "${aws_iam_role.shuntingyard_task.id}"

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
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "sqs_for_shuntingyard" {
  name  = "sqs"
  role  = "${aws_iam_role.shuntingyard_task.id}"

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
        "Resource": "*"
    }
}
EOF
}

resource "aws_cloudwatch_log_group" "shuntingyard_ecs" {
  name = "${local.instance_alias}"
  tags = "${var.tags}"
}

data "template_file" "shuntingyard_config_yaml" {
  template = "${file("${path.module}/templates/shunting-yard-config.yml.tmpl")}"

  vars {
    source_metastore_uri      = "${var.source_metastore_uri}"
    target_metastore_uri      = "${var.target_metastore_uri}"
    shunting_yard_sqs_queue   = "${aws_sqs_queue.shuntingyard_sqs_queue.id}"
    selected_tables           = "${var.selected_tables}"
  }
}

data "template_file" "shuntingyard" {
  template = "${file("${path.module}/templates/shuntingyard.json")}"

  vars {
    heapsize            = "${var.memory}"
    docker_image        = "${var.docker_image}"
    docker_version      = "${var.docker_version}"
    region              = "${var.aws_region}"
    loggroup            = "${aws_cloudwatch_log_group.shuntingyard_ecs.name}"
    shuntingyard_config_yaml   = "${base64encode(data.template_file.shuntingyard_config_yaml.rendered)}"
  }
}

resource "aws_ecs_task_definition" "shuntingyard" {
  family                   = "${local.instance_alias}"
  task_role_arn            = "${aws_iam_role.shuntingyard_task.arn}"
  execution_role_arn       = "${aws_iam_role.shuntingyard_task_exec.arn}"
  network_mode             = "awsvpc"
  memory                   = "${var.memory}"
  cpu                      = "${var.cpu}"
  requires_compatibilities = ["EC2", "FARGATE"]
  container_definitions    = "${data.template_file.shuntingyard.rendered}"
}

resource "aws_security_group" "sy_sg" {
  name   = "${local.instance_alias}-sg"
  vpc_id = "${var.vpc_id}"
  tags   = "${var.tags}"

  ingress {
    from_port   = 48869
    to_port     = 48869
    protocol    = "tcp"
    cidr_blocks = "${var.ingress_cidr}"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_vpc.shuntingyard_vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "shuntingyard_service" {
  name            = "${local.instance_alias}-service"
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.shuntingyard.id}"
  task_definition = "${aws_ecs_task_definition.shuntingyard.arn}"
  desired_count   = "${var.sy_ecs_task_count}"

  network_configuration {
    security_groups = ["${aws_security_group.sy_sg.id}"]
    subnets         = ["${var.subnets}"]
  }
}
