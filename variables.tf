variable "aws_region" {
  type = string
}

variable "execution_logs_logging_level" {
  type = string
}

variable "execution_logs_data_trace_enabled" {
  type = bool
}

variable "execution_logs_metrics_enabled" {
  type = bool
}

variable "xray_tracing_enabled" {
  type = bool
}
