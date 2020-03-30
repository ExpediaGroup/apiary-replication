resource "aws_s3_bucket_object" "master_config" {
  bucket  = "${var.master-config-s3-bucket}"
  key     = "${var.master-config-s3-key}/cloverleaf_master_config.yml"
  content = "${var.cloverleaf-master-config}"
  etag    = "${md5("${var.cloverleaf-master-config}")}"
}

locals {
  # TODO: read artifact from a bucket in EGDL
  default-cloverleaf-lambda-bucket     = "hcom-data-lab-shared-us-east-1"
  default-cloverleaf-lambda-jar-s3-key = "artifacts/release/com/hotels/bdp/cloverleaf-lambda/${var.cloverleaf-lambda-version}"
  default-cloverleaf-steps-jar-s3-key  = "artifacts/release/com/hotels/bdp/cloverleaf-steps/${var.cloverleaf-lambda-version}"
}

resource "aws_lambda_function" "cloverleaf_fn" {
  s3_bucket     = "${coalesce(var.cloverleaf-lambda-bucket, local.default-cloverleaf-lambda-bucket)}"
  s3_key        = "${coalesce(var.cloverleaf-jars-s3-key, local.default-cloverleaf-lambda-jar-s3-key)}/cloverleaf-lambda-${var.cloverleaf-lambda-version}.jar"
  function_name = "${var.instance_name}-fn"
  role          = "${aws_iam_role.cloverleaf-lambda.arn}"
  handler       = "com.hotels.bdp.cloverleaf.ApiaryMetastoreEventPartitionHandler::handleRequest"
  runtime       = "java8"
  memory_size   = "512"
  timeout       = "60"
  publish       = true
  reserved_concurrent_executions = 1
  tags          = "${var.tags}"

  environment {
    variables = {
      CloverleafVersion = "${var.cloverleaf-lambda-version}"
      MetastoreUris     = "${var.hive-metastore-uri}"
      InstanceName      = "${var.instance_name}"

      # The variables below are all required
      EmrCloverleafJarUri           = "s3://${coalesce(var.cloverleaf-lambda-bucket, local.default-cloverleaf-lambda-bucket)}/${coalesce(var.cloverleaf-jars-s3-key, local.default-cloverleaf-steps-jar-s3-key)}/cloverleaf-steps-${var.cloverleaf-lambda-version}.jar"
      EmrCloverleafStepJarMainClass = "com.hotels.bdp.cloverleaf.CloverleafOrchestrator"
      MasterConfigLocation          = "s3://${var.master-config-s3-bucket}/${var.master-config-s3-key}/cloverleaf_master_config.yml"
      DatapipelineLogUri            = "${var.cloverleaf-datapipeline-log-location}"
      DatapipelineTopicArn          = "${aws_sns_topic.cloverleaf-datapipeline.arn}"
      DatapipelineSnsRole           = "CLOVERLEAF/${aws_iam_role.cloverleaf-datapipeline-sns.name}"

      # Optionally set the strategy for deleting orphaned data
      OrphanedDataStrategy = "${var.orphaned-data-strategy}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "cloverleaf_fn" {
  event_source_arn = "${aws_sqs_queue.cloverleaf_sqs_queue.arn}"
  function_name    = "${aws_lambda_function.cloverleaf_fn.arn}"
  batch_size       = 1
  enabled          = true
}

resource "aws_lambda_function" "cloverleaf_datapipeline_fn" {
  s3_bucket     = "${coalesce(var.cloverleaf-lambda-bucket, local.default-cloverleaf-lambda-bucket)}"
  s3_key        = "${coalesce(var.cloverleaf-jars-s3-key, local.default-cloverleaf-lambda-jar-s3-key)}/cloverleaf-lambda-${var.cloverleaf-lambda-version}.jar"
  function_name = "${var.instance_name}-datapipeline-fn"
  role          = "${aws_iam_role.cloverleaf-datapipeline-lambda.arn}"
  handler       = "com.hotels.bdp.cloverleaf.datapipeline.lambda.DataPipelineNotificationsHandler::handleRequest"
  runtime       = "java8"
  memory_size   = "512"
  timeout       = "300"
  publish       = true
  reserved_concurrent_executions = 10
  tags          = "${var.tags}"
}

resource "aws_lambda_permission" "cloverlaf-datapipeline" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cloverleaf_datapipeline_fn.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.cloverleaf-datapipeline.arn}"
}
