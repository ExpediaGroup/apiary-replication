/**
 * Copyright (C) 2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

variable "instance_name" {
  description = "Shunting Yard instance name to identify resources in multi-instance deployments."
  type        = "string"
  default     = ""
}

variable "aws_region" {
  description = "AWS region to use for resources."
  type        = "string"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = "string"
}

variable "subnets" {
  description = "ECS container subnets."
  type        = "list"
}

# Tags
variable "shuntingyard_tags" {
  description = "A map of tags to apply to resources."
  type        = "map"
}

variable "memory" {
  description = <<EOF
The amount of memory (in MiB) used to allocate for the Shunting Yard container.
Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = "string"
  default = "4096"
}

variable "cpu" {
  description = <<EOF
The number of CPU units to reserve for the Shunting Yard container.
Valid values can be 256, 512, 1024, 2048 and 4096.
Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = "string"
  default = "1024"
}

variable "docker_image" {
  description = "Full path of Shunting Yard Docker image."
  type        = "string"
}

variable "docker_version" {
  description = "Shunting Yard Docker image version."
  type        = "string"
}

variable "ct_common_config_yaml" {
  description = "Common Circus Train configuration to be passed to internal Circus Train instance. It can be used, for example to configure Graphite for Circus Train. Refer to [Circus Train README](https://github.com/HotelsDotCom/circus-train/blob/master/README.md) for an exhaustive list of options supported by Circus Train."
  type        = "string"
}

variable "ct_log4j_xml" {
  description = "Log4j XML file to be passed to internal Circus Train instance to configure logging."
  type        = "string"
}

variable "allowed_s3_buckets" {
  description = "List of S3 Buckets to which Shunting Yard will have read-write access."
  type        = "list"
}

variable "source_metastore_uri" {
  description = "Source Metastore URI for Shunting Yard."
  type        = "string"
}

variable "target_metastore_uri" {
  description = "Target Metastore URI for Shunting Yard."
  type        = "string"
}

variable "metastore_events_sns_topic" {
  description = "SNS Topic for Hive Metastore events."
  type        = "string"
}

variable "shuntingyard_sqs_queue_wait_timeout" {
  description = "Wait timeout for connecting to the Shunting Yard SQS queue (in seconds)"
  type        = "string"
  default     = 15
}

variable "shuntingyard_sqs_queue_stale_messages_timeout" {
  description = "Shunting Yard SQS Queue Cloudwatch Alert timeout for messages older than this number of seconds."
  type        = "string"
  default     = 300
}

variable "selected_tables" {
  description = <<EOF
Tables selected for Shunting Yard Replication.
Supported Format: [ "database_1.table_1", "database_2.table_2" ]
Wildcards are not supported, i.e. you need to specify each table explicitly.
EOF

  type    = "list"
  default = []
}

variable "orphaned_data_strategy" {
  description = <<EOF
Orphaned data strategy to use for stale data during replication. Supported strategies: "NONE", "HOUSEKEEPING" (default).
EOF

  type    = "string"
  default = "HOUSEKEEPING"
}

variable "docker_registry_auth_secret_name" {
  description = "Docker Registry authentication SecretManager secret name."
  type        = "string"
  default     = ""
}
