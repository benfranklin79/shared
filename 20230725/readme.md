# Troubleshooting Deploying To GAE Using Terraform

This folder contains extra supporting information for
[this stackoverflow link](https://stackoverflow.com/questions/76755150/why-does-a-terraform-deployment-of-a-gae-net-service-fail-despite-specifying-th)

The actual deployment I'm having problems with creates a publish package
of an application and saves it as an artifact which is then picked up by 
a separate build process which runs a terraform deployment. More details 
to be added later.

## First Test - Deploy Without Terraform

`AppEngineTest` is a stripped down version of the application I'm trying to
deploy with the proprietary code removed. I'm fairly confident that the
proprietary code isn't the problem right now.

Have run the command:

```
gcloud app deploy
```

in the root of the project `AppEngineTest` and the file `app_deploy_masked` is
the build output.


