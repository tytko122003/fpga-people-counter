create_clock -period 10.000 -name sys_clk_pin -waveform {0 5.000} [get_ports clk]
# Zegar 100 MHz
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Przyciski
set_property PACKAGE_PIN T18 [get_ports btnU]
set_property IOSTANDARD LVCMOS33 [get_ports btnU]
set_property PACKAGE_PIN U17 [get_ports btnD]
set_property IOSTANDARD LVCMOS33 [get_ports btnD]

# Segmenty (od CA [seg 0] do CG [seg 6])
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

# Anody (od AN0 do AN3)
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

# Dioda alarmowa (LD15 na p³ytce)
set_property PACKAGE_PIN L1 [get_ports led_limit]
set_property IOSTANDARD LVCMOS33 [get_ports led_limit]

# Nowe przyciski do sekwencji (Lewy, Œrodkowy, Prawy)
set_property PACKAGE_PIN W19 [get_ports btnL]
set_property IOSTANDARD LVCMOS33 [get_ports btnL]

set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]

set_property PACKAGE_PIN T17 [get_ports btnR]
set_property IOSTANDARD LVCMOS33 [get_ports btnR]

# Dioda statusu blokady/awarii (LD14 na p³ytce)
set_property PACKAGE_PIN P1 [get_ports led_sec]
set_property IOSTANDARD LVCMOS33 [get_ports led_sec]

# Czujnik A (Zewnêtrzny) - Pierwszy od lewej w z³¹czu JA
set_property PACKAGE_PIN J1 [get_ports sensorA]
set_property IOSTANDARD LVCMOS33 [get_ports sensorA]

# Czujnik B (Wewnêtrzny) - Drugi od lewej w z³¹czu JA
set_property PACKAGE_PIN L2 [get_ports sensorB]
set_property IOSTANDARD LVCMOS33 [get_ports sensorB]

# Diody diagnostyczne do testowania czujników (LD0 i LD1)
set_property PACKAGE_PIN U16 [get_ports led_A]
set_property IOSTANDARD LVCMOS33 [get_ports led_A]

set_property PACKAGE_PIN E19 [get_ports led_B]
set_property IOSTANDARD LVCMOS33 [get_ports led_B]

