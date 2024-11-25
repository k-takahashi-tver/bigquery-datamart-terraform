variable "project" {
  description = "Project ID"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "default" {
  description = "Default values"
  type        = map(string)
}

variable "scheduled_queries" {
  description = "Map of resource setting"
  type = map(object({
    project                = optional(string, "")
    location               = optional(string, "")
    dataset_id             = optional(map(string))
    destination_dataset_id = optional(string, "")
    table_id               = optional(string, "")
    scheduled_display_name = optional(string, "")
    schedule               = optional(string, "")
    schedule_options       = optional(map(string))
    email_preferences      = optional(map(string))
    schedule_query_params  = optional(map(string))
    query_path             = optional(string, "")
    query_args             = optional(map(string))
    table_schema_path      = optional(string, "")
    table_description      = optional(string, "")
    time_partitioning      = optional(map(string))
    service_account_emails = optional(map(string))
    clustering             = optional(list(string))
  }))
}

variable "views" {
  description = "Map of resource setting"
  type = map(object({
    project     = optional(string, "")
    location    = optional(string, "")
    dataset_id  = optional(map(string))
    table_id    = string
    query_path  = string
    query_args  = optional(map(string))
    description = optional(string, "")
  }))
}

variable "tvfs" {
  description = "Map of resource table valued function"
  type = map(object({
    project     = optional(string, "")
    dataset_id  = optional(map(string))
    routine_id  = string
    query_path  = string
    query_args  = optional(map(string))
    description = optional(string, "")
    arguments = optional(list(object({
      name             = string
      type             = string
      arrayElementType = optional(map(string))
    })))
  }))
}

variable "udfs" {
  description = "Map of resource table valued function"
  type = map(object({
    project     = optional(string, "")
    dataset_id  = optional(map(string))
    routine_id  = string
    language    = optional(string, "")
    return_type = optional(string, "")
    query_path  = string
    query_args  = optional(map(string))
    description = optional(string, "")
    arguments = optional(list(object({
      name             = string
      type             = string
      arrayElementType = optional(map(string))
    })))
  }))
}

