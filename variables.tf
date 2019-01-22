/**
 * Copyright (C) 2018 Expedia Inc.
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

variable "sy_ecs_task_count" {
  description = "Number of ECS tasks to create."
  type        = "string"
  default     = "1"
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
variable "tags" {
  description = "A map of tags to apply to resources."
  type        = "map"

  default = {
    Environment = ""
    Application = ""
    Team        = ""
  }
}

variable "memory" {
  description = <<EOF
The amount of memory (in MiB) used to allocate for the Waggle Dance container.
Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = "string"
  default = "4096"
}

variable "cpu" {
  description = <<EOF
The number of CPU units to reserve for the Waggle Dance container.
Valid values can be 256, 512, 1024, 2048 and 4096.
Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = "string"
  default = "1024"
}

variable "ingress_cidr" {
  description = "Generally allowed ingress CIDR list."
  type        = "list"
}

variable "docker_image" {
  description = "Full path Waggle Dance Docker image."
  type        = "string"
}

variable "docker_version" {
  description = "Waggle Dance Docker image version."
  type        = "string"
}

variable "source_metastore_uri" {
  description = "Source Metastore URI for Shunting Yard"
  type        = "string"
}

variable "target_metastore_uri" {
  description = "Target for Shunting Yard"
  type        = "string"
}

variable "shunting_yard_sqs_queue" {
  description = "SQS Queue for reading events"
  type        = "string"
}

variable "metastore_events_sns_topic" {
  description = "SNS Topic for Hive Metastore events"
  type        = "string"
}

variable "selected_tables" {
  description = "Tables selected for Shunting Yard Replication"
  type        = "string"
}
