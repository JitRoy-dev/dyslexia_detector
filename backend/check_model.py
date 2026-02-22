import torch

# Load the model file and inspect its structure
model_path = "/backend/model/dyslexia_model.pth"

print("Loading model file...")
state_dict = torch.load(model_path, map_location='cpu')

print("\n" + "="*80)
print("MODEL STRUCTURE")
print("="*80)

# Check if it's a state_dict or full model
if isinstance(state_dict, dict):
    print("\nThis is a state_dict (weights only)")
    print(f"\nNumber of layers: {len(state_dict)}")
    print("\nLayer names and shapes:")
    print("-"*80)
    for key, value in state_dict.items():
        if hasattr(value, 'shape'):
            print(f"{key:50s} {str(value.shape):30s}")
        else:
            print(f"{key:50s} {type(value)}")
else:
    print("\nThis is a full model object")
    print(f"Model type: {type(state_dict)}")
    print(f"\nModel architecture:\n{state_dict}")

print("\n" + "="*80)
