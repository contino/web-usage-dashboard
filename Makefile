MY_PUBLIC_IP=$(shell curl -s https://api.ipify.org)
DASHBOARD_FILE=kibana_dashboard_export.ndjson
KIBANA_URL=https://search-manitest6-u6ggfrtq7y7aykurrb2hcdpwou.eu-west-2.es.amazonaws.com/_plugin/kibana/

PHONEY: init test clean build deploy destroy help validate

init: ## Configure python virtual env and download dependencies
	pipenv --python 3.8 && \
	pipenv install --ignore-pipfile -d  && \
	pipenv shell

test: ## Run Lambda unit tests
	pipenv run python -m pytest

clean: ## Clean up existing artifacts, tf state files etc.
	@echo "[make clean] Cleaning up.." && \
	rm -rf _build && rm -f lambda.zip && \
	rm -rf .pytest_cache/ && \
	rm -rf .requirements.txt && \
	rm -rf terraform/.terraform* && \
	rm -f terraform/terraform.tfstate* && \
	rm -f terraform/.terraform.lock.hcl && \
	echo "[make clean] Successfully cleaned up build env.."


build: ## Build lambda artifact
	@echo "[make build] Installing dependencies to a dedicated directory" && \
	pipenv lock -r > .requirements.txt && \
	pipenv run pip install -r .requirements.txt --target _build/  && \
	echo "[make build] Copying project's source code to _build folder"  && \
	rsync -rv --exclude=tests src/* _build && \
	echo "[make build] Creating zip file for lambda"  && \
	cd _build && zip -r ../lambda.zip *

deploy: validate ## Deploy infrastructure to the cloud
	cd terraform  && \
	terraform init  && \
	terraform apply \
		-var="allowed_ip=$(MY_PUBLIC_IP)"  \
		-var="project_name=$(PROJECT_NAME)" \
		-auto-approve
	@echo "Importing $(DASHBOARD_FILE) to kibana endpoint: `cd terraform && terraform output -raw kibana_endpoint`"
	@curl -X POST `cd terraform && terraform output -raw kibana_endpoint`/api/saved_objects/_import -H "kbn-xsrf: true" --form file=@$(DASHBOARD_FILE) -H 'kbn-xsrf: true'
	@echo "\n\nKibana Dashboard: `cd terraform && terraform output -raw kibana_endpoint`app/dashboards"
	@echo "\n\nTo test: Upload a sample log file by using the following command:"
	@echo "aws s3 cp ./sample_data/2021-12.log  s3://`cd terraform && terraform output -raw s3_bucket_name`/\n"

destroy: validate ## Destroy infrastructure from the cloud
	cd terraform  && \
	terraform init  && \
	terraform destroy  -var="allowed_ip=$(MY_PUBLIC_IP)" -var="project_name=$(PROJECT_NAME)" --auto-approve

validate: ## Validates input variables (not to be used directly)
ifndef PROJECT_NAME
	$(error make variable PROJECT_NAME is undefined)
else
	@echo "[make validate-variables] Successfully validated input variables"
endif

help: ## Help with commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help