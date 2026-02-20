from PIL import Image
import numpy as np
import time

W = 64
H = 64

def equalize_img(input_hex_path, output_hex_path):
    time_start = time.time()

    # Store data from hex file
    data = []
    with open (input_hex_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('//'):
                hex_val = line.split()[0]
                data.append(int(hex_val, 16))
    data = np.array(data, dtype = np.int64)

    # Histogram Equalization
    # CDF
    histogram = np.bincount(data, minlength = 256)
    cdf = histogram.cumsum().astype(np.int64)
    cdf_min = cdf[cdf > 0].min()
    total_pixel = W * H

    # Calculate
    den = total_pixel - cdf_min
    if den <= 0: den = 1
    K = (255 * 65536) // den # / chia lấy số thực, // chia lấy phần nguyên
    #mul_res = ((cdf - cdf_min) * K)

    # Mapping
    lut = (((cdf - cdf_min) * K) + 32768) >> 16
    lut = np.clip(lut, 0, 255).astype(np.uint8) 
    map_data = lut[data]

    # Save equalized image
    final_img = Image.fromarray(map_data.reshape((H, W)))
    final_img.save('py_output_img.png')
    print("Equalized image saved to py_output_img.png.")

    # Save equalized hex data
    with open(output_hex_path, 'w') as f:
        for val in map_data:
            f.write("{:02x}\n".format(val))

    print(f"Equalized hex data saved to {output_hex_path} with {len(map_data)} lines of hex values.")

    time_end = time.time()
    print(f"Equalization completed in {time_end - time_start:.2f} seconds.")
    
try:
    equalize_img('img_in.mem', 'hist_py_out.mem')
except FileNotFoundError:
    print("Error: File not found.")