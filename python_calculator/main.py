import struct

import numpy as np

def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print(f'Hi, {name}')  # Press Ctrl+F8 to toggle the breakpoint.


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print_hi('PyCharm')

    num_iter = 100

    # 14.58203125 -  0.25
    c_real = 0.0234375
    # 0.47021484375 -  0.25
    c_imag = 0.12158203125
    z_real = 0
    z_imag = 0

    for i in range(num_iter):
        z_real_new = z_real ** 2 - z_imag ** 2 + c_real
        z_imag_new = z_imag * 2 * z_real + c_imag

        z_real = z_real_new
        z_imag = z_imag_new
        print("iteration n°", i, " : z_real = ", z_real, " (", float.hex(z_real),
              ") ; z_imag = ", z_imag, " (", float.hex(z_imag), ")")

        if ((z_real ** 2 + z_imag ** 2) >= 4):
            print("\n        after ", i, "bigger than radius")
            break
