set_property -dict {PACKAGE_PIN R2 IOSTANDARD SSTL135} [get_ports clk_100mhz]
create_clock -period 10.000 -name sys_clk_100mhz -waveform {0.000 5.000} -add [get_ports clk_100mhz]
create_generated_clock -name baud_clk -source [get_ports clk_100mhz] -divide_by 54 [get_pins uart0_inst/baud_gen/_clk_out_reg/Q]

set_input_delay -clock sys_clk_100mhz -max 1.1 [get_ports * -filter {DIRECTION == IN && NAME !~ "*clk*"}]
set_input_delay -clock sys_clk_100mhz -min 0.5 [get_ports * -filter {DIRECTION == IN && NAME !~ "*clk*"}]

set_output_delay -clock sys_clk_100mhz -max 0 [all_outputs]
set_output_delay -clock sys_clk_100mhz -min 100 [all_outputs]

set_false_path -to [all_outputs]

