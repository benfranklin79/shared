data "archive_file" "alertsProcessor" {
  type        = "zip"
  source_dir  = "${path.module}/applications/tenantProcessor"
  output_path = "${path.module}/../_archive/appengine/alerts/tenantProcessor.zip"
}

resource "google_storage_bucket_object" "alertsProcessor" {
  name   = "alertsProcessor-${data.archive_file.alertsProcessor.output_sha}.zip"
  bucket = "some bucket name"
  source = data.archive_file.alertsProcessor.output_path
}

resource "google_app_engine_flexible_app_version" "tenantProcessor_v1" {
  version_id = "v1"
  project    = "some project id"
  service    = "some service name"
  runtime    = "aspnetcore"

  network {
    name       = "some network name"
    subnetwork = "some subnetwork"
  }
  
  env_variables = {
    ASPNETCORE_ENVIRONMENT =  "xxxxx" 
    AWS_ACCESS_KEY_ID      =  "xxxxx"
    AWS_SECRET_ACCESS_KEY  = "xxxxx" 
    AWS_REGION             = "eu-west-1"
    APP_PROJECT_ID         = "some project value"
  }

  deployment {
    zip {
      source_url =
      "https://storage.googleapis.com/some_bucket/${google_storage_bucket_object.alertsProcessor.name}"
    }

    cloud_build_options {
        app_yaml_path =  "app.yaml"
    }
  }

  liveness_check {
    path = "/healthcheck"
  }

  readiness_check {
    path = "/healthcheck"
  }

  automatic_scaling {
    min_total_instances = 1
    max_total_instances = 1
    cool_down_period    = "60s"
    request_utilization {
      target_concurrent_requests = 15
    }
    cpu_utilization {
      target_utilization = 0.7
    }
  }

  noop_on_destroy = true
}
