# model-training-examples

## Prerequisits

### 1. Provision a bucket if not exists

```
cat << EOF > terraform_bucket/terraform.tfvars
project_id          = "<GCP project id>"
EOF

pushd terraform_bucket
terraform init
terraform apply
popd
```

### 1. Write a globla variable file

Info for uploading the model

```
cat <<EOF >global_variables.json
{
    "bucket": "<bucket name>",
    "k8s_namespace": "default",
    "k8s_service_account_name": "training"
}
EOF
```

### 1. Provision GKE cluster

```
cat << EOF > terraform_cluster/terraform.tfvars
project_id   = "<GCP project id>"

# Following items are optional
# cluster_name = "gpu-cluster-2"
# region       = "us-west1"
# zone         = "us-west1-a"
# gpc_node_size= 1

EOF

pushd terraform_cluster
terraform init
terraform apply
popd
```

