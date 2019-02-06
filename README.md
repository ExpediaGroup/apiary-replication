
# Overview

Terraform module for setting up infrastructure for [Shunting Yard](https://github.com/HotelsDotCom/shunting-yard).

For more information please refer to the main [Apiary](https://github.com/ExpediaInc/apiary) project page.

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_s3\_buckets | List of S3 Buckets to which SY will have read-write access. | list | n/a | yes |
| aws\_region | AWS region to use for resources. | string | n/a | yes |
| cpu | The number of CPU units to reserve for the Shunting Yard container. Valid values can be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `"1024"` | no |
| docker\_image | Full path of Shunting Yard Docker image. | string | n/a | yes |
| docker\_version | Shunting Yard Docker image version. | string | n/a | yes |
| graphite\_host | Graphite server configured in Shunting Yard to send metrics to. | string | `"localhost"` | no |
| graphite\_namespace | Namespace for all metrics sent to Graphite from this Shunting Yard instance. | string | `"com.hotels"` | no |
| graphite\_port | Graphite server port. | string | `"2003"` | no |
| graphite\_prefix | Prefix addded to all metrics sent to Graphite from this Shunting Yard instance. | string | `"shuntingyard"` | no |
| instance\_name | Shunting Yard instance name to identify resources in multi-instance deployments. | string | `""` | no |
| memory | The amount of memory (in MiB) used to allocate for the Shunting Yard container. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `"4096"` | no |
| metastore\_events\_sns\_topic | SNS Topic for Hive Metastore events. | string | n/a | yes |
| selected\_tables | Tables selected for Shunting Yard Replication. | string | n/a | yes |
| source\_metastore\_uri | Source Metastore URI for Shunting Yard. | string | n/a | yes |
| subnets | ECS container subnets. | list | n/a | yes |
| tags | A map of tags to apply to resources. | map | `<map>` | no |
| target\_metastore\_uri | Target Metastore URI for Shunting Yard. | string | n/a | yes |
| vpc\_id | VPC ID. | string | n/a | yes |

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
