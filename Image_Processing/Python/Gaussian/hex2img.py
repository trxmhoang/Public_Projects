import os
import sys
import time
import numpy as np
from PIL import Image

W = 256
H = 256

def hex2image(hex_path, img_path):
    time_start = time.time()

    # Check if hex file exists
    if not os.path.exists(hex_path):
        print(f"Error: File {hex_path} does not exist.")
        return
    
    pixel = []
    err_cnt = 0

    with open(hex_path, 'r') as f:
        lines = f.readlines()
    
    if len(lines) == 0:
        print("Error: Hex file is empty.")
        return
    
    print(f"Total lines read from hex file: {len(lines)}.")

    # Process each line
    for i, line in enumerate(lines):
        line = line.strip()
        if not line: continue

        try:
            val = int(line, 16)
            pixel.append(val)
        except ValueError:
            pixel.append(0)
            err_cnt += 1

            if err_cnt <= 5:
                print(f"Warning: Line {i+1} is not a valid hex number: '{line}'. Replaced with 0.")
    
    if err_cnt > 0:
        print(f"Total invalid lines encountered: {err_cnt}. They have been replaced with 0.")

    # Check if we have the correct number of pixels
    expected_size = W * H
    actual_size = len(pixel)
    
    if actual_size < expected_size:
        missing = expected_size - actual_size
        print(f"Warning: Hex file has {actual_size} pixels, expected {expected_size}. Padding with zeros.")
        pixel += [0] * missing
    elif actual_size > expected_size:
        print(f"Warning: Hex file has {actual_size} pixels, expected {expected_size}. Truncating excess data.")
        pixel = pixel[:expected_size]
    else:
        print("Hex file has the correct number of pixels.")

    try:
        arr = np.array(pixel, dtype = np.uint8).reshape((H, W))
        img = Image.fromarray(arr)
        img.save(img_path)
        print(f"Image saved to {img_path}.")
    except Exception as e:
        print(f"Error: Failed to create image. {e}")
        return

    time_end = time.time()
    print(f"Time taken to read and process hex file: {time_end - time_start:.2f} seconds.")

hex2image('gau_py_out.mem', 'gau_py_out.png')
hex2image('gau_v_out.mem', 'gau_v_out.png')