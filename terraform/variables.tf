variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "project ID"
  type        = string
}

variable "service_account_email" {
  description = "Default service account email"
  type        = string
}

# 以下デフォルトあり
variable "location" {
  description = "region"
  type        = string
  default     = "asia-northeast1"
}

variable "dataset_id" {
  description = "Dataset ID"
  type        = string
  default     = "work_takahashi"
}

variable "import_resources" {
  type = object({
    table = optional(list(object({
      resource_name = string
      id            = string
    })), [])
    scheduled_query = optional(list(object({
      resource_name = string
      id            = string
    })), [])
    view = optional(list(object({
      resource_name = string
      id            = string
    })), [])
    udf = optional(list(object({
      resource_name = string
      id            = string
    })), [])
    tvf = optional(list(object({
      resource_name = string
      id            = string
    })), [])
  })
  default = {
    table           = []
    scheduled_query = []
    view            = []
    udf             = []
    tvf             = []
  }
}
