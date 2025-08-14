TF_IMAGE=hashicorp/terraform:1.6.6
TF_DIR=terraform/modules/networking
ENV_FILE=env/.dev.env

include $(ENV_FILE)

format:
	docker run --rm -v $$(pwd):/workspace -w /workspace \
	  $(TF_IMAGE) fmt -recursive

policies:
	docker compose -f infra-tools/generate-policies/docker-compose.yml run --rm generate-policies
