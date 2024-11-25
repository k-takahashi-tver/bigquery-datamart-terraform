# リソース内容を記述した .json を読み取る
data "external" "scheduled_query_config" {
  program = ["bash", "${path.module}/../scripts/list_queries.sh", "${path.module}/../scheduled_query"]
}

data "external" "view_config" {
  program = ["bash", "${path.module}/../scripts/list_queries.sh", "${path.module}/../view"]
}

data "external" "tvf_config" {
  program = ["bash", "${path.module}/../scripts/list_queries.sh", "${path.module}/../table_valued_function"]
}

data "external" "udf_config" {
  program = ["bash", "${path.module}/../scripts/list_queries.sh", "${path.module}/../user_defined_function"]
}

# 読み取った .json を変数にする
locals {
  scheduled_queries = { for k, v in data.external.scheduled_query_config.result : k => jsondecode(v) }
  views             = { for k, v in data.external.view_config.result : k => jsondecode(v) }
  tvfs              = { for k, v in data.external.tvf_config.result : k => jsondecode(v) }
  udfs              = { for k, v in data.external.udf_config.result : k => jsondecode(v) }

  # 指定がないときに使うデフォルト設定
  default = {
    project                     = var.project
    location                    = var.location
    dataset_id                  = var.dataset_id
    service_account_email       = var.service_account_email
  }
}

module "bigquery_resources" {
  source      = "./modules"
  environment = var.environment
  project     = var.project
  location    = var.location

  default           = local.default
  scheduled_queries = local.scheduled_queries
  views             = local.views
  tvfs              = local.tvfs
  udfs              = local.udfs
}

# リソース種類毎に import を実行
# 内容は /environments/(devintegrate|staging|production)/terraform.tfvars に記述する
import {
  for_each = { for v in var.import_resources.table : v.resource_name => v if length(var.import_resources.table) > 0 }
  id       = each.value.id
  to       = module.bigquery_resources.google_bigquery_table.tables[each.value.resource_name]
}

import {
  for_each = { for v in var.import_resources.scheduled_query : v.resource_name => v if length(var.import_resources.scheduled_query) > 0 }
  id       = each.value.id
  to       = module.bigquery_resources.google_bigquery_data_transfer_config.scheduled_queries[each.value.resource_name]
}

import {
  for_each = { for v in var.import_resources.view : v.resource_name => v if length(var.import_resources.view) > 0 }
  id       = each.value.id
  to       = module.bigquery_resources.google_bigquery_table.views[each.value.resource_name]
}

import {
  for_each = { for v in var.import_resources.udf : v.resource_name => v if length(var.import_resources.udf) > 0 }
  id       = each.value.id
  to       = module.bigquery_resources.google_bigquery_routine.udfs[each.value.resource_name]
}

import {
  for_each = { for v in var.import_resources.tvf : v.resource_name => v if length(var.import_resources.tvf) > 0 }
  id       = each.value.id
  to       = module.bigquery_resources.google_bigquery_routine.tvfs[each.value.resource_name]
}
