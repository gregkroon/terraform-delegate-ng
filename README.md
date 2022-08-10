# TerraformDelegateAutomation

### Introduction 
MVP Terraform manifest for provisioning a delegate , cloud provider and infrastructure .
Purpose is to ease and automate onboarding through configuration as code .

Feel free to hack and change as you see fit !


### Requirements 

The terraform manifest uses the official kubernetes provider from Hashicorp . It is set to read your kubeconfig file 
you will need to provide path and context . Alteratively use what ever credential helper or auth configuration that suits you .

https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

With this provider it will create exaclty the same kubernetes objects as the kubernetes YAML downloaded form Harness.
Namely : Namespace , Cluster role binding , seecret and statefulset .

For the cloud provider and infrstructure binding it will use the Harness config as code rest api via the Terraform local-exec and curl commands 
(therefore curl is required in the path where this manifest is run )

### Input parameters required for provisioning 

harness_api_key = Create one in the Harness UI , Security->Access management->API keys 

harness_account_id = You can find this in your harness url or in the UI at Setup->Overview->Account id 

harness_account_secret = In the delegate kubernetes yaml 

application_name = Existing application name 

environment_name = Existing environment name

delegate_name = provided by you 

cloud_provider_name = provided by you

infrastructure_name = provided by you


