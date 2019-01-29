
# Overview

Terraform module for setting up infrastructure for [Shunting Yard](https://github.com/HotelsDotCom/shunting-yard).

For more information please refer to the main [Apiary](https://github.com/ExpediaInc/apiary) project page.

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_region | AWS region to use for resources. | string | - | yes |
| cpu | The number of CPU units to reserve for the Shunting Yard container. Valid values can be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `1024` | no |
| memory | The amount of memory (in MiB) used to allocate for the Shunting Yard container. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `4096` | no |
| docker_image | Full path to Shunting Yard Docker image. | string | - | yes |
| docker_version | Shunting Yard Docker image version. | string | - | yes |
| allowed_s3_buckets | List of S3 Buckets to which Shunting Yard will have read-write access. eg. `["bucket-1", "bucket-2"]` | list | `<list>` | no |
| instance_name | Shunting Yard instance name to identify resources in multi-instance deployments. | string | `` | no |
| subnets | ECS container subnets. | list | - | yes |
| tags | A map of tags to apply to resources. | map | `<map>` | no |
| vpc_id | VPC ID. | string | - | yes |
| source_metastore_uri | Source Metastore URI for Shunting Yard. | string | - | yes |
| target_metastore_uri | Target Metastore URI for Shunting Yard. | string | - | yes |
| metastore_events_sns_topic | SNS Topic for Hive Metastore events. | string | - | yes |
| selected_tables | Tables selected for Shunting Yard Replication. Supported Format: `database_1.table_1, database_2.table_2` | string | - | yes |

## Usage

Example module invocation:
```
module "apiary-shuntingyard" {
  source             = "git::https://github.com/ExpediaInc/apiary-replication.git?ref=master"
  instance_name      = "shuntingyard-test"
  aws_region         = "us-west-2"
  vpc_id             = "vpc-1"
  subnets            = ["subnet-1", "subnet-2"]
  allowed_s3_buckets = ["bucket-1", "bucket-2"]

  tags = {
    Name = "Apiary-Shuntingyard"
    Team = "Operations"
  }

  source_metastore_uri               = "thrift://ip-address:9083"
  target_metastore_uri               = "thrift://ip-address:9083"
  metastore_events_sns_topic         = "arn:aws:sns:us-west-2:1234567:metastore-events-sns-topic"
  selected_tables                    = "database_1.table_1, database_2.table_2"

  docker_image                       = "your.docker.repo/apiary-shuntingyard"
  docker_version                     = "latest"
}
```

# Contact

## Mailing List
If you would like to ask any questions about or discuss Apiary please join our mailing list at

  [https://groups.google.com/forum/#!forum/apiary-user](https://groups.google.com/forum/#!forum/apiary-user)

# Legal
This project is available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).

Copyright 2019 Expedia Inc.
