locals {
  default_alarms = {
    "delayed_messages" = {
      "alarm_description"   = "Too many delayed messages"
      "comparison_operator" = "GreaterThanOrEqualToThreshold"
      "evaluation_periods"  = 2
      "metric_name"         = "ApproximateNumberOfMessagesDelayed"
      "period"              = 120
      "statistic"           = "Average"
      "threshold"           = "80"
    }
  }
  alarms = merge(local.default_alarms, var.additional_alarms)
}

module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.1.1"

  content_based_deduplication           = var.content_based_deduplication
  create_dlq                            = var.create_dlq
  create_dlq_queue_policy               = var.create_dlq_queue_policy
  create_dlq_redrive_allow_policy       = var.create_dlq_redrive_allow_policy
  create_queue_policy                   = var.create_queue_policy
  deduplication_scope                   = var.deduplication_scope
  delay_seconds                         = var.delay_seconds
  dlq_content_based_deduplication       = var.dlq_content_based_deduplication
  dlq_deduplication_scope               = var.dlq_deduplication_scope
  dlq_delay_seconds                     = var.dlq_delay_seconds
  dlq_kms_data_key_reuse_period_seconds = var.dlq_kms_data_key_reuse_period_seconds
  dlq_kms_master_key_id                 = var.dlq_kms_master_key_id
  dlq_message_retention_seconds         = var.dlq_message_retention_seconds
  dlq_name                              = var.dlq_name
  dlq_queue_policy_statements           = var.dlq_queue_policy_statements
  dlq_receive_wait_time_seconds         = var.dlq_receive_wait_time_seconds
  dlq_redrive_allow_policy              = var.dlq_redrive_allow_policy
  dlq_sqs_managed_sse_enabled           = var.dlq_sqs_managed_sse_enabled
  dlq_tags                              = var.dlq_tags
  dlq_visibility_timeout_seconds        = var.dlq_visibility_timeout_seconds
  fifo_queue                            = var.fifo_queue
  fifo_throughput_limit                 = var.fifo_throughput_limit
  kms_data_key_reuse_period_seconds     = var.kms_data_key_reuse_period_seconds
  kms_master_key_id                     = var.kms_master_key_id
  max_message_size                      = var.max_message_size
  message_retention_seconds             = var.message_retention_seconds
  name                                  = var.name
  override_dlq_queue_policy_documents   = var.override_dlq_queue_policy_documents
  override_queue_policy_documents       = var.override_queue_policy_documents
  queue_policy_statements               = var.queue_policy_statements
  receive_wait_time_seconds             = var.receive_wait_time_seconds
  redrive_allow_policy                  = var.redrive_allow_policy
  redrive_policy                        = var.redrive_policy
  source_dlq_queue_policy_documents     = var.source_dlq_queue_policy_documents
  source_queue_policy_documents         = var.source_queue_policy_documents
  sqs_managed_sse_enabled               = var.sqs_managed_sse_enabled
  tags                                  = var.tags
  use_name_prefix                       = var.use_name_prefix
  visibility_timeout_seconds            = var.visibility_timeout_seconds
}

module "metric_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "~> 3.0"

  for_each = var.create ? local.alarms : {}

  alarm_name          = each.key
  alarm_description   = lookup(each.value, "alarm_description", "")
  comparison_operator = lookup(each.value, "comparison_operator", "")
  evaluation_periods  = lookup(each.value, "evaluation_periods", "")
  threshold           = lookup(each.value, "threshold", 1)
  period              = lookup(each.value, "period", 60)
  unit                = lookup(each.value, "unit", "Count")
  metric_name         = lookup(each.value, "metric_name", "")
  namespace           = "AWS/SQS"

  alarm_actions = [var.sns_arn]
}
