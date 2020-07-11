SHELL := /usr/bin/env bash
AWS_PROFILE ?= admin
ENV ?= dev
TF_STATE_NAME ?= state


.PHONY: validate format plan apply shell

validate: ## Usage: make validate <ENV=staging
	@aws-vault exec ${AWS_PROFILE} -- docker-compose run --rm terraform " \
		terraform init -backend-config 'key=${TF_STATE_NAME}.${ENV}.tfstate' -reconfigure -get=true && \
		terraform validate \
	"

format: ## Usage: make format
	@docker-compose run --rm terraform " \
		terraform fmt -list=true -diff -recursive . \
	"

plan: ## Usage: make plan <ENV=staging>
	@aws-vault exec ${AWS_PROFILE} -- docker-compose run --rm terraform " \
		terraform init -backend-config=key=${TF_STATE_NAME}.${ENV}.tfstate -force-copy -reconfigure && \
		terraform plan -var-file=tfvars/${ENV}.tfvars -out=./.plans/plan.out \
	"

apply: ## Usage: make apply <ENV=staging>
	@aws-vault exec ${AWS_PROFILE} -- docker-compose run --rm terraform " \
		terraform init -backend-config=key=${TF_STATE_NAME}.${ENV}.tfstate -force-copy -reconfigure && \
		terraform apply ./.plans/plan.out && \
		rm ./.plans/plan.out \
	"

shell: ## Usage: make shell <ENV=staging>
	@aws-vault exec ${AWS_PROFILE} -- docker-compose run --rm terraform " \
		terraform init -backend-config=key=${TF_STATE_NAME}.${ENV}.tfstate -force-copy -reconfigure && \
		/bin/sh \
	"
