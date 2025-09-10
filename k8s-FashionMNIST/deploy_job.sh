#!/bin/bash

# Define the input and output file names
TRAIN_SCRIPT_FILE="train.py"
TEMPLATE_FILE="job.yaml.tmpl"
OUTPUT_FILE="training-job.yaml"



# Check if the training script exists
if [ ! -f "$TRAIN_SCRIPT_FILE" ]; then
    echo "Error: Training script '$TRAIN_SCRIPT_FILE' not found!"
    exit 1
fi

# The indentation level required for the script in the YAML
INDENTATION="    "

# Read the Python script, add the correct indentation to each line,
# and store it in a variable, escaping newlines.
# Using 'sed s/^/$INDENTATION/g' to add indentation to each line.
# The 'awk' command then joins the lines and escapes newlines.
ESCAPED_SCRIPT=$(sed "s/^/$INDENTATION/" "$TRAIN_SCRIPT_FILE" | awk 'BEGIN{ORS=""} {print $0 "\\n"}' | sed 's/\\n$//')

# Use sed to replace the placeholder in the template with the script content.
# Using a pipe '|' as the delimiter for the substitution command to avoid
# conflicts with characters like '/' or '&' in the script.
sed "s|<<<TRAINING_SCRIPT>>>|$ESCAPED_SCRIPT|" "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "Successfully generated Kubernetes YAML file: $OUTPUT_FILE"

kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.17.4/deployments/static/nvidia-device-plugin.yml

# Optional: Uncomment to apply the manifest automatically
kubectl apply -f $OUTPUT_FILE