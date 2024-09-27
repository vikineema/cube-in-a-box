## You can follow the steps below in order to get yourself a local ODC.
## Start by running `setup` then you should have a system that is fully configured
##
## Once running, you can access a Jupyter environment
## at 'http://localhost' with password 'secretpassword'
.PHONY: help setup up down clean

# Use a different date command flag on Mac OS
DATE_FLAG="-d-3months"
ifeq ($(shell uname),Darwin)
		DATE_FLAG="-v-3m"
endif

# Default BBOX is over Rwanda
BBOX := 25.0,-5.0,35.0,5.0
INDEX_LIMIT := 1000
INDEX_LIMIT_LOW := 200
DATE_START := $(shell date $(DATE_FLAG) +%Y-%m-%d)
DATE_END := $(shell date +%Y-%m-%d)

help: ## Print this help
	@grep -E '^##.*$$' $(MAKEFILE_LIST) | cut -c'4-'
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

setup: build up init products index ## Run a full local/development setup
setup-prod: up-prod init products index ## Run a full production setup

reset:
	make down
	sudo rm -rf data
	make up
	make init
	make products
	#make index-parallel

build: ## 0. Build the base image
	docker compose pull
	docker compose build

up: ## 1. Bring up your Docker environment
	docker compose up -d postgres
	docker compose run checkdb
	docker compose up -d jupyter

init: ## 2. Prepare the database
	docker compose exec -T jupyter datacube -v system init

products: ## 3. Add all product definitions
	docker compose exec -T jupyter dc-sync-products https://raw.githubusercontent.com/digitalearthafrica/config/master/prod/products_prod.csv

index: index-parallel ## 4. Index most products
index-parallel:
	INDEX_LIMIT=$(INDEX_LIMIT) DATE_START=$(DATE_START) DATE_END=$(DATE_END) INDEX_LIMIT_LOW=$(INDEX_LIMIT_LOW) bash index-parallel.sh

index-all: index-dem_srtm index-fc_ls index-gm_ls5_ls7_annual index-gm_ls8_annual index-gm_s2_annual index-gm_s2_annual_lowres index-gm_s2_semiannual index-io_lulc index-ls5_sr index-ls5_st index-ls7_sr index-ls7_st index-ls8_sr index-ls8_st index-pc_s2_annual index-rainfall_chirps_monthly index-s1_rtc index-s2_l2a index-wofs_ls index-wofs_ls_summary_alltime index-wofs_ls_summary_annual index-alos_palsar_mosaic index-jers_sar_mosaic index-crop_mask_eastern index-crop_mask_northern index-crop_mask_western

index-alos_palsar_mosaic:
	@echo "$$(date) Start with alos_palsar_mosaic"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=alos_palsar_mosaic \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with alos_palsar_mosaic"

index-crop_mask:
	@echo "$$(date) Start with crop_mask"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=crop_mask \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with crop_mask"

index-dem_srtm:
	@echo "$$(date) Start with dem_srtm"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=dem_srtm \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with dem_srtm"

index-fc_ls:
	@echo "$$(date) Start with fc_ls"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=fc_ls \
		--bbox=$(BBOX) \
		--limit=$$(($(INDEX_LIMIT)/2)) \
		--datetime=$(DATE_START)/$(DATE_END)
	@echo "$$(date) Done with fc_ls"

index-gm_ls5_ls7_annual:
	@echo "$$(date) Start with gm_ls5_ls7_annual"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=gm_ls5_ls7_annual \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with gm_ls5_ls7_annual"

index-gm_ls8_annual:
	@echo "$$(date) Start with gm_ls8_annual"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=gm_ls8_annual \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with gm_ls8_annual"

index-gm_s2_annual:
	@echo "$$(date) Start with gm_s2_annual"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=gm_s2_annual \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with gm_s2_annual"

index-gm_s2_annual_lowres:
	@echo "$$(date) Start with gm_s2_annual_lowres"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=gm_s2_annual_lowres \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with gm_s2_annual_lowres"

index-gm_s2_semiannual:
	@echo "$$(date) Start with gm_s2_semiannual"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=gm_s2_semiannual \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with gm_s2_semiannual"

index-io_lulc:
	@echo "$$(date) Start with io_lulc"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=io_lulc \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with io_lulc"

index-jers_sar_mosaic:
	@echo "$$(date) Start with jers_sar_mosaic"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=jers_sar_mosaic \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with jers_sar_mosaic"

