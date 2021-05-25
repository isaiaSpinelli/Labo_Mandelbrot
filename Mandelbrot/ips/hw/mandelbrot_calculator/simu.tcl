# source D:/Master/S2/LPSC/Pratique/P/Mandelbrot/ips/hw/mandelbrot_calculator/simu.tcl

# ready to ready_reg !

restart

add_force {/mandelbrot_calculator/clk} -radix hex {0 0ns} {1 5ns} -repeat_every 10ns
add_force {/mandelbrot_calculator/rst} -radix hex {1 0ns}



add_force {/mandelbrot_calculator/start} -radix hex {0 0ns}
# test with C_re = 0.5 -> 0000100000000000
# 0xe950 (14.58203125) -> 1110100101010000
add_force {/mandelbrot_calculator/c_real} -radix bin {1110100101010000 0ns}
# test with C_Im = 0.5 -> 0000100000000000
# 0x0786 (0.47021484375) -> 0000011110000110
add_force {/mandelbrot_calculator/c_imaginary} -radix bin {0000011110000110 0ns}


#add_force {/mandelbrot_calculator/ready} -radix hex {0 0ns}
#add_force {/mandelbrot_calculator/finished} -radix hex {0 0ns}

run 20 ns



add_force {/mandelbrot_calculator/rst} -radix hex {0 0ns}

run 20 ns

add_force {/mandelbrot_calculator/start} -radix hex {1 0ns}

run 20 ns

add_force {/mandelbrot_calculator/start} -radix hex {0 0ns}

run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
run 20 ns
