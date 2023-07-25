# Troubleshooting Deploying To GAE Using Terraform

This folder contains extra supporting information for
[this stackoverflow link](https://stackoverflow.com/questions/76755150/why-does-a-terraform-deployment-of-a-gae-net-service-fail-despite-specifying-th)

The actual deployment I'm having problems with creates a publish package
of an application and saves it as an artifact which is then picked up by 
a separate build process which runs a terraform deployment. See [terraform
deployment](#terraform-deployment)

## First Test - Deploy Without Terraform

`AppEngineTest` is a stripped down version of the application I'm trying to
deploy with the proprietary code removed. I'm fairly confident that the
proprietary code isn't the problem right now.

Have run the command:

```
gcloud app deploy
```

in the root of the project `AppEngineTest` and the file
[app_deploy_masked](./app_deploy_masked.log) is the build output. Even though
this fails the cloud build corresponding to this succeeds and the [execution details](./exec_details_1.txt) 
for the build are far more comprehensive. In particular you can see
that the build has picked up the .NET 6 runtime. For builds which use the
terraform deployment the [execution details](./exec_details_2.txt) are not as comprehensive. You can 
see that the `_GAE_APPLICATION_YAML_PATH` variable has been set but the runtime
is not picked up.

## Terraform Deployment

We use this command to create the publish package which is zipped up:

```
dotnet publish -c release -o 'tenantProcessor' 'path to csproj file'
```

Here is the terraform used to deploy the application. As mentioned in the
stackoverflow link I've tried a few different options for the app.yaml path.

```terraform
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
```
