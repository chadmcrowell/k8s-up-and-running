#! /bin/bash

# Initialize terraform - checks, downloads and installs required modules
terraform init

# Plans the deployment - what needs to be created/removed and plans out a provisioning plan based on resource dependencies
terraform plan -out tfplan

# Apply the plan file (e.g. tfplan) and provison the requested resources
#
# -auto-approve flag is optional but for automated environments you should use this flag to automatically deploy the resources without human/user interaction (i.e y/n input)
terraform apply -auto-approve tfplan