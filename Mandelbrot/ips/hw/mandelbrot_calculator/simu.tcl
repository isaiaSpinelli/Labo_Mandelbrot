# source D:/Master/S2/LPSC/Pratique/Projet/Mandelbrot/ips/hw/mandelbrot_calculator/simu.tcl

# ready to ready_reg !

restart

add_force {/mandelbrot_calculator/clk} -radix hex {0 0ns} {1 10000ps} -repeat_every 20000ps
add_force {/mandelbrot_calculator/rst} -radix hex {1 0ns}



add_force {/mandelbrot_calculator/start} -radix hex {0 0ns}
add_force {/mandelbrot_calculator/c_real} -radix bin {0000000000000001 0ns}
add_force {/mandelbrot_calculator/c_imaginary} -radix bin {0000000000000001 0ns}


add_force {/mandelbrot_calculator/ready} -radix hex {0 0ns}
add_force {/mandelbrot_calculator/finished} -radix hex {0 0ns}

run 20 ns



add_force {/mandelbrot_calculator/rst} -radix hex {0 0ns}

run 40 ns

add_force {/mandelbrot_calculator/start} -radix hex {1 0ns}

run 40 ns
run 40 ns
run 40 ns

