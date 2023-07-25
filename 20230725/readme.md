# Troubleshooting Deploying To GAE Using Terraform

This folder contains extra supporting information for
[this stackoverflow link](https://stackoverflow.com/questions/76755150/why-does-a-terraform-deployment-of-a-gae-net-service-fail-despite-specifying-th)

An [issue](https://github.com/hashicorp/terraform-provider-google/issues/15281) has been raised for this.

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

## Terraform Deployment Steps

Below is a simplified version of what we have in our production and test system and should hopefully provide enough information to
reproduce the issue.

We use this command to create the publish package from the included test application which is zipped up:

```
dotnet publish -c release '.\AppEngineTest\AppEngineTest.csproj'
```

[Here](main.tf) is the terraform used to deploy the application. To use this you would need to fill
in some of the variables with your own constants. 

We get a build log (cloud build in GCP web UI) as follows when running the terraform apply:

```
Pulling image: gcr.io/gcp-runtimes/aspnetcorebuild@sha256:f5552a5efdaf278a3124ea10fd1c9636b09fc9f98f9e620cbd71279797576b3f
gcr.io/gcp-runtimes/aspnetcorebuild@sha256:f5552a5efdaf278a3124ea10fd1c9636b09fc9f98f9e620cbd71279797576b3f: Pulling from gcp-runtimes/aspnetcorebuild
bd0de8be231c: Pulling fs layer
091745073ef1: Pulling fs layer
355bf594d611: Pulling fs layer
013d0752935b: Pulling fs layer
4c7d0d02eb09: Pulling fs layer
013d0752935b: Waiting
4c7d0d02eb09: Waiting
355bf594d611: Verifying Checksum
355bf594d611: Download complete
013d0752935b: Verifying Checksum
013d0752935b: Download complete
4c7d0d02eb09: Verifying Checksum
4c7d0d02eb09: Download complete
091745073ef1: Verifying Checksum
091745073ef1: Download complete
bd0de8be231c: Verifying Checksum
bd0de8be231c: Download complete
bd0de8be231c: Pull complete
091745073ef1: Pull complete
355bf594d611: Pull complete
013d0752935b: Pull complete
4c7d0d02eb09: Pull complete
Digest: sha256:f5552a5efdaf278a3124ea10fd1c9636b09fc9f98f9e620cbd71279797576b3f
Status: Downloaded newer image for gcr.io/gcp-runtimes/aspnetcorebuild@sha256:f5552a5efdaf278a3124ea10fd1c9636b09fc9f98f9e620cbd71279797576b3f
gcr.io/gcp-runtimes/aspnetcorebuild@sha256:f5552a5efdaf278a3124ea10fd1c9636b09fc9f98f9e620cbd71279797576b3f
No valid .NET Core runtime version found for the app or it is not a supported app.
```

The execution details provides a name of:

```
gcr.io/gcp-runtimes/aspnetcorebuild@sha256:f5552a5efdaf278a3124ea10fd1c9636b09fc9f98f9e620cbd71279797576b3f
```

and arguments of:

```
--version-map 1.0.16=gcr.io/google-appengine/aspnetcore@sha256:68171f7e9a9f165b6c5e5c86efd2a53ed170d7463cb11c2f05e50da8bd8d1f58 1.1.13=gcr.io/google-appengine/aspnetcore@sha256:f725349414f643c56d786e63dd485713c315f9dd68d51d2f1d43aa5796f38fb0 2.0.9=gcr.io/google-appengine/aspnetcore@sha256:bce276858454e5ebdcfb2c856d7ce212dd2cce11a18a5e7f0963c745deba3da4 2.1.22=gcr.io/google-appengine/aspnetcore@sha256:8657a8c70decda993603ccb95877562542567ddf877fde418b126550338024a0 2.2.8=gcr.io/google-appengine/aspnetcore@sha256:1361663f11e30634c89000f3646bef65f943d18fae39d3dd6a5cf3782da15dd1 3.0.3=gcr.io/google-appengine/aspnetcore@sha256:0c7b1ce32de694b46ea0e6f169eab0c4adfae0a4cdcc4616627d514a43ad9b76 3.1.9=gcr.io/google-appengine/aspnetcore@sha256:e3e50ed350c6bb885f37e94581ffe172395f1c9163b0492f08fd83e2d32a13b8
```
