@echo off
echo Starting Dyslexia Detection API...

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate

REM Install dependencies
echo Installing dependencies...
pip install -r requirements.txt

REM Check if model exists
if not exist "\backend\model\dyslexia_model.pth" (
    echo WARNING: Model file not found at model\dyslexia_model.pth
    echo Please place your trained model in the model directory
    exit /b 1
)

REM Start the server
echo Starting FastAPI server...
python main.py
