/**
 * Copyright (C) 2019 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "template_file" "shuntingyard_config_yaml" {
  template = "${file("${path.module}/templates/shuntingyard-config.yml.tmpl")}"

  vars {
    source_metastore_uri                = "${var.source_metastore_uri}"
    target_metastore_uri                = "${var.target_metastore_uri}"
    shuntingyard_sqs_queue              = "${aws_sqs_queue.shuntingyard_sqs_queue.id}"
    shuntingyard_sqs_queue_wait_timeout = "${var.shuntingyard_sqs_queue_wait_timeout}"
    selected_tables                     = "${join("\n", formatlist("    - %s", var.selected_tables))}"
    orphaned_data_strategy              = "${format("orphaned-data-strategy: %s", var.orphaned_data_strategy)}"
  }
}

data "template_file" "shuntingyard" {
  template = "${file("${path.module}/templates/shuntingyard.json")}"

  vars {
    heapsize                 = "${var.memory}"
    docker_image             = "${var.docker_image}"
    docker_version           = "${var.docker_version}"
    region                   = "${var.aws_region}"
    loggroup                 = "${aws_cloudwatch_log_group.shuntingyard_ecs.name}"
    shuntingyard_config_yaml = "${base64encode(data.template_file.shuntingyard_config_yaml.rendered)}"
    ct_common_config_yaml    = "${base64encode(var.ct_common_config_yaml)}"

    #to instruct ECS to use repositoryCredentials for private docker registry
    docker_auth = "${var.docker_registry_auth_secret_name == "" ? "" : format("\"repositoryCredentials\" :{\n \"credentialsParameter\":\"%s\"\n},", join("", data.aws_secretsmanager_secret.docker_registry.*.arn))}"
  }
}
