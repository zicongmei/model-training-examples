import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.applications import ResNet50
from tensorflow.keras.layers import Dense, Flatten, Dropout
from tensorflow.keras.models import Model
import numpy as np
import scipy # Import scipy for ImageDataGenerator's internal operations
import time # Import the time module for logging durations
import os # Import os for path operations

print("TensorFlow version:", tf.__version__)
print("Number of GPUs available:", len(tf.config.list_physical_devices('GPU')))

# Load the CIFAR-100 dataset
print(f"[{time.ctime()}] Starting CIFAR-100 dataset download...")
download_start_time = time.time()
(train_images, train_labels), (test_images, test_labels) = keras.datasets.cifar100.load_data()
download_end_time = time.time()
download_duration = download_end_time - download_start_time
print(f"[{time.ctime()}] CIFAR-100 dataset download completed in {download_duration:.2f} seconds.")


# Normalize pixel values
train_images, test_images = train_images / 255.0, test_images / 255.0

# Define data augmentation
datagen = keras.preprocessing.image.ImageDataGenerator(
    rotation_range=15,
    width_shift_range=0.1,
    height_shift_range=0.1,
    horizontal_flip=True,
    zoom_range=0.1
)

# Load the pre-trained ResNet50 model without the top classification layer
# We use the 'imagenet' weights as a starting point (transfer learning)
base_model = ResNet50(weights='imagenet', include_top=False, input_shape=(32, 32, 3))

# Freeze the base model layers
for layer in base_model.layers:
    layer.trainable = False

# Add new classification layers for CIFAR-100
x = base_model.output
x = Flatten()(x)
x = Dense(512, activation='relu')(x)
x = Dropout(0.5)(x)
predictions = Dense(100, activation='softmax')(x)

# Create the final model
model = Model(inputs=base_model.input, outputs=predictions)

# Compile the model
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# Train the model for 15 epochs with data augmentation
print(f"[{time.ctime()}] Starting model training (ResNet-50 on CIFAR-100)...")
training_start_time = time.time()
model.fit(datagen.flow(train_images, train_labels, batch_size=64),
          epochs=15,
          validation_data=(test_images, test_labels))
training_end_time = time.time()
training_duration = training_end_time - training_start_time
print(f"[{time.ctime()}] Model training completed in {training_duration:.2f} seconds.")

# Evaluate the model
test_loss, test_acc = model.evaluate(test_images, test_labels, verbose=2)
print('Test accuracy:', test_acc)

# Define the path where the model will be saved
MODEL_SAVE_PATH = "/output/resnet_cifar100.h5"

# Save the trained model
os.makedirs(os.path.dirname(MODEL_SAVE_PATH), exist_ok=True) # Ensure the output directory exists
model.save(MODEL_SAVE_PATH)
print(f"Model saved as {MODEL_SAVE_PATH}")