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
dotnet publish -c release '.\AppEngineTest\AppEngineTest.csproj'
```

[Here](main.tf) is the terraform used to deploy the application. As mentioned in the
stackoverflow link I've tried a few different options for the app.yaml path.
