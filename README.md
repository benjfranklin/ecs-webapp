# AWS ECS-hosted Web Application
This repository contains the infrastructure-code required to compile a basic HTML web-page into a docker container and host it in AWS using the [Elastic Container Service](https://aws.amazon.com/ecs/).

When the deployment is run, the contents of ./src/www will be compiled into a docker container running NGINX and pushed to an AWS container repository. Thereafter the deployment will create the required resources to host the service in ECS and publish it to the WWW using an [AWS Global Accelerator](https://aws.amazon.com/global-accelerator).

The diagram below describes the resultant deployment architecture in AWS.


![Alt text](diagram.png?raw=true "Architecture Diagram")

## Pre-requisites
1. Terraform 0.12.x [installed](https://www.terraform.io/downloads.html).
2. Terraform AWS Provider [credentials](https://www.terraform.io/docs/providers/aws/index.html#authentication) configured.
3. AWS CLI version 2 [installed](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
4. AWS CLI [credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) configured.
5. Docker [installed](https://docs.docker.com/get-docker/).

## Usage
```
$ terraform init
$ terraform plan 
$ terraform apply 
```
Once the terraform apply has successfully completed, the process will output the Global Accelerator URL to the console similar to the following:

```
Application_Endpoint_URL = https://<hostname>.awsglobalaccelerator.com
```
The URL can be opened in a browser to verify that the application has been successfully deployed

Note: The deployment does not create or manage AWS Route53 or similar DNS records and as such, to complete the deployment one would need create a CNAME entry on a valid hosted DNS zone (as depicted in the diagram) to finalize the installation.
