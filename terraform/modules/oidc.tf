
locals {
  repo_name = "bigquery-datamart-terraform"
  repo_org  = "k-takahashi-tver"
  repo_url  = "https://github.com/k-takahashi-tver/bigquery-datamart-terraform"
  runner_project_roles = toset([
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/iam.serviceAccountViewer",
  ])
}

resource "google_iam_workload_identity_pool" "github_actions" {
  project = var.project

  workload_identity_pool_id = "${local.repo_name}-ga"
  display_name              = "${local.repo_name}-ga"
  description               = "2024-12-03 ブログ用"
  disabled                  = false
}

resource "google_project_iam_member" "github_actions_project_roles" {
  for_each = local.runner_project_roles

  project = var.project
  role    = each.value
  member  = google_service_account.terraform_runner.member

  condition {
    title       = local.repo_url
    description = ""
    expression  = ""
  }
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  project = var.project

  workload_identity_pool_id = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  # once applied with local.repo_name and then destroyed,
  # re-creating with local.repo_name does not work due to
  # error 409: requested entity already exists, even though waited for a while
  workload_identity_pool_provider_id = "${local.repo_name}-ga"
  display_name                       = "${local.repo_name}-ga"
  description                        = "2024-12-03 ブログ用"
  disabled                           = false
  attribute_condition                = "assertion.repository_owner == \"${local.repo_org}\""
  attribute_mapping = {
    "google.subject" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [google_iam_workload_identity_pool.github_actions]
}

resource "google_service_account_iam_member" "terraform_runner_workload_identity" {
  service_account_id = google_service_account.terraform_runner.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/subject/${local.repo_org}/${local.repo_name}"

  depends_on = [google_iam_workload_identity_pool.github_actions]
}
