
# Overview

Terraform module for setting up infrastructure for [Shunting Yard](https://github.com/HotelsDotCom/shunting-yard).

For more information please refer to the main [Apiary](https://github.com/ExpediaInc/apiary) project page.

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_s3\_buckets | List of S3 Buckets to which Shunting Yard will have read-write access. eg. `["bucket-1", "bucket-2"]`. | list | `n/a` | yes |
| aws\_region | AWS region to use for resources. | string | n/a | yes |
| cpu | The number of CPU units to reserve for the Shunting Yard container. Valid values can be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `"1024"` | no |
| ct\_common\_config\_yaml | Common Circus Train configuration to be passed to internal Circus Train instance. It can be used, for example to configure Graphite for Circus Train. Refer to [Circus Train README](https://github.com/HotelsDotCom/circus-train/blob/master/README.md) for an exhaustive list of options supported by Circus Train. | string | n/a | yes |
| docker\_image | Full path of Shunting Yard Docker image. | string | n/a | yes |
| docker\_version | Shunting Yard Docker image version. | string | n/a | yes |
| docker\_registry\_auth\_secret\_name | Docker Registry authentication SecretManager secret name. | string | `` | no |
| instance\_name | Shunting Yard instance name to identify resources in multi-instance deployments. | string | `""` | no |
| memory | The amount of memory (in MiB) allocated to the Shunting Yard container. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `"4096"` | no |
| metastore\_events\_sns\_topic | SNS Topic for Hive Metastore events. | string | n/a | yes |
| shuntingyard_sqs_queue_wait_timeout | Shunting Yard SQS queue wait timeout | string | 15 | no |
| shuntingyard_sqs_queue_stale_messages_timeout | Shunting Yard SQS queue stale messages alert timeout | string | 300 | no |
| selected\_tables | Tables selected for Shunting Yard Replication. Supported Format: `[ "database_1.table_1", "database_2.table_2" ]` | list | [] | no |
| source\_metastore\_uri | Source Metastore URI for Shunting Yard. | string | n/a | yes |
| subnets | ECS container subnets. | list | n/a | yes |
| shuntingyard_tags | A map of tags to apply to resources. | map | `<map>` | no |
| target\_metastore\_uri | Target Metastore URI for Shunting Yard. | string | n/a | yes |
| vpc\_id | VPC ID. | string | n/a | yes |

## Usage

Example module invocation:
```
module "apiary-shuntingyard" {
  source                      = "git::https://github.com/ExpediaInc/apiary-replication.git"
  aws_region                  = "us-west-2"
  vpc_id                      = "vpc-1"
  subnets                     = ["subnet-1", "subnet-2"]
  instance_name               = "shuntingyard-test"
  docker_image                = "your.docker.repo/apiary-shuntingyard"
  docker_version              = "latest"
  ct_common_config_yaml       = "${data.template_file.ct_common_config_yaml.rendered}"  
  source_metastore_uri        = "thrift://ip-address:9083"
  target_metastore_uri        = "thrift://ip-address:9083"
  metastore_events_sns_topic  = "arn:aws:sns:us-west-2:1234567:metastore-events-sns-topic"
  selected_tables             = [ "database_1.table_1", "database_2.table_2" ]
  allowed_s3_buckets          = [ "bucket-1", "bucket-2" ]
  shuntingyard_tags           = "${var.tags}" 
}
```

Please note that the parameter `ct_common_config_yaml` takes in the contents of the ct-common-config.yml file and should be passed in the manner described above using templates.

# Contact

## Mailing List
If you would like to ask any questions about or discuss Apiary please join our mailing list at

  [https://groups.google.com/forum/#!forum/apiary-user](https://groups.google.com/forum/#!forum/apiary-user)

# Legal
This project is available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).

Copyright 2019 Expedia Inc.
