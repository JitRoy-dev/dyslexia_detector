import torch
import torch.nn as nn

# Load the model architecture
class DyslexiaModel(nn.Module):
    def __init__(self, hidden_size=256):
        super(DyslexiaModel, self).__init__()
        
        self.cnn = nn.Sequential(
            nn.Conv2d(1, 64, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2, 2),
            nn.Conv2d(64, 128, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2, 2),
            nn.Conv2d(128, 256, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.Conv2d(256, 256, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d((2, 1)),
            nn.Conv2d(256, 512, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.BatchNorm2d(512),
            nn.Conv2d(512, 512, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.BatchNorm2d(512),
            nn.MaxPool2d((2, 1)),
            nn.Conv2d(512, 512, kernel_size=2, padding=0),
            nn.ReLU()
        )
        
        self.map_to_sequence = nn.Linear(1536, hidden_size)

# Test different input sizes
model = DyslexiaModel()
model.eval()

print("Testing different input sizes to find the correct one:\n")
print("="*80)

# Common image sizes to test
test_sizes = [
    (32, 128),   # Common for text/handwriting
    (64, 256),
    (32, 256),
    (64, 512),
    (128, 512),
]

for height, width in test_sizes:
    try:
        x = torch.randn(1, 1, height, width)
        cnn_out = model.cnn(x)
        batch, channels, h, w = cnn_out.size()
        
        # Reshape like in forward pass
        x_reshaped = cnn_out.permute(0, 3, 1, 2)
        x_reshaped = x_reshaped.reshape(batch, w, channels * h)
        
        print(f"Input: {height}x{width}")
        print(f"  CNN output shape: {cnn_out.shape}")
        print(f"  After reshape: {x_reshaped.shape}")
        print(f"  Features per position: {channels * h}")
        
        if channels * h == 1536:
            print(f"  ✓ CORRECT SIZE! Use {height}x{width}")
        else:
            print(f"  ✗ Wrong size (expected 1536)")
        print()
        
    except Exception as e:
        print(f"Input: {height}x{width} - Error: {e}\n")

print("="*80)
