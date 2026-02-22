#!/bin/bash

echo "Starting Dyslexia Detection API..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Check if model exists
if [ ! -f "model/dyslexia_model.pth" ]; then
    echo "WARNING: Model file not found at model/dyslexia_model.pth"
    echo "Please place your trained model in the model directory"
    exit 1
fi

# Start the server
echo "Starting FastAPI server..."
python main.py
