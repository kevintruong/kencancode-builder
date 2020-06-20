#!/usr/bin/env bash


command=$1
tf_build_prefix_env=$2

export TF_PROJECT_PREFIX=${tf_build_prefix_env}
mkdir -p ${TF_PROJECT_PREFIX}
rm -rf backend_*.tf
envsubst < ./temp/backend_gcs_temp.tf > backend_conf_${TF_PROJECT_PREFIX}.tf;
echo run "terraform init -backend-config=./backend_conf_${TF_PROJECT_PREFIX}.tf"
terraform init -backend-config=./backend_conf_${TF_PROJECT_PREFIX}.tf ;

terraform plan -var prefix=$TF_PROJECT_PREFIX
terraform $command -var prefix=$TF_PROJECT_PREFIX
