# source D:/Master/S2/LPSC/Pratique/Projet/Mandelbrot/ips/hw/simu_mandelbrot.tcl


restart

add_wave {{/mandelbrot_pinout/BramVideoMemoryxI/inst/\native_mem_module.blk_mem_gen_v8_4_4_inst /wea_i}} 

add_force {/mandelbrot_pinout/ClkSys100MhzxCI} -radix hex {0 0ns} {1 5ns} -repeat_every 10ns
add_force {/mandelbrot_pinout/ClkMandelxC} -radix hex {0 0ns} {1 5000ps} -repeat_every 10000ps

add_force {/mandelbrot_pinout/ResetxRNI} -radix hex {1 0ns}
add_force {/mandelbrot_pinout/PllNotLockedxS} -radix hex {1 0ns}

run 20 ns
add_force {/mandelbrot_pinout/ResetxRNI} -radix hex {0 0ns}
add_force {/mandelbrot_pinout/PllNotLockedxS} -radix hex {0 0ns}

run 400 ns
run 400000ns
