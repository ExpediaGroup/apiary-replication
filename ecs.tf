/**
 * Copyright (C) 2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_ecs_cluster" "shuntingyard" {
  name = "${local.instance_alias}"
  tags = "${var.shuntingyard_tags}"
}

resource "aws_cloudwatch_log_group" "shuntingyard_ecs" {
  name = "${local.instance_alias}"
  tags = "${var.shuntingyard_tags}"
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
  tags                     = "${var.shuntingyard_tags}"
}

resource "aws_ecs_service" "shuntingyard_service" {
  name            = "${local.instance_alias}-service"
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.shuntingyard.id}"
  task_definition = "${aws_ecs_task_definition.shuntingyard.arn}"
  desired_count   = "1"

  network_configuration {
    security_groups = ["${aws_security_group.shuntingyard_sg.id}"]
    subnets         = ["${var.subnets}"]
  }
}
