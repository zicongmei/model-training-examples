# model-training-examples

## Prerequisits

- Provision GKE cluster

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

