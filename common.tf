/**
 * Copyright (C) 2019 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias = "${ var.instance_name == "" ? "shuntingyard" : format("shuntingyard-%s",var.instance_name) }"
}

data "aws_vpc" "shuntingyard_vpc" {
  id = "${var.vpc_id}"
}

data "aws_secretsmanager_secret" "docker_registry" {
  count = "${var.docker_registry_auth_secret_name == "" ? 0 : 1}"
  name  = "${var.docker_registry_auth_secret_name}"
}
