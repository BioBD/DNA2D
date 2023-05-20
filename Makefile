.PHONY: clean build push sanitize matches tree run experiments cluster

.SECONDARY:

APP_DIR="/app"
DATA_DIR=$(APP_DIR)/data
FULL_ROOT_DIR=`pwd`
FULL_DATA_DIR=$(FULL_ROOT_DIR)/data

IMG_NAME="ghcr.io/biobd/dna2d"

clean:
	mkdir -p $(FULL_DATA_DIR)/images
	mkdir -p $(FULL_DATA_DIR)/trees
	rm -rf $(FULL_DATA_DIR)/images/*
	rm -rf $(FULL_DATA_DIR)/trees/*
	touch $(FULL_DATA_DIR)/.keep
	touch $(FULL_DATA_DIR)/images/.keep
	touch $(FULL_DATA_DIR)/trees/.keep
	rm $(FULL_DATA_DIR)/*.pkl
	rm $(FULL_DATA_DIR)/final_cluster.csv
	rm $(FULL_DATA_DIR)/*.db

build:
	pip install 'dvc==2.34.0' 'dvc-gdrive==2.19.0'
	docker build . -t $(IMG_NAME)

push:
	docker push $(IMG_NAME)

run-docker:
	docker run $(DOCKER_FLAGS) -v $(FULL_ROOT_DIR):$(APP_DIR) $(IMG_NAME) $(CMD)

sanitize:
	CMD="python $(APP_DIR)/sanitize_seqs.py $(DATA_DIR)/$(SEQ).fasta $(TYPE)" $(MAKE) run-docker

matches:
	CMD="python $(APP_DIR)/matchmatrix.py $(DATA_DIR)/$(SEQ).fasta.sanitized $(DATA_DIR)/images/" $(MAKE) run-docker

tree-by-channel:
	CMD="python $(APP_DIR)/tree_builder.py $(DATA_DIR)/$(SEQ).fasta.sanitized $(DATA_DIR)/trees/$(CHANNEL) $(TYPE) $(DATA_DIR)/images/$(SEQ)/$(CHANNEL)/" $(MAKE) run-docker

tree:
	CHANNEL="red" $(MAKE) tree-by-channel
	CHANNEL="green" $(MAKE) tree-by-channel
	CHANNEL="blue" $(MAKE) tree-by-channel
	CHANNEL="full" $(MAKE) tree-by-channel
	CHANNEL="red_green" $(MAKE) tree-by-channel
	CHANNEL="red_blue" $(MAKE) tree-by-channel
	CHANNEL="green_blue" $(MAKE) tree-by-channel
	CHANNEL="gray_r" $(MAKE) tree-by-channel
	CHANNEL="gray_g" $(MAKE) tree-by-channel
	CHANNEL="gray_b" $(MAKE) tree-by-channel
	CHANNEL="gray_max" $(MAKE) tree-by-channel
	CHANNEL="gray_mean" $(MAKE) tree-by-channel

run: | sanitize matches tree

experiments:
	SEQ="orthologs_cytoglobin" TYPE="N" $(MAKE) run
	SEQ="orthologs_myoglobin" TYPE="N" $(MAKE) run
	SEQ="orthologs_neuroglobin" TYPE="N" $(MAKE) run
	SEQ="orthologs_androglobin" TYPE="N" $(MAKE) run
	SEQ="orthologs_hemoglobin_beta" TYPE="N" $(MAKE) run
	SEQ="indelible" TYPE="N" $(MAKE) run

cluster:
	CMD="bash run_blast.sh 11" DOCKER_FLAGS="-w $(APP_DIR)" $(MAKE) run-docker
	SEQ="indelible" TYPE="N" $(MAKE) matches
	SEQ="orthologs_androglobin" TYPE="N" $(MAKE) matches
	SEQ="orthologs_cytoglobin" TYPE="N" $(MAKE) matches
	SEQ="orthologs_myoglobin" TYPE="N" $(MAKE) matches
	SEQ="orthologs_neuroglobin" TYPE="N" $(MAKE) matches
	SEQ="orthologs_hemoglobin_beta" TYPE="N" $(MAKE) matches
	CMD="python clusterize.py" DOCKER_FLAGS="-w $(APP_DIR)" $(MAKE) run-docker
