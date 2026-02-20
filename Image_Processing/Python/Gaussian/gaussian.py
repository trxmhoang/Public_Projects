import numpy as np

W = 512
H = 512
TOTAL_PIXEL = W*H
INPUT_HEX_FILE = 'hist_v_out.mem'
OUTPUT_HEX_FILE = 'gau_py_out.mem'

KERNEL_SUM = 16
KERNEL = np.array ([
    [1, 2, 1],
    [2, 4, 2],
    [1, 2, 1]
])

def hex2img (filename):
    try:
        with open (filename, 'r') as f:
            hex_data = [int(line.strip(), 16) for line in f if line.strip()]
        
        if len (hex_data) != TOTAL_PIXEL:
            print(f"Warning: File {filename} has {hex_data} pixels, but image has {TOTAL_PIXEL} pixels.")

            if len (hex_data) < TOTAL_PIXEL:
                hex_data += [0] * (TOTAL_PIXEL - len(hex_data))
            else:
                hex_data = hex_data[:TOTAL_PIXEL]
            
        img = np.array (hex_data, dtype = np.uint8).reshape ((H, W))
        print(f"Load image from {filename} successfully.")
        return img
    except FileNotFoundError:
        print("Error: Cannot find file {filename}. Have you run Equalization?")
        return None
    
def gaussian (img):
    img_h, img_w = img.shape
    output = np.zeros ((img_h, img_w), dtype=np.uint8)
    padded_img = np.pad (img, ((1,1), (1,1)), mode = 'constant', constant_values = 0)
    
    for r in range (img_h):
        for c in range (img_w):
            region = padded_img[r:r+3, c:c+3]
            acc = np.sum (region * KERNEL)
            pixel_out = (acc + 8) // 16
            output[r, c] = min (255, max (0, pixel_out))
    
    return output

def save_hex (filename, data):
    with open (filename, 'w') as f:
        for val in data.flatten():
            f.write (f'{val:02x}\n')
    print(f"Save output to {filename}.")

if __name__ == "__main__":
    input_img = hex2img (INPUT_HEX_FILE)
    if input_img is not None:
        output = gaussian (input_img)
        save_hex (OUTPUT_HEX_FILE, output)
        print ("Finish!")
