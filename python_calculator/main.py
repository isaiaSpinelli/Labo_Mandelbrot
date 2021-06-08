# Spinelli Isaia
# LPSC - mandelbrot

# ----- CONSTANTES -----

ITER_MAX = 100
RADIUS_MAX  = 2

C_RE = 0.00390625
C_IM = 0.31640625


def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print(f'Hi, {name}')  # Press Ctrl+F8 to toggle the breakpoint.


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print_hi('PyCharm')

    z_real = 0
    z_imag = 0

    for i in range(ITER_MAX):
        z_real = (z_real ** 2) - (z_imag ** 2) + (C_RE)
        z_imag = (2 * z_imag * z_real) + C_IM
        print("it n°", i, " : z_real = ", z_real, " (", float.hex(z_real),
              ") // z_imag = ", z_imag, " (", float.hex(z_imag), ")")

        if ((z_real ** 2 + z_imag ** 2) >= (RADIUS_MAX ** 2)):
            print("\n after ", i, "bigger than radius")
            break
