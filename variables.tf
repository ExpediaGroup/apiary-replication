/**
 * Copyright (C) 2019 Expedia Inc.
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

variable "graphite_host" {
  description = "Graphite server configured in Shunting Yard to send metrics to."
  type        = "string"
  default     = "localhost"
}

variable "graphite_port" {
  description = "Graphite server port."
  type        = "string"
  default     = "2003"
}

variable "graphite_namespace" {
  description = "Namespace for all metrics sent to Graphite from this Shunting Yard instance."
  type        = "string"
  default     = "com.hotels"
}

variable "graphite_prefix" {
  description = "Prefix addded to all metrics sent to Graphite from this Shunting Yard instance."
  type        = "string"
  default     = "shuntingyard"
}

variable "allowed_s3_buckets" {
  description = "List of S3 Buckets to which SY will have read-write access."
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

variable "selected_tables" {
  description = "Tables selected for Shunting Yard Replication."
  type        = "string"
}
