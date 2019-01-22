/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias = "${ var.instance_name == "" ? "shuntingyard" : format("shuntingyard-%s",var.instance_name) }"
}

data "aws_vpc" "shuntingyard_vpc" {
  id = "${var.vpc_id}"
}
