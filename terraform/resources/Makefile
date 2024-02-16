tfplan:
	terraform init -var-file="dev.tfvars"
	terraform plan -var-file="dev.tfvars"

tfapply: 
	terraform init -var-file="dev.tfvars"
	terraform apply -var-file="dev.tfvars"

tfdestroy:
	terraform destroy -var-file="dev.tfvars"