# build.tcl
# Command - vivado -mode batch -source build.tcl
# Open project

set proj_name "UART_Interface"
open_project ../../$proj_name/${proj_name}.xpr

# Run synthesis (includes IPs automatically)
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_runs synth_1

# Run implementation
reset_run impl_1
launch_runs impl_1 -jobs 4
wait_on_runs impl_1

# Generate bitstream
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_runs impl_1

write_cfgmem -force -format mcs -size 16 -interface SPIx4 -loadbit {up 0x00000000 "../../UART_Interface/UART_Interface.runs/impl_1/UART_Interface_top.bit" } -file "../../UART_Interface/UART_Interface.runs/impl_1/UART_Interface_top.mcs"

# Optionally, close project
close_project
