resource "google_service_account" "datamart_runner" {
  project      = var.project
  account_id   = "datamart-creator"
  display_name = "datamart-creator"
  description  = "2024-12-03 ブログ用"
  disabled     = false
}

resource "google_project_iam_member" "scheduled_query_runner_jobuser" {
  project = var.project
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.datamart_runner.member
}

resource "google_service_account" "terraform_runner" {
  project      = var.project
  account_id   = "sample-terraform-runner"
  display_name = "sample-terraform-runner"
  description  = "2024-12-03 ブログ用"
  disabled     = false
}

resource "google_project_iam_member" "terraform_runner_jobuser" {
  for_each = toset(["roles/bigquery.admin",
    "roles/storage.objectUser",
    "roles/iam.serviceAccountCreator",
    "roles/iam.serviceAccountUser",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountTokenCreator"
  ])
  project = var.project
  role    = each.value
  member  = google_service_account.terraform_runner.member
}

resource "google_project_iam_member" "terraform_runner_transfereditor" {
  project = var.project
  role    = "projects/${var.project}/roles/bigquery.transferEditor"
  member  = google_service_account.terraform_runner.member
}

