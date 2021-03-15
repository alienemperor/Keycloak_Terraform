# Keycloak_Terraform
Terraform configs for Keycloak

## How to run
1. install terraform
1. clone repo
1. navigate to keycloak_terraform/<realm-you-want-to-create>
1. copy the *tfvars.example file to *.tfvars and update with the required information.
1. run `terraform init`
1. run `terraform plan -var-file="*.tfvars"`
1. verify the changes show correctly
1. run `terraform apply -var-file="*.tfvars" -auto-approve`