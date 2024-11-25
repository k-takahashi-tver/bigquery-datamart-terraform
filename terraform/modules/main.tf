resource "google_bigquery_table" "tables" {
  # テーブルスキーマのパスを持つものだけ
  for_each = { for k, v in var.scheduled_queries : k => v if v.table_schema_path != "" }

  project    = each.value.project != "" ? each.value.project : var.default.project
  dataset_id = each.value.dataset_id != null ? lookup(each.value.dataset_id, var.environment, var.default.dataset_id) : var.default.dataset_id
  table_id   = each.value.table_id
  schema     = file("${path.module}/../../scheduled_query/${each.key}/${each.value.table_schema_path}")
  dynamic "time_partitioning" {
    for_each = each.value.time_partitioning != null ? [each.value.time_partitioning] : []
    content {
      type  = lookup(time_partitioning.value, "type", "DAY")
      field = lookup(time_partitioning.value, "field", null)
    }
  }
  clustering  = each.value.clustering != "" ? each.value.clustering : null
  description = each.value.table_description != "" ? each.value.table_description : null
}

resource "google_bigquery_data_transfer_config" "scheduled_queries" {
  # クエリパスを持つものだけ
  for_each               = { for k, v in var.scheduled_queries : k => v if v.query_path != "" }
  project                = each.value.project != "" ? each.value.project : var.default.project
  location               = each.value.location != "" ? each.value.location : var.default.location
  display_name           = each.value.scheduled_display_name
  destination_dataset_id = each.value.destination_dataset_id != "" ? each.value.destination_dataset_id : null
  data_source_id         = "scheduled_query"
  schedule               = each.value.schedule
  params = merge({
    query = templatefile(
      "${path.module}/../../scheduled_query/${each.key}/${each.value.query_path}",
      merge(var.default, each.value.query_args)
    )
  }, each.value.schedule_query_params)
  # service_account_emails が設定されている場合、各環境のSAを設定する. 設定されてなければデフォルト
  service_account_name = each.value.service_account_emails != null ? lookup(each.value.service_account_emails, var.environment, var.default.service_account_email) : var.default.service_account_email

  dynamic "schedule_options" {
    for_each = each.value.schedule_options != null ? [each.value.schedule_options] : []
    content {
      disable_auto_scheduling = lookup(schedule_options.value, "disable_auto_scheduling", false)
      start_time              = lookup(schedule_options.value, "start_time", null)
    }
  }
  dynamic "email_preferences" {
    for_each = each.value.email_preferences != null ? [each.value.email_preferences] : []
    content {
      enable_failure_email = lookup(email_preferences.value, "enable_failure_email", false)
    }
  }
}

resource "google_bigquery_table" "views" {
  for_each    = var.views
  project     = each.value.project != "" ? each.value.project : var.default.project
  dataset_id  = each.value.dataset_id != null ? lookup(each.value.dataset_id, var.environment, var.default.dataset_id) : var.default.dataset_id
  table_id    = each.value.table_id
  description = each.value.description
  view {
    query = templatefile(
      "${path.module}/../../view/${each.key}/${each.value.query_path}",
      merge(var.default, each.value.query_args)
    )
    use_legacy_sql = false
  }
}

resource "google_bigquery_routine" "tvfs" {
  for_each     = var.tvfs
  project      = each.value.project != "" ? each.value.project : var.default.project
  dataset_id   = each.value.dataset_id != null ? lookup(each.value.dataset_id, var.environment, var.default.dataset_id) : var.default.dataset_id
  routine_id   = each.value.routine_id
  routine_type = "TABLE_VALUED_FUNCTION"
  language     = "SQL"
  definition_body = templatefile(
    "${path.module}/../../table_valued_function/${each.key}/${each.value.query_path}",
    merge(var.default, each.value.query_args)
  )
  dynamic "arguments" {
    for_each = { for k, v in each.value.arguments : k => v }
    content {
      name      = arguments.value.name
      data_type = try(arguments.value.arrayElementType, null) == null ? jsonencode({ "typeKind" : arguments.value.type }) : jsonencode({ "typeKind" : arguments.value.type, "arrayElementType" : arguments.value.arrayElementType })
    }
  }
  description = each.value.description
}

resource "google_bigquery_routine" "udfs" {
  for_each     = var.udfs
  project      = each.value.project != "" ? each.value.project : var.default.project
  dataset_id   = each.value.dataset_id != null ? lookup(each.value.dataset_id, var.environment, var.default.dataset_id) : var.default.dataset_id
  routine_id   = each.value.routine_id
  routine_type = "SCALAR_FUNCTION"
  language     = each.value.language != "" ? each.value.language : "SQL"
  definition_body = templatefile(
    "${path.module}/../../user_defined_function/${each.key}/${each.value.query_path}",
    merge(var.default, each.value.query_args)
  )
  description = each.value.description
  dynamic "arguments" {
    for_each = { for k, v in each.value.arguments : k => v }
    content {
      name      = arguments.value.name
      data_type = try(arguments.value.arrayElementType, null) == null ? jsonencode({ "typeKind" : arguments.value.type }) : jsonencode({ "typeKind" : arguments.value.type, "arrayElementType" : arguments.value.arrayElementType })
    }
  }

  return_type = each.value.return_type != "" ? jsonencode({ "typeKind" : each.value.return_type }) : null
}

resource "google_bigquery_table_iam_member" "table_editor" {
  # テーブルスキーマのパスを持つ & scheduled query のクエリのパスを持つ
  for_each   = { for k, v in var.scheduled_queries : k => v if v.table_schema_path != "" && v.query_path != "" }
  project    = each.value.project != "" ? each.value.project : var.default.project
  dataset_id = each.value.dataset_id != null ? lookup(each.value.dataset_id, var.environment, var.default.dataset_id) : var.default.dataset_id
  table_id   = each.value.table_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${each.value.service_account_emails != null ? lookup(each.value.service_account_emails, var.environment, var.default.service_account_email) : var.default.service_account_email}"
}

