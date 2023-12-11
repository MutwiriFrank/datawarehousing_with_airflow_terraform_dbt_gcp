terraform {
  required_version = ">= 1.0"
  backend "local" {}  # Can change from "local" to "gcs" (for google) or "s3" (for aws), if you would like to preserve your tf-state online
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project
  region = var.region
  // credentials = file(var.credentials)  # Use this if you do not want to set env-var GOOGLE_APPLICATION_CREDENTIALS
}

# Data Lake Bucket
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "data-lake-bucket" {
  name          = "${local.data_lake_bucket}_${var.project}" # Concatenating DL bucket & Project name for unique naming
  location      = var.region

  # Optional, but recommended settings:
  storage_class = var.storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled     = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30  // days
    }
  }

  force_destroy = true
}


# DWH
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset
resource "google_bigquery_dataset" "datasets" {
  for_each = local.datasetsMap

  project    = var.project
  dataset_id = each.value["datasetId"]
  location   = var.region
  friendly_name = each.value["datasetFriendlyName"]
  description = each.value["datasetDescription"]

}

resource "google_bigquery_table" "tables" {
  for_each = {for idx, table in local.tables_flattened : "${table["datasetId"]}_${table["tableId"]}" => table}

  project    = var.project
  depends_on = [google_bigquery_dataset.datasets]
  dataset_id = each.value["datasetId"]
  table_id   = each.value["tableId"]
  clustering = each.value["clustering"]

  dynamic "time_partitioning" {
    for_each = each.value["partitionType"] != null ? [1] : []

    content {
      type                     = each.value["partitionType"]
      field                    = each.value["partitionField"]
      expiration_ms            = each.value["expirationMs"]
      require_partition_filter = each.value["requirePartitionFilter"]
    }
  }

  schema = file("${path.module}/${each.value["tableSchemaPath"]}")
}