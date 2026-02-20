from PIL import Image
import numpy as np
import time

W = 512
H = 512

def image2hex(img_path, hex_path):
    time_start = time.time()

    img = Image.open(img_path).convert('L') # Convert to grayscale
    img = img.resize((W, H)) # Resize to 64x64
    data = np.array(img).flatten()

    with open(hex_path, 'w') as f:
        for pixel in data:
            f.write("{:02x}\n".format(pixel))
    
    time_end = time.time()
    print(f"Conversion completed in {time_end - time_start:.2f} seconds.")
    print(f"Hex data saved to {hex_path} with {len(data)} lines of hex values.")

try:
    image2hex('img_in.png', 'img_in.mem')
except FileNotFoundError:
    print("Error: input_img.png file not found.")