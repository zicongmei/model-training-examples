#!/bin/bash

# Define the input and output file names
TRAIN_SCRIPT_FILE="resources/train.py"
TEMPLATE_FILE="resources/job.yaml.tmpl"
OUTPUT_FILE="output/training-job.yaml"
GLOBAL_VARS_FILE="../global_variables.json" # Path to global variables

# Check if the training script exists
if [ ! -f "$TRAIN_SCRIPT_FILE" ]; then
    echo "Error: Training script '$TRAIN_SCRIPT_FILE' not found!"
    exit 1
fi

# Check if global variables file exists
if [ ! -f "$GLOBAL_VARS_FILE" ]; then
    echo "Error: Global variables file '$GLOBAL_VARS_FILE' not found!"
    exit 1
fi

# Read global variables using jq
# Ensure jq is installed: sudo apt-get install jq
BUCKET=$(jq -r '.bucket' "$GLOBAL_VARS_FILE")
K8S_SERVICE_ACCOUNT=$(jq -r '.k8s_service_account_name' "$GLOBAL_VARS_FILE")
K8S_NAMESPACE=$(jq -r '.k8s_namespace' "$GLOBAL_VARS_FILE")

if [ -z "$BUCKET" ] || [ -z "$K8S_SERVICE_ACCOUNT" ] || [ -z "$K8S_NAMESPACE" ]; then
    echo "Error: Could not read 'bucket', 'k8s_service_account_name', or 'k8s_namespace' from $GLOBAL_VARS_FILE"
    exit 1
fi

# Generate timestamp in YYYYMMDDHHMMSS format
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# The indentation level required for the script in the YAML
INDENTATION="    "

# Read the Python script, add the correct indentation to each line,
# and store it in a variable, escaping newlines.
# Using 'sed s/^/$INDENTATION/g' to add indentation to each line.
# The 'awk' command then joins the lines and escapes newlines.
ESCAPED_SCRIPT=$(sed "s/^/$INDENTATION/" "$TRAIN_SCRIPT_FILE" | awk 'BEGIN{ORS=""} {print $0 "\\n"}' | sed 's/\\n$//')

mkdir -p output # Ensure output directory exists

# Use sed to replace the placeholder in the template with the script content,
# and then replace GCS_BUCKET, K8S_SERVICE_ACCOUNT_NAME, K8S_NAMESPACE, and TIMESTAMP.
# Using a pipe '|' as the delimiter for the substitution command to avoid
# conflicts with characters like '/' or '&' in the script or bucket name.
sed "s|<<<TRAINING_SCRIPT>>>|$ESCAPED_SCRIPT|" "$TEMPLATE_FILE" | \
sed "s|<<<GCS_BUCKET>>>|$BUCKET|" | \
sed "s|<<<K8S_SERVICE_ACCOUNT_NAME>>>|$K8S_SERVICE_ACCOUNT|" | \
sed "s|<<<K8S_NAMESPACE>>>|$K8S_NAMESPACE|" | \
sed "s|<<<TIMESTAMP>>>|$TIMESTAMP|" > "$OUTPUT_FILE"

echo "Successfully generated Kubernetes YAML file: $OUTPUT_FILE"
echo "Model will be saved to gs://${BUCKET}/models/${TIMESTAMP}/fashion_mnist_cnn.pt"

# Optional: Uncomment to apply the manifest automatically
kubectl delete -f $OUTPUT_FILE --ignore-not-found
kubectl apply -f $OUTPUT_FILE