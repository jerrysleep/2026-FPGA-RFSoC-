set_property PACKAGE_PIN F10 [get_ports clk_50m]


set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets clk_wiz_0_inst/inst/clk_in1_clk_wiz_0]
 
 
set_property PACKAGE_PIN A9 [get_ports LMK04828_SYNC]
set_property PACKAGE_PIN A10 [get_ports LMK_dac_rst]
set_property PACKAGE_PIN C13 [get_ports LMK_dac_SDIO]
set_property PACKAGE_PIN A12 [get_ports LMK_dac_CS]
set_property PACKAGE_PIN B12 [get_ports LMK_dac_SCLK]

 
 
 
set_property PACKAGE_PIN F13 [get_ports si5341_csb]
set_property PACKAGE_PIN A13 [get_ports si5341_sdio]
set_property PACKAGE_PIN C11 [get_ports si5341_sclk]
set_property PACKAGE_PIN B11 [get_ports si5341_sdo]

 
set_property PACKAGE_PIN AJ16 [get_ports glblclkp]
set_property PACKAGE_PIN AJ15 [get_ports glblclkn]
set_property PACKAGE_PIN AJ17 [get_ports sysref_p]
set_property PACKAGE_PIN AK16 [get_ports sysref_n]




 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 



 
 


 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 


 
set_property PACKAGE_PIN AC17 [get_ports AGC_16DB_F]
set_property PACKAGE_PIN AE15 [get_ports AGC_1DB_F]
set_property PACKAGE_PIN AE13 [get_ports AGC_2DB_F]
set_property PACKAGE_PIN AD16 [get_ports AGC_4DB_F]
set_property PACKAGE_PIN AD15 [get_ports AGC_8DB_F]
set_property PACKAGE_PIN H11 [get_ports {CH_CHOOSE[0]}]
set_property PACKAGE_PIN K11 [get_ports {CH_CHOOSE[1]}]

set_property IOSTANDARD LVCMOS12 [get_ports AGC_16DB_F]
set_property IOSTANDARD LVCMOS12 [get_ports AGC_1DB_F]
set_property IOSTANDARD LVCMOS12 [get_ports AGC_2DB_F]
set_property IOSTANDARD LVCMOS12 [get_ports AGC_4DB_F]
set_property IOSTANDARD LVCMOS12 [get_ports AGC_8DB_F]
set_property IOSTANDARD LVCMOS33 [get_ports {CH_CHOOSE[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {CH_CHOOSE[1]}]


set_property PACKAGE_PIN C10 [get_ports uart_RF_de]
set_property PACKAGE_PIN C9 [get_ports uart_RF_re]
set_property PACKAGE_PIN D11 [get_ports uart_RF_rx]
set_property PACKAGE_PIN B10 [get_ports uart_RF_tx]

set_property PACKAGE_PIN D13 [get_ports FK422_RX]
set_property PACKAGE_PIN C14 [get_ports FK422_TX]

set_property PACKAGE_PIN H9 [get_ports TF_pc]
set_property PACKAGE_PIN F9 [get_ports TR_k]
set_property PACKAGE_PIN G10 [get_ports TF_pm]


set_property PACKAGE_PIN B13 [get_ports YC422_RX]
set_property PACKAGE_PIN A14 [get_ports YC422_TX]


set_property IOSTANDARD LVCMOS33 [get_ports uart_RF_de]
set_property IOSTANDARD LVCMOS33 [get_ports uart_RF_re]
set_property IOSTANDARD LVCMOS33 [get_ports uart_RF_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_RF_tx]

set_property IOSTANDARD LVCMOS33 [get_ports FK422_RX]
set_property IOSTANDARD LVCMOS33 [get_ports FK422_TX]
set_property IOSTANDARD LVCMOS33 [get_ports TF_pc]
set_property IOSTANDARD LVCMOS33 [get_ports TR_k]

 
 
 
 
 
 
 
 
 
 
 
 

set_property IOSTANDARD LVCMOS33 [get_ports TF_pm]
 
 
 
 
 
set_property IOSTANDARD LVCMOS33 [get_ports YC422_RX]
set_property IOSTANDARD LVCMOS33 [get_ports YC422_TX]






set_property IOSTANDARD LVCMOS33 [get_ports clk_50m]
create_clock -period 20.000 -name clk_50m [get_ports clk_50m]
set_input_jitter [get_clocks clk_50m] 0.010
set_property IOSTANDARD LVCMOS33 [get_ports LMK04828_SYNC]
set_property IOSTANDARD LVCMOS33 [get_ports LMK_dac_rst]
set_property IOSTANDARD LVCMOS33 [get_ports LMK_dac_SDIO]
set_property IOSTANDARD LVCMOS33 [get_ports LMK_dac_CS]
set_property IOSTANDARD LVCMOS33 [get_ports LMK_dac_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports si5341_csb]
set_property IOSTANDARD LVCMOS33 [get_ports si5341_sdio]
set_property IOSTANDARD LVCMOS33 [get_ports si5341_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports si5341_sdo]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports glblclkp]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports glblclkn]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports sysref_p]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports sysref_n]
create_clock -period 4.000 -name glblclkp -waveform {0.000 2.000} [get_ports glblclkp]
set_input_jitter [get_clocks glblclkp] 0.010

 
 
set_false_path -to [get_pins -hier -regexp {.*U5_Analysis_RadarParameter/.*_sys_reg.*\/D}]
 
 
 


