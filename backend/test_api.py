import requests
import sys

def test_health():
    """Test health endpoint"""
    try:
        response = requests.get("http://localhost:8000/health")
        print(f"Health Check: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Health check failed: {e}")
        return False

def test_predict(image_path):
    """Test prediction endpoint"""
    try:
        with open(image_path, 'rb') as f:
            files = {'file': f}
            response = requests.post("http://localhost:8000/predict", files=files)
        
        print(f"\nPrediction: {response.status_code}")
        print(f"Response: {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Prediction test failed: {e}")
        return False

if __name__ == "__main__":
    print("Testing Dyslexia Detection API\n")
    print("=" * 50)
    
    # Test health
    if test_health():
        print("✓ Health check passed")
    else:
        print("✗ Health check failed")
        sys.exit(1)
    
    # Test prediction if image path provided
    if len(sys.argv) > 1:
        image_path = sys.argv[1]
        print("\n" + "=" * 50)
        if test_predict(image_path):
            print("✓ Prediction test passed")
        else:
            print("✗ Prediction test failed")
    else:
        print("\nTo test prediction, run:")
        print("python test_api.py path/to/test_image.jpg")
