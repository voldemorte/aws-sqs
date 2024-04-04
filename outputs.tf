output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.sqs.queue_arn
}

output "queue_url" {
  description = "Same as `queue_id`: The URL for the created Amazon SQS queue"
  value       = module.sqs.queue_url
}

output "queue_name" {
  description = "The name of the SQS queue"
  value       = module.sqs.queue_name
}
