# source D:/Master/S2/LPSC/Pratique/Projet/Mandelbrot/ips/hw/c_gen/c_gen_simu.tcl


restart

#add_force {/c_gen/nextValue} -radix hex {0 0ns} {1 20ns} -repeat_every 40ns
add_force {/c_gen/nextValue} -radix hex {1 0ns} {0 10000ps} -repeat_every 100000ps

add_force {/c_gen/ClkxC} -radix hex {0 0ns} {1 5ns} -repeat_every 10ns
add_force {/c_gen/RstxRA} -radix hex {1 0ns}

add_force {/c_gen/ZoomInxSI} -radix hex {0 0ns}
add_force {/c_gen/ZoomOutxSI} -radix hex {0 0ns}


run 20 ns



add_force {/c_gen/RstxRA} -radix hex {0 0ns}

# 0x3ff = 1023 => 1024 pixel
#run 10300 ns

run 200 ns