index-ls5_sr:
	@echo "$$(date) Start with ls5_sr"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=ls5_sr \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with ls5_sr"

index-ls5_st:
	@echo "$$(date) Start with ls5_st"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=ls5_st \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with ls5_st"

index-ls7_sr:
	@echo "$$(date) Start with ls7_sr"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=ls7_sr \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT) \
		--datetime=$(DATE_START)/$(DATE_END)
	@echo "$$(date) Done with ls7_sr"

index-ls7_st:
	@echo "$$(date) Start with ls7_st"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=ls7_st \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT) \
		--datetime=$(DATE_START)/$(DATE_END)
	@echo "$$(date) Done with ls7_st"

index-ls8_sr:
	@echo "$$(date) Start with ls8_sr"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=ls8_sr \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT) \
		--datetime=$(DATE_START)/$(DATE_END)
	@echo "$$(date) Done with ls8_sr"

index-ls8_st:
	@echo "$$(date) Start with ls8_st"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=ls8_st \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT) \
		--datetime=$(DATE_START)/$(DATE_END)
	@echo "$$(date) Done with ls8_st"

index-pc_s2_annual:
	@echo "$$(date) Start with pc_s2_annual"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=pc_s2_annual \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with pc_s2_annual"

index-rainfall_chirps_monthly:
	@echo "$$(date) Start with rainfall_chirps_monthly"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=rainfall_chirps_monthly \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT) \
		--datetime=$(DATE_START)/$(DATE_END)
	@echo "$$(date) Done with rainfall_chirps_monthly"

index-s1_rtc:
	@echo "$$(date) Start with s1_rtc"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=s1_rtc \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT) \
		--datetime=$(DATE_START)/$(DATE_END)
	@echo "$$(date) Done with s1_rtc"

index-s2_l2a:
	@echo "$$(date) Start with s2_l2a"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=s2_l2a \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT_LOW) \
		--datetime=$(DATE_START)/$(DATE_END)
	@echo "$$(date) Done with s2_l2a"

index-wofs_ls:
	@echo "$$(date) Start with wofs_ls"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=wofs_ls \
		--bbox=$(BBOX) \
		--limit=$$(($(INDEX_LIMIT)/2)) \
		--datetime=$(DATE_START)/$(DATE_END)
	@echo "$$(date) Done with wofs_ls"

index-wofs_ls_summary_alltime:
	@echo "$$(date) Start with wofs_ls_summary_alltime"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=wofs_ls_summary_alltime \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with wofs_ls_summary_alltime"

index-wofs_ls_summary_annual:
	@echo "$$(date) Start with wofs_ls_summary_annual"
	docker compose exec -T jupyter stac-to-dc \
		--catalog-href=https://explorer.digitalearth.africa/stac/ \
		--collections=wofs_ls_summary_annual \
		--bbox=$(BBOX) \
		--limit=$(INDEX_LIMIT)
	@echo "$$(date) Done with wofs_ls_summary_annual"

down: ## Bring down the system
	docker compose down

shell: ## Start an interactive shell
	docker compose exec jupyter bash

clean: ## Delete everything
	docker compose down --rmi all -v

logs: ## Show the logs from the stack
	docker compose logs --follow

build-image:
	docker build --tag digitalearthafrica/cube-in-a-box .

push-image:
	docker push digitalearthafrica/cube-in-a-box

up-prod: ## Bring up production version
	docker compose -f docker-compose-prod.yml pull
	docker compose -f docker-compose.yml -f docker-compose-prod.yml up -d postgres
	docker compose run checkdb
	docker compose -f docker-compose.yml -f docker-compose-prod.yml up -d --no-build

create-infra:  ## Deploy to AWS
	aws cloudformation create-stack \
		--region eu-west-1 \
		--stack-name odc-test \
		--template-body file://cube-in-a-box-cloudformation.yml \
		--parameter file://parameters.json \
		--tags Key=Name,Value=OpenDataCube \
		--capabilities CAPABILITY_NAMED_IAM

update-infra: ## Update AWS deployment
	aws cloudformation update-stack \
		--stack-name eu-west-1 \
		--template-body file://cube-in-a-box-cloudformation.yml \
		--parameter file://parameters.json \
		--tags Key=Name,Value=OpenDataCube \
		--capabilities CAPABILITY_NAMED_IAM
