def compare (file1, file2):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        line1 = f1.readlines()
        line2 = f2.readlines()
    
    err = 0
    for i, (l1, l2) in enumerate(zip(line1, line2)):
        if l1.strip() != l2.strip():
            print(f"Different at line {i}: Python = {l1.strip()}, Verilog = {l2.strip()}")
            err += 1

    if err == 0:
        print (f"YAY! PERFECT MATCH!")
    else:
        print (f"ERROR! TOTAL {err} MISMATCHED PIXELS.")

compare ("gau_py_out.mem", "gau_v_out.mem")