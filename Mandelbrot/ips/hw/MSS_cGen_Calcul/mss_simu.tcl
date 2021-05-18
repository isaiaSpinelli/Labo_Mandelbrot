# source D:/Master/S2/LPSC/Pratique/Projet/Mandelbrot/ips/hw/MSS_cGen_Calcul/mss_simu.tcl

# ready to ready_reg !

restart



add_force {/mss_cgen_calcul/clk} -radix hex {0 0ns} {1 5ns} -repeat_every 10ns
add_force {/mss_cgen_calcul/rst} -radix hex {1 0ns}
add_force {/mss_cgen_calcul/ready} -radix hex {0 0ns}


run 20 ns
add_force {/mss_cgen_calcul/rst} -radix hex {0 0ns}
run 40 ns


add_force {/mss_cgen_calcul/ready} -radix hex {1 0ns}

run 15 ns

add_force {/mss_cgen_calcul/ready} -radix hex {0 0ns}

run 200 ns

add_force {/mss_cgen_calcul/ready} -radix hex {1 0ns}

run 15 ns

add_force {/mss_cgen_calcul/ready} -radix hex {0 0ns}

run 200 ns