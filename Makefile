TF_IMAGE=hashicorp/terraform:1.6.6
TF_DIR=terraform/networking
ENV_FILE=.env

include $(ENV_FILE)

format:
	docker run --rm -v $$(pwd):/workspace -w /workspace \
	  $(TF_IMAGE) fmt -recursive

scan:
	checkov -d terraform/networking --framework terraform