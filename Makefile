POWERSHELL ?= pwsh
TERRAFORM_SCRIPT := scripts/terraform.ps1

.PHONY: help terraform-fmt terraform-init terraform-validate terraform-check
.PHONY: terraform-plan terraform-output

help:
	@echo "Available targets:"
	@echo "  terraform-fmt       Format all Terraform files"
	@echo "  terraform-init      Initialize providers and HCP Terraform state"
	@echo "  terraform-validate  Validate the non-production configuration"
	@echo "  terraform-check     Format, initialize and validate"
	@echo "  terraform-plan      Create a reviewed non-production plan"
	@echo "  terraform-output    Display the non-production outputs"

terraform-fmt:
	$(POWERSHELL) -NoProfile -File $(TERRAFORM_SCRIPT) -Action fmt

terraform-init:
	$(POWERSHELL) -NoProfile -File $(TERRAFORM_SCRIPT) -Action init

terraform-validate:
	$(POWERSHELL) -NoProfile -File $(TERRAFORM_SCRIPT) -Action validate

terraform-check: terraform-fmt terraform-init terraform-validate

terraform-plan: terraform-check
	$(POWERSHELL) -NoProfile -File $(TERRAFORM_SCRIPT) -Action plan

terraform-output:
	$(POWERSHELL) -NoProfile -File $(TERRAFORM_SCRIPT) -Action output
