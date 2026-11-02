`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


module cfg_si5341(
input        clk_1M,
input        sys_rst,
input        clk_50m,
   (* IOB="true" *)output reg   dac_sclk,
   (* IOB="true" *)output reg   dac_sden,
   (* IOB="true" *)output reg   dac_sdio,
input         dac_sdo,
output reg    dac_reset,

output reg    dac_cfg_done,

output        direction_ctl,
                   
output [7:0] dac_read_out1,
output [7:0] dac_read_out2,
output        dac_spi_rdy
);

wire        idle_flag;
wire [7:0]  data_read_out1;
wire [7:0]  data_read_out2;
wire [15:0] reg_addr;
wire [7:0]  config_value;
wire        start_spi;

 

assign dac_read_out1  = data_read_out1;
assign dac_read_out2  = data_read_out2;

 
reg clk_1M_reg0,clk_1M_reg1;
reg clk_1M_en;
reg clk_1M_en_nege;
always@(posedge clk_50m)
begin
  clk_1M_reg0 <= clk_1M;
  clk_1M_reg1 <= clk_1M_reg0;
  
  clk_1M_en<=clk_1M_reg0&&(~clk_1M_reg1);
  clk_1M_en_nege<=clk_1M_reg1&&(~clk_1M_reg0);
end 
 
 
localparam REG_NUMA = 6;                  
wire [7:0]    reg_cfg_valueA[REG_NUMA - 1:0];
wire [15:0]   reg_cfg_addrA[REG_NUMA - 1:0];
 
assign reg_cfg_addrA[0]   = 16'h0B24;   assign reg_cfg_valueA[0]   =8'hC0;
assign reg_cfg_addrA[1]   = 16'h0B25;   assign reg_cfg_valueA[1]   =8'h00;
assign reg_cfg_addrA[2]   = 16'h0502;   assign reg_cfg_valueA[2]   =8'h01; 
assign reg_cfg_addrA[3]   = 16'h0505;   assign reg_cfg_valueA[3]   =8'h03;
assign reg_cfg_addrA[4]   = 16'h0957;   assign reg_cfg_valueA[4]   =8'h17;
assign reg_cfg_addrA[5]   = 16'h0B4E;   assign reg_cfg_valueA[5]   =8'h1A;
 

 
 
 
 
 
 
localparam REG_NUMB = 384; 
wire [7:0]    reg_cfg_valueB[REG_NUMB - 1:0];
wire [15:0]   reg_cfg_addrB[REG_NUMB - 1:0];

assign reg_cfg_addrB[0]     = 16'h0006;   assign reg_cfg_valueB[0]    =8'h00;
assign reg_cfg_addrB[1]     = 16'h0007;   assign reg_cfg_valueB[1]    =8'h00;
assign reg_cfg_addrB[2]     = 16'h0008;   assign reg_cfg_valueB[2]    =8'h00;
assign reg_cfg_addrB[3]     = 16'h000B;   assign reg_cfg_valueB[3]    =8'h74;
assign reg_cfg_addrB[4]     = 16'h0017;   assign reg_cfg_valueB[4]    =8'hD0;
assign reg_cfg_addrB[5]     = 16'h0018;   assign reg_cfg_valueB[5]    =8'hFE;
assign reg_cfg_addrB[6]     = 16'h0021;   assign reg_cfg_valueB[6]    =8'h09;
assign reg_cfg_addrB[7]     = 16'h0022;   assign reg_cfg_valueB[7]    =8'h00;
assign reg_cfg_addrB[8]     = 16'h0023;   assign reg_cfg_valueB[8]    =8'hFE;
assign reg_cfg_addrB[9]     = 16'h0024;   assign reg_cfg_valueB[9]    =8'h0B;
assign reg_cfg_addrB[10]    = 16'h0025;   assign reg_cfg_valueB[10]   =8'h00;
assign reg_cfg_addrB[11]    = 16'h0026;   assign reg_cfg_valueB[11]   =8'h00;
assign reg_cfg_addrB[12]    = 16'h0027;   assign reg_cfg_valueB[12]   =8'h00;
assign reg_cfg_addrB[13]    = 16'h0028;   assign reg_cfg_valueB[13]   =8'h00;
assign reg_cfg_addrB[14]    = 16'h002B;   assign reg_cfg_valueB[14]   =8'h02;
assign reg_cfg_addrB[15]    = 16'h002C;   assign reg_cfg_valueB[15]   =8'h31;
assign reg_cfg_addrB[16]    = 16'h002D;   assign reg_cfg_valueB[16]   =8'h01;
assign reg_cfg_addrB[17]    = 16'h002E;   assign reg_cfg_valueB[17]   =8'h90;
assign reg_cfg_addrB[18]    = 16'h002F;   assign reg_cfg_valueB[18]   =8'h00;
assign reg_cfg_addrB[19]    = 16'h0030;   assign reg_cfg_valueB[19]   =8'h00;
assign reg_cfg_addrB[20]    = 16'h0031;   assign reg_cfg_valueB[20]   =8'h00;
assign reg_cfg_addrB[21]    = 16'h0032;   assign reg_cfg_valueB[21]   =8'h00;
assign reg_cfg_addrB[22]    = 16'h0033;   assign reg_cfg_valueB[22]   =8'h00;
assign reg_cfg_addrB[23]    = 16'h0034;   assign reg_cfg_valueB[23]   =8'h00;
assign reg_cfg_addrB[24]    = 16'h0035;   assign reg_cfg_valueB[24]   =8'h00;
assign reg_cfg_addrB[25]    = 16'h0036;   assign reg_cfg_valueB[25]   =8'h90;
assign reg_cfg_addrB[26]    = 16'h0037;   assign reg_cfg_valueB[26]   =8'h00;
assign reg_cfg_addrB[27]    = 16'h0038;   assign reg_cfg_valueB[27]   =8'h00;
assign reg_cfg_addrB[28]    = 16'h0039;   assign reg_cfg_valueB[28]   =8'h00;
assign reg_cfg_addrB[29]    = 16'h003A;   assign reg_cfg_valueB[29]   =8'h00;
assign reg_cfg_addrB[30]    = 16'h003B;   assign reg_cfg_valueB[30]   =8'h00;
assign reg_cfg_addrB[31]    = 16'h003C;   assign reg_cfg_valueB[31]   =8'h00;
assign reg_cfg_addrB[32]    = 16'h003D;   assign reg_cfg_valueB[32]   =8'h00;
assign reg_cfg_addrB[33]    = 16'h0041;   assign reg_cfg_valueB[33]   =8'h05;
assign reg_cfg_addrB[34]    = 16'h0042;   assign reg_cfg_valueB[34]   =8'h00;
assign reg_cfg_addrB[35]    = 16'h0043;   assign reg_cfg_valueB[35]   =8'h00;
assign reg_cfg_addrB[36]    = 16'h0044;   assign reg_cfg_valueB[36]   =8'h00;
assign reg_cfg_addrB[37]    = 16'h009E;   assign reg_cfg_valueB[37]   =8'h00;
assign reg_cfg_addrB[38]    = 16'h0102;   assign reg_cfg_valueB[38]   =8'h01;
assign reg_cfg_addrB[39]    = 16'h0108;   assign reg_cfg_valueB[39]   =8'h02;
assign reg_cfg_addrB[40]    = 16'h0109;   assign reg_cfg_valueB[40]   =8'h09;
assign reg_cfg_addrB[41]    = 16'h010A;   assign reg_cfg_valueB[41]   =8'h33;
assign reg_cfg_addrB[42]    = 16'h010B;   assign reg_cfg_valueB[42]   =8'h08;
assign reg_cfg_addrB[43]    = 16'h010D;   assign reg_cfg_valueB[43]   =8'h01;
assign reg_cfg_addrB[44]    = 16'h010E;   assign reg_cfg_valueB[44]   =8'h09;
assign reg_cfg_addrB[45]    = 16'h010F;   assign reg_cfg_valueB[45]   =8'h3B;
assign reg_cfg_addrB[46]    = 16'h0110;   assign reg_cfg_valueB[46]   =8'h28;
assign reg_cfg_addrB[47]    = 16'h0112;   assign reg_cfg_valueB[47]   =8'h02;
assign reg_cfg_addrB[48]    = 16'h0113;   assign reg_cfg_valueB[48]   =8'h09;
assign reg_cfg_addrB[49]    = 16'h0114;   assign reg_cfg_valueB[49]   =8'h33;
assign reg_cfg_addrB[50]    = 16'h0115;   assign reg_cfg_valueB[50]   =8'h08;
assign reg_cfg_addrB[51]    = 16'h0117;   assign reg_cfg_valueB[51]   =8'h01;
assign reg_cfg_addrB[52]    = 16'h0118;   assign reg_cfg_valueB[52]   =8'h09;
assign reg_cfg_addrB[53]    = 16'h0119;   assign reg_cfg_valueB[53]   =8'h3B;
assign reg_cfg_addrB[54]    = 16'h011A;   assign reg_cfg_valueB[54]   =8'h28;
assign reg_cfg_addrB[55]    = 16'h011C;   assign reg_cfg_valueB[55]   =8'h01;
assign reg_cfg_addrB[56]    = 16'h011D;   assign reg_cfg_valueB[56]   =8'h09;
assign reg_cfg_addrB[57]    = 16'h011E;   assign reg_cfg_valueB[57]   =8'h3B;
assign reg_cfg_addrB[58]    = 16'h011F;   assign reg_cfg_valueB[58]   =8'h28;
assign reg_cfg_addrB[59]    = 16'h0121;   assign reg_cfg_valueB[59]   =8'h02;
assign reg_cfg_addrB[60]    = 16'h0122;   assign reg_cfg_valueB[60]   =8'h09;
assign reg_cfg_addrB[61]    = 16'h0123;   assign reg_cfg_valueB[61]   =8'h33;
assign reg_cfg_addrB[62]    = 16'h0124;   assign reg_cfg_valueB[62]   =8'h09;
assign reg_cfg_addrB[63]    = 16'h0126;   assign reg_cfg_valueB[63]   =8'h01;
assign reg_cfg_addrB[64]    = 16'h0127;   assign reg_cfg_valueB[64]   =8'h09;
assign reg_cfg_addrB[65]    = 16'h0128;   assign reg_cfg_valueB[65]   =8'h3B;
assign reg_cfg_addrB[66]    = 16'h0129;   assign reg_cfg_valueB[66]   =8'h28;
assign reg_cfg_addrB[67]    = 16'h012B;   assign reg_cfg_valueB[67]   =8'h01;
assign reg_cfg_addrB[68]    = 16'h012C;   assign reg_cfg_valueB[68]   =8'h09;
assign reg_cfg_addrB[69]    = 16'h012D;   assign reg_cfg_valueB[69]   =8'h3B;
assign reg_cfg_addrB[70]    = 16'h012E;   assign reg_cfg_valueB[70]   =8'h28;
assign reg_cfg_addrB[71]    = 16'h0130;   assign reg_cfg_valueB[71]   =8'h01;
assign reg_cfg_addrB[72]    = 16'h0131;   assign reg_cfg_valueB[72]   =8'h09;
assign reg_cfg_addrB[73]    = 16'h0132;   assign reg_cfg_valueB[73]   =8'h3B;
assign reg_cfg_addrB[74]    = 16'h0133;   assign reg_cfg_valueB[74]   =8'h28;
assign reg_cfg_addrB[75]    = 16'h013A;   assign reg_cfg_valueB[75]   =8'h01;
assign reg_cfg_addrB[76]    = 16'h013B;   assign reg_cfg_valueB[76]   =8'h09;
assign reg_cfg_addrB[77]    = 16'h013C;   assign reg_cfg_valueB[77]   =8'h3B;
assign reg_cfg_addrB[78]    = 16'h013D;   assign reg_cfg_valueB[78]   =8'h28;
assign reg_cfg_addrB[79]    = 16'h013F;   assign reg_cfg_valueB[79]   =8'h00;
assign reg_cfg_addrB[80]    = 16'h0140;   assign reg_cfg_valueB[80]   =8'h00;
assign reg_cfg_addrB[81]    = 16'h0141;   assign reg_cfg_valueB[81]   =8'h40;
assign reg_cfg_addrB[82]    = 16'h0206;   assign reg_cfg_valueB[82]   =8'h00;
assign reg_cfg_addrB[83]    = 16'h0208;   assign reg_cfg_valueB[83]   =8'h01;
assign reg_cfg_addrB[84]    = 16'h0209;   assign reg_cfg_valueB[84]   =8'h00;
assign reg_cfg_addrB[85]    = 16'h020A;   assign reg_cfg_valueB[85]   =8'h00;
assign reg_cfg_addrB[86]    = 16'h020B;   assign reg_cfg_valueB[86]   =8'h00;
assign reg_cfg_addrB[87]    = 16'h020C;   assign reg_cfg_valueB[87]   =8'h00;
assign reg_cfg_addrB[88]    = 16'h020D;   assign reg_cfg_valueB[88]   =8'h00;
assign reg_cfg_addrB[89]    = 16'h020E;   assign reg_cfg_valueB[89]   =8'h01;
assign reg_cfg_addrB[90]    = 16'h020F;   assign reg_cfg_valueB[90]   =8'h00;
assign reg_cfg_addrB[91]    = 16'h0210;   assign reg_cfg_valueB[91]   =8'h00;
assign reg_cfg_addrB[92]    = 16'h0211;   assign reg_cfg_valueB[92]   =8'h00;
assign reg_cfg_addrB[93]    = 16'h0212;   assign reg_cfg_valueB[93]   =8'h00;
assign reg_cfg_addrB[94]    = 16'h0213;   assign reg_cfg_valueB[94]   =8'h00;
assign reg_cfg_addrB[95]    = 16'h0214;   assign reg_cfg_valueB[95]   =8'h00;
assign reg_cfg_addrB[96]    = 16'h0215;   assign reg_cfg_valueB[96]   =8'h00;
assign reg_cfg_addrB[97]    = 16'h0216;   assign reg_cfg_valueB[97]   =8'h00;
assign reg_cfg_addrB[98]    = 16'h0217;   assign reg_cfg_valueB[98]   =8'h00;
assign reg_cfg_addrB[99]    = 16'h0218;   assign reg_cfg_valueB[99]   =8'h00;
assign reg_cfg_addrB[100]   = 16'h0219;   assign reg_cfg_valueB[100]  =8'h00;
assign reg_cfg_addrB[101]   = 16'h021A;   assign reg_cfg_valueB[101]  =8'h00;
assign reg_cfg_addrB[102]   = 16'h021B;   assign reg_cfg_valueB[102]  =8'h00;
assign reg_cfg_addrB[103]   = 16'h021C;   assign reg_cfg_valueB[103]  =8'h00;
assign reg_cfg_addrB[104]   = 16'h021D;   assign reg_cfg_valueB[104]  =8'h00;
assign reg_cfg_addrB[105]   = 16'h021E;   assign reg_cfg_valueB[105]  =8'h00;
assign reg_cfg_addrB[106]   = 16'h021F;   assign reg_cfg_valueB[106]  =8'h00;
assign reg_cfg_addrB[107]   = 16'h0220;   assign reg_cfg_valueB[107]  =8'h00;
assign reg_cfg_addrB[108]   = 16'h0221;   assign reg_cfg_valueB[108]  =8'h00;
assign reg_cfg_addrB[109]   = 16'h0222;   assign reg_cfg_valueB[109]  =8'h00;
assign reg_cfg_addrB[110]   = 16'h0223;   assign reg_cfg_valueB[110]  =8'h00;
assign reg_cfg_addrB[111]   = 16'h0224;   assign reg_cfg_valueB[111]  =8'h00;
assign reg_cfg_addrB[112]   = 16'h0225;   assign reg_cfg_valueB[112]  =8'h00;
assign reg_cfg_addrB[113]   = 16'h0226;   assign reg_cfg_valueB[113]  =8'h00;
assign reg_cfg_addrB[114]   = 16'h0227;   assign reg_cfg_valueB[114]  =8'h00;
assign reg_cfg_addrB[115]   = 16'h0228;   assign reg_cfg_valueB[115]  =8'h00;
assign reg_cfg_addrB[116]   = 16'h0229;   assign reg_cfg_valueB[116]  =8'h00;
assign reg_cfg_addrB[117]   = 16'h022A;   assign reg_cfg_valueB[117]  =8'h00;
assign reg_cfg_addrB[118]   = 16'h022B;   assign reg_cfg_valueB[118]  =8'h00;
assign reg_cfg_addrB[119]   = 16'h022C;   assign reg_cfg_valueB[119]  =8'h00;
assign reg_cfg_addrB[120]   = 16'h022D;   assign reg_cfg_valueB[120]  =8'h00;
assign reg_cfg_addrB[121]   = 16'h022E;   assign reg_cfg_valueB[121]  =8'h00;
assign reg_cfg_addrB[122]   = 16'h022F;   assign reg_cfg_valueB[122]  =8'h00;
assign reg_cfg_addrB[123]   = 16'h0235;   assign reg_cfg_valueB[123]  =8'h00;
assign reg_cfg_addrB[124]   = 16'h0236;   assign reg_cfg_valueB[124]  =8'h00;
assign reg_cfg_addrB[125]   = 16'h0237;   assign reg_cfg_valueB[125]  =8'h00;
assign reg_cfg_addrB[126]   = 16'h0238;   assign reg_cfg_valueB[126]  =8'h80;
assign reg_cfg_addrB[127]   = 16'h0239;   assign reg_cfg_valueB[127]  =8'hAF;
assign reg_cfg_addrB[128]   = 16'h023A;   assign reg_cfg_valueB[128]  =8'h00;
assign reg_cfg_addrB[129]   = 16'h023B;   assign reg_cfg_valueB[129]  =8'h00;
assign reg_cfg_addrB[130]   = 16'h023C;   assign reg_cfg_valueB[130]  =8'h00;
assign reg_cfg_addrB[131]   = 16'h023D;   assign reg_cfg_valueB[131]  =8'h00;
assign reg_cfg_addrB[132]   = 16'h023E;   assign reg_cfg_valueB[132]  =8'hA0;
assign reg_cfg_addrB[133]   = 16'h024A;   assign reg_cfg_valueB[133]  =8'h19;
assign reg_cfg_addrB[134]   = 16'h024B;   assign reg_cfg_valueB[134]  =8'h00;
assign reg_cfg_addrB[135]   = 16'h024C;   assign reg_cfg_valueB[135]  =8'h00;
assign reg_cfg_addrB[136]   = 16'h024D;   assign reg_cfg_valueB[136]  =8'h00;
assign reg_cfg_addrB[137]   = 16'h024E;   assign reg_cfg_valueB[137]  =8'h00;
assign reg_cfg_addrB[138]   = 16'h024F;   assign reg_cfg_valueB[138]  =8'h00;
assign reg_cfg_addrB[139]   = 16'h0250;   assign reg_cfg_valueB[139]  =8'h1A;
assign reg_cfg_addrB[140]   = 16'h0251;   assign reg_cfg_valueB[140]  =8'h00;
assign reg_cfg_addrB[141]   = 16'h0252;   assign reg_cfg_valueB[141]  =8'h00;
assign reg_cfg_addrB[142]   = 16'h0253;   assign reg_cfg_valueB[142]  =8'h00;
assign reg_cfg_addrB[143]   = 16'h0254;   assign reg_cfg_valueB[143]  =8'h00;
assign reg_cfg_addrB[144]   = 16'h0255;   assign reg_cfg_valueB[144]  =8'h00;
assign reg_cfg_addrB[145]   = 16'h0256;   assign reg_cfg_valueB[145]  =8'h00;
assign reg_cfg_addrB[146]   = 16'h0257;   assign reg_cfg_valueB[146]  =8'h00;
assign reg_cfg_addrB[147]   = 16'h0258;   assign reg_cfg_valueB[147]  =8'h00;
assign reg_cfg_addrB[148]   = 16'h0259;   assign reg_cfg_valueB[148]  =8'h01;
assign reg_cfg_addrB[149]   = 16'h025A;   assign reg_cfg_valueB[149]  =8'h00;
assign reg_cfg_addrB[150]   = 16'h025B;   assign reg_cfg_valueB[150]  =8'h00;
assign reg_cfg_addrB[151]   = 16'h025C;   assign reg_cfg_valueB[151]  =8'h00;
assign reg_cfg_addrB[152]   = 16'h025D;   assign reg_cfg_valueB[152]  =8'h00;
assign reg_cfg_addrB[153]   = 16'h025E;   assign reg_cfg_valueB[153]  =8'h00;
assign reg_cfg_addrB[154]   = 16'h025F;   assign reg_cfg_valueB[154]  =8'h00;
assign reg_cfg_addrB[155]   = 16'h0260;   assign reg_cfg_valueB[155]  =8'h00;
assign reg_cfg_addrB[156]   = 16'h0261;   assign reg_cfg_valueB[156]  =8'h00;
assign reg_cfg_addrB[157]   = 16'h0262;   assign reg_cfg_valueB[157]  =8'h00;
assign reg_cfg_addrB[158]   = 16'h0263;   assign reg_cfg_valueB[158]  =8'h00;
assign reg_cfg_addrB[159]   = 16'h0264;   assign reg_cfg_valueB[159]  =8'h00;
assign reg_cfg_addrB[160]   = 16'h0268;   assign reg_cfg_valueB[160]  =8'h00;
assign reg_cfg_addrB[161]   = 16'h0269;   assign reg_cfg_valueB[161]  =8'h00;
assign reg_cfg_addrB[162]   = 16'h026A;   assign reg_cfg_valueB[162]  =8'h00;
assign reg_cfg_addrB[163]   = 16'h026B;   assign reg_cfg_valueB[163]  =8'h00;
assign reg_cfg_addrB[164]   = 16'h026C;   assign reg_cfg_valueB[164]  =8'h00;
assign reg_cfg_addrB[165]   = 16'h026D;   assign reg_cfg_valueB[165]  =8'h00;
assign reg_cfg_addrB[166]   = 16'h026E;   assign reg_cfg_valueB[166]  =8'h00;
assign reg_cfg_addrB[167]   = 16'h026F;   assign reg_cfg_valueB[167]  =8'h00;
assign reg_cfg_addrB[168]   = 16'h0270;   assign reg_cfg_valueB[168]  =8'h00;
assign reg_cfg_addrB[169]   = 16'h0271;   assign reg_cfg_valueB[169]  =8'h00;
assign reg_cfg_addrB[170]   = 16'h0272;   assign reg_cfg_valueB[170]  =8'h00;
assign reg_cfg_addrB[171]   = 16'h0302;   assign reg_cfg_valueB[171]  =8'h00;
assign reg_cfg_addrB[172]   = 16'h0303;   assign reg_cfg_valueB[172]  =8'h00;
assign reg_cfg_addrB[173]   = 16'h0304;   assign reg_cfg_valueB[173]  =8'h00;
assign reg_cfg_addrB[174]   = 16'h0305;   assign reg_cfg_valueB[174]  =8'h00;
assign reg_cfg_addrB[175]   = 16'h0306;   assign reg_cfg_valueB[175]  =8'h05;
assign reg_cfg_addrB[176]   = 16'h0307;   assign reg_cfg_valueB[176]  =8'h00;
assign reg_cfg_addrB[177]   = 16'h0308;   assign reg_cfg_valueB[177]  =8'h00;
assign reg_cfg_addrB[178]   = 16'h0309;   assign reg_cfg_valueB[178]  =8'h00;
assign reg_cfg_addrB[179]   = 16'h030A;   assign reg_cfg_valueB[179]  =8'h00;
assign reg_cfg_addrB[180]   = 16'h030B;   assign reg_cfg_valueB[180]  =8'h80;
assign reg_cfg_addrB[181]   = 16'h030C;   assign reg_cfg_valueB[181]  =8'h00;
assign reg_cfg_addrB[182]   = 16'h030D;   assign reg_cfg_valueB[182]  =8'h00;
assign reg_cfg_addrB[183]   = 16'h030E;   assign reg_cfg_valueB[183]  =8'h00;
assign reg_cfg_addrB[184]   = 16'h030F;   assign reg_cfg_valueB[184]  =8'h00;
assign reg_cfg_addrB[185]   = 16'h0310;   assign reg_cfg_valueB[185]  =8'hF0;
assign reg_cfg_addrB[186]   = 16'h0311;   assign reg_cfg_valueB[186]  =8'h15;
assign reg_cfg_addrB[187]   = 16'h0312;   assign reg_cfg_valueB[187]  =8'h00;
assign reg_cfg_addrB[188]   = 16'h0313;   assign reg_cfg_valueB[188]  =8'h00;
assign reg_cfg_addrB[189]   = 16'h0314;   assign reg_cfg_valueB[189]  =8'h00;
assign reg_cfg_addrB[190]   = 16'h0315;   assign reg_cfg_valueB[190]  =8'h00;
assign reg_cfg_addrB[191]   = 16'h0316;   assign reg_cfg_valueB[191]  =8'hC8;
assign reg_cfg_addrB[192]   = 16'h0317;   assign reg_cfg_valueB[192]  =8'h00;
assign reg_cfg_addrB[193]   = 16'h0318;   assign reg_cfg_valueB[193]  =8'h00;
assign reg_cfg_addrB[194]   = 16'h0319;   assign reg_cfg_valueB[194]  =8'h00;
assign reg_cfg_addrB[195]   = 16'h031A;   assign reg_cfg_valueB[195]  =8'h00;
assign reg_cfg_addrB[196]   = 16'h031B;   assign reg_cfg_valueB[196]  =8'h00;
assign reg_cfg_addrB[197]   = 16'h031C;   assign reg_cfg_valueB[197]  =8'h00;
assign reg_cfg_addrB[198]   = 16'h031D;   assign reg_cfg_valueB[198]  =8'h00;
assign reg_cfg_addrB[199]   = 16'h031E;   assign reg_cfg_valueB[199]  =8'h00;
assign reg_cfg_addrB[200]   = 16'h031F;   assign reg_cfg_valueB[200]  =8'h00;
assign reg_cfg_addrB[201]   = 16'h0320;   assign reg_cfg_valueB[201]  =8'h00;
assign reg_cfg_addrB[202]   = 16'h0321;   assign reg_cfg_valueB[202]  =8'h00;
assign reg_cfg_addrB[203]   = 16'h0322;   assign reg_cfg_valueB[203]  =8'h00;
assign reg_cfg_addrB[204]   = 16'h0323;   assign reg_cfg_valueB[204]  =8'h00;
assign reg_cfg_addrB[205]   = 16'h0324;   assign reg_cfg_valueB[205]  =8'h00;
assign reg_cfg_addrB[206]   = 16'h0325;   assign reg_cfg_valueB[206]  =8'h00;
assign reg_cfg_addrB[207]   = 16'h0326;   assign reg_cfg_valueB[207]  =8'h00;
assign reg_cfg_addrB[208]   = 16'h0327;   assign reg_cfg_valueB[208]  =8'h00;
assign reg_cfg_addrB[209]   = 16'h0328;   assign reg_cfg_valueB[209]  =8'h00;
assign reg_cfg_addrB[210]   = 16'h0329;   assign reg_cfg_valueB[210]  =8'h00;
assign reg_cfg_addrB[211]   = 16'h032A;   assign reg_cfg_valueB[211]  =8'h00;
assign reg_cfg_addrB[212]   = 16'h032B;   assign reg_cfg_valueB[212]  =8'h00;
assign reg_cfg_addrB[213]   = 16'h032C;   assign reg_cfg_valueB[213]  =8'h00;
assign reg_cfg_addrB[214]   = 16'h032D;   assign reg_cfg_valueB[214]  =8'h00;
assign reg_cfg_addrB[215]   = 16'h032E;   assign reg_cfg_valueB[215]  =8'h00;
assign reg_cfg_addrB[216]   = 16'h032F;   assign reg_cfg_valueB[216]  =8'h00;
assign reg_cfg_addrB[217]   = 16'h0330;   assign reg_cfg_valueB[217]  =8'h00;
assign reg_cfg_addrB[218]   = 16'h0331;   assign reg_cfg_valueB[218]  =8'h00;
assign reg_cfg_addrB[219]   = 16'h0332;   assign reg_cfg_valueB[219]  =8'h00;
assign reg_cfg_addrB[220]   = 16'h0333;   assign reg_cfg_valueB[220]  =8'h00;
assign reg_cfg_addrB[221]   = 16'h0334;   assign reg_cfg_valueB[221]  =8'h00;
assign reg_cfg_addrB[222]   = 16'h0335;   assign reg_cfg_valueB[222]  =8'h00;
assign reg_cfg_addrB[223]   = 16'h0336;   assign reg_cfg_valueB[223]  =8'h00;
assign reg_cfg_addrB[224]   = 16'h0337;   assign reg_cfg_valueB[224]  =8'h00;
assign reg_cfg_addrB[225]   = 16'h0338;   assign reg_cfg_valueB[225]  =8'h00;
assign reg_cfg_addrB[226]   = 16'h0339;   assign reg_cfg_valueB[226]  =8'h1F;
assign reg_cfg_addrB[227]   = 16'h033B;   assign reg_cfg_valueB[227]  =8'h00;
assign reg_cfg_addrB[228]   = 16'h033C;   assign reg_cfg_valueB[228]  =8'h00;
assign reg_cfg_addrB[229]   = 16'h033D;   assign reg_cfg_valueB[229]  =8'h00;
assign reg_cfg_addrB[230]   = 16'h033E;   assign reg_cfg_valueB[230]  =8'h00;
assign reg_cfg_addrB[231]   = 16'h033F;   assign reg_cfg_valueB[231]  =8'h00;
assign reg_cfg_addrB[232]   = 16'h0340;   assign reg_cfg_valueB[232]  =8'h00;
assign reg_cfg_addrB[233]   = 16'h0341;   assign reg_cfg_valueB[233]  =8'h00;
assign reg_cfg_addrB[234]   = 16'h0342;   assign reg_cfg_valueB[234]  =8'h00;
assign reg_cfg_addrB[235]   = 16'h0343;   assign reg_cfg_valueB[235]  =8'h00;
assign reg_cfg_addrB[236]   = 16'h0344;   assign reg_cfg_valueB[236]  =8'h00;
assign reg_cfg_addrB[237]   = 16'h0345;   assign reg_cfg_valueB[237]  =8'h00;
assign reg_cfg_addrB[238]   = 16'h0346;   assign reg_cfg_valueB[238]  =8'h00;
assign reg_cfg_addrB[239]   = 16'h0347;   assign reg_cfg_valueB[239]  =8'h00;
assign reg_cfg_addrB[240]   = 16'h0348;   assign reg_cfg_valueB[240]  =8'h00;
assign reg_cfg_addrB[241]   = 16'h0349;   assign reg_cfg_valueB[241]  =8'h00;
assign reg_cfg_addrB[242]   = 16'h034A;   assign reg_cfg_valueB[242]  =8'h00;
assign reg_cfg_addrB[243]   = 16'h034B;   assign reg_cfg_valueB[243]  =8'h00;
assign reg_cfg_addrB[244]   = 16'h034C;   assign reg_cfg_valueB[244]  =8'h00;
assign reg_cfg_addrB[245]   = 16'h034D;   assign reg_cfg_valueB[245]  =8'h00;
assign reg_cfg_addrB[246]   = 16'h034E;   assign reg_cfg_valueB[246]  =8'h00;
assign reg_cfg_addrB[247]   = 16'h034F;   assign reg_cfg_valueB[247]  =8'h00;
assign reg_cfg_addrB[248]   = 16'h0350;   assign reg_cfg_valueB[248]  =8'h00;
assign reg_cfg_addrB[249]   = 16'h0351;   assign reg_cfg_valueB[249]  =8'h00;
assign reg_cfg_addrB[250]   = 16'h0352;   assign reg_cfg_valueB[250]  =8'h00;
assign reg_cfg_addrB[251]   = 16'h0353;   assign reg_cfg_valueB[251]  =8'h00;
assign reg_cfg_addrB[252]   = 16'h0354;   assign reg_cfg_valueB[252]  =8'h00;
assign reg_cfg_addrB[253]   = 16'h0355;   assign reg_cfg_valueB[253]  =8'h00;
assign reg_cfg_addrB[254]   = 16'h0356;   assign reg_cfg_valueB[254]  =8'h00;
assign reg_cfg_addrB[255]   = 16'h0357;   assign reg_cfg_valueB[255]  =8'h00;
assign reg_cfg_addrB[256]   = 16'h0358;   assign reg_cfg_valueB[256]  =8'h00;
assign reg_cfg_addrB[257]   = 16'h0359;   assign reg_cfg_valueB[257]  =8'h00;
assign reg_cfg_addrB[258]   = 16'h035A;   assign reg_cfg_valueB[258]  =8'h00;
assign reg_cfg_addrB[259]   = 16'h035B;   assign reg_cfg_valueB[259]  =8'h00;
assign reg_cfg_addrB[260]   = 16'h035C;   assign reg_cfg_valueB[260]  =8'h00;
assign reg_cfg_addrB[261]   = 16'h035D;   assign reg_cfg_valueB[261]  =8'h00;
assign reg_cfg_addrB[262]   = 16'h035E;   assign reg_cfg_valueB[262]  =8'h00;
assign reg_cfg_addrB[263]   = 16'h035F;   assign reg_cfg_valueB[263]  =8'h00;
assign reg_cfg_addrB[264]   = 16'h0360;   assign reg_cfg_valueB[264]  =8'h00;
assign reg_cfg_addrB[265]   = 16'h0361;   assign reg_cfg_valueB[265]  =8'h00;
assign reg_cfg_addrB[266]   = 16'h0362;   assign reg_cfg_valueB[266]  =8'h00;
assign reg_cfg_addrB[267]   = 16'h0802;   assign reg_cfg_valueB[267]  =8'h00;
assign reg_cfg_addrB[268]   = 16'h0803;   assign reg_cfg_valueB[268]  =8'h00;
assign reg_cfg_addrB[269]   = 16'h0804;   assign reg_cfg_valueB[269]  =8'h00;
assign reg_cfg_addrB[270]   = 16'h0805;   assign reg_cfg_valueB[270]  =8'h00;
assign reg_cfg_addrB[271]   = 16'h0806;   assign reg_cfg_valueB[271]  =8'h00;
assign reg_cfg_addrB[272]   = 16'h0807;   assign reg_cfg_valueB[272]  =8'h00;
assign reg_cfg_addrB[273]   = 16'h0808;   assign reg_cfg_valueB[273]  =8'h00;
assign reg_cfg_addrB[274]   = 16'h0809;   assign reg_cfg_valueB[274]  =8'h00;
assign reg_cfg_addrB[275]   = 16'h080A;   assign reg_cfg_valueB[275]  =8'h00;
assign reg_cfg_addrB[276]   = 16'h080B;   assign reg_cfg_valueB[276]  =8'h00;
assign reg_cfg_addrB[277]   = 16'h080C;   assign reg_cfg_valueB[277]  =8'h00;
assign reg_cfg_addrB[278]   = 16'h080D;   assign reg_cfg_valueB[278]  =8'h00;
assign reg_cfg_addrB[279]   = 16'h080E;   assign reg_cfg_valueB[279]  =8'h00;
assign reg_cfg_addrB[280]   = 16'h080F;   assign reg_cfg_valueB[280]  =8'h00;
assign reg_cfg_addrB[281]   = 16'h0810;   assign reg_cfg_valueB[281]  =8'h00;
assign reg_cfg_addrB[282]   = 16'h0811;   assign reg_cfg_valueB[282]  =8'h00;
assign reg_cfg_addrB[283]   = 16'h0812;   assign reg_cfg_valueB[283]  =8'h00;
assign reg_cfg_addrB[284]   = 16'h0813;   assign reg_cfg_valueB[284]  =8'h00;
assign reg_cfg_addrB[285]   = 16'h0814;   assign reg_cfg_valueB[285]  =8'h00;
assign reg_cfg_addrB[286]   = 16'h0815;   assign reg_cfg_valueB[286]  =8'h00;
assign reg_cfg_addrB[287]   = 16'h0816;   assign reg_cfg_valueB[287]  =8'h00;
assign reg_cfg_addrB[288]   = 16'h0817;   assign reg_cfg_valueB[288]  =8'h00;
assign reg_cfg_addrB[289]   = 16'h0818;   assign reg_cfg_valueB[289]  =8'h00;
assign reg_cfg_addrB[290]   = 16'h0819;   assign reg_cfg_valueB[290]  =8'h00;
assign reg_cfg_addrB[291]   = 16'h081A;   assign reg_cfg_valueB[291]  =8'h00;
assign reg_cfg_addrB[292]   = 16'h081B;   assign reg_cfg_valueB[292]  =8'h00;
assign reg_cfg_addrB[293]   = 16'h081C;   assign reg_cfg_valueB[293]  =8'h00;
assign reg_cfg_addrB[294]   = 16'h081D;   assign reg_cfg_valueB[294]  =8'h00;
assign reg_cfg_addrB[295]   = 16'h081E;   assign reg_cfg_valueB[295]  =8'h00;
assign reg_cfg_addrB[296]   = 16'h081F;   assign reg_cfg_valueB[296]  =8'h00;
assign reg_cfg_addrB[297]   = 16'h0820;   assign reg_cfg_valueB[297]  =8'h00;
assign reg_cfg_addrB[298]   = 16'h0821;   assign reg_cfg_valueB[298]  =8'h00;
assign reg_cfg_addrB[299]   = 16'h0822;   assign reg_cfg_valueB[299]  =8'h00;
assign reg_cfg_addrB[300]   = 16'h0823;   assign reg_cfg_valueB[300]  =8'h00;
assign reg_cfg_addrB[301]   = 16'h0824;   assign reg_cfg_valueB[301]  =8'h00;
assign reg_cfg_addrB[302]   = 16'h0825;   assign reg_cfg_valueB[302]  =8'h00;
assign reg_cfg_addrB[303]   = 16'h0826;   assign reg_cfg_valueB[303]  =8'h00;
assign reg_cfg_addrB[304]   = 16'h0827;   assign reg_cfg_valueB[304]  =8'h00;
assign reg_cfg_addrB[305]   = 16'h0828;   assign reg_cfg_valueB[305]  =8'h00;
assign reg_cfg_addrB[306]   = 16'h0829;   assign reg_cfg_valueB[306]  =8'h00;
assign reg_cfg_addrB[307]   = 16'h082A;   assign reg_cfg_valueB[307]  =8'h00;
assign reg_cfg_addrB[308]   = 16'h082B;   assign reg_cfg_valueB[308]  =8'h00;
assign reg_cfg_addrB[309]   = 16'h082C;   assign reg_cfg_valueB[309]  =8'h00;
assign reg_cfg_addrB[310]   = 16'h082D;   assign reg_cfg_valueB[310]  =8'h00;
assign reg_cfg_addrB[311]   = 16'h082E;   assign reg_cfg_valueB[311]  =8'h00;
assign reg_cfg_addrB[312]   = 16'h082F;   assign reg_cfg_valueB[312]  =8'h00;
assign reg_cfg_addrB[313]   = 16'h0830;   assign reg_cfg_valueB[313]  =8'h00;
assign reg_cfg_addrB[314]   = 16'h0831;   assign reg_cfg_valueB[314]  =8'h00;
assign reg_cfg_addrB[315]   = 16'h0832;   assign reg_cfg_valueB[315]  =8'h00;
assign reg_cfg_addrB[316]   = 16'h0833;   assign reg_cfg_valueB[316]  =8'h00;
assign reg_cfg_addrB[317]   = 16'h0834;   assign reg_cfg_valueB[317]  =8'h00;
assign reg_cfg_addrB[318]   = 16'h0835;   assign reg_cfg_valueB[318]  =8'h00;
assign reg_cfg_addrB[319]   = 16'h0836;   assign reg_cfg_valueB[319]  =8'h00;
assign reg_cfg_addrB[320]   = 16'h0837;   assign reg_cfg_valueB[320]  =8'h00;
assign reg_cfg_addrB[321]   = 16'h0838;   assign reg_cfg_valueB[321]  =8'h00;
assign reg_cfg_addrB[322]   = 16'h0839;   assign reg_cfg_valueB[322]  =8'h00;
assign reg_cfg_addrB[323]   = 16'h083A;   assign reg_cfg_valueB[323]  =8'h00;
assign reg_cfg_addrB[324]   = 16'h083B;   assign reg_cfg_valueB[324]  =8'h00;
assign reg_cfg_addrB[325]   = 16'h083C;   assign reg_cfg_valueB[325]  =8'h00;
assign reg_cfg_addrB[326]   = 16'h083D;   assign reg_cfg_valueB[326]  =8'h00;
assign reg_cfg_addrB[327]   = 16'h083E;   assign reg_cfg_valueB[327]  =8'h00;
assign reg_cfg_addrB[328]   = 16'h083F;   assign reg_cfg_valueB[328]  =8'h00;
assign reg_cfg_addrB[329]   = 16'h0840;   assign reg_cfg_valueB[329]  =8'h00;
assign reg_cfg_addrB[330]   = 16'h0841;   assign reg_cfg_valueB[330]  =8'h00;
assign reg_cfg_addrB[331]   = 16'h0842;   assign reg_cfg_valueB[331]  =8'h00;
assign reg_cfg_addrB[332]   = 16'h0843;   assign reg_cfg_valueB[332]  =8'h00;
assign reg_cfg_addrB[333]   = 16'h0844;   assign reg_cfg_valueB[333]  =8'h00;
assign reg_cfg_addrB[334]   = 16'h0845;   assign reg_cfg_valueB[334]  =8'h00;
assign reg_cfg_addrB[335]   = 16'h0846;   assign reg_cfg_valueB[335]  =8'h00;
assign reg_cfg_addrB[336]   = 16'h0847;   assign reg_cfg_valueB[336]  =8'h00;
assign reg_cfg_addrB[337]   = 16'h0848;   assign reg_cfg_valueB[337]  =8'h00;
assign reg_cfg_addrB[338]   = 16'h0849;   assign reg_cfg_valueB[338]  =8'h00;
assign reg_cfg_addrB[339]   = 16'h084A;   assign reg_cfg_valueB[339]  =8'h00;
assign reg_cfg_addrB[340]   = 16'h084B;   assign reg_cfg_valueB[340]  =8'h00;
assign reg_cfg_addrB[341]   = 16'h084C;   assign reg_cfg_valueB[341]  =8'h00;
assign reg_cfg_addrB[342]   = 16'h084D;   assign reg_cfg_valueB[342]  =8'h00;
assign reg_cfg_addrB[343]   = 16'h084E;   assign reg_cfg_valueB[343]  =8'h00;
assign reg_cfg_addrB[344]   = 16'h084F;   assign reg_cfg_valueB[344]  =8'h00;
assign reg_cfg_addrB[345]   = 16'h0850;   assign reg_cfg_valueB[345]  =8'h00;
assign reg_cfg_addrB[346]   = 16'h0851;   assign reg_cfg_valueB[346]  =8'h00;
assign reg_cfg_addrB[347]   = 16'h0852;   assign reg_cfg_valueB[347]  =8'h00;
assign reg_cfg_addrB[348]   = 16'h0853;   assign reg_cfg_valueB[348]  =8'h00;
assign reg_cfg_addrB[349]   = 16'h0854;   assign reg_cfg_valueB[349]  =8'h00;
assign reg_cfg_addrB[350]   = 16'h0855;   assign reg_cfg_valueB[350]  =8'h00;
assign reg_cfg_addrB[351]   = 16'h0856;   assign reg_cfg_valueB[351]  =8'h00;
assign reg_cfg_addrB[352]   = 16'h0857;   assign reg_cfg_valueB[352]  =8'h00;
assign reg_cfg_addrB[353]   = 16'h0858;   assign reg_cfg_valueB[353]  =8'h00;
assign reg_cfg_addrB[354]   = 16'h0859;   assign reg_cfg_valueB[354]  =8'h00;
assign reg_cfg_addrB[355]   = 16'h085A;   assign reg_cfg_valueB[355]  =8'h00;
assign reg_cfg_addrB[356]   = 16'h085B;   assign reg_cfg_valueB[356]  =8'h00;
assign reg_cfg_addrB[357]   = 16'h085C;   assign reg_cfg_valueB[357]  =8'h00;
assign reg_cfg_addrB[358]   = 16'h085D;   assign reg_cfg_valueB[358]  =8'h00;
assign reg_cfg_addrB[359]   = 16'h085E;   assign reg_cfg_valueB[359]  =8'h00;
assign reg_cfg_addrB[360]   = 16'h085F;   assign reg_cfg_valueB[360]  =8'h00;
assign reg_cfg_addrB[361]   = 16'h0860;   assign reg_cfg_valueB[361]  =8'h00;
assign reg_cfg_addrB[362]   = 16'h0861;   assign reg_cfg_valueB[362]  =8'h00;
assign reg_cfg_addrB[363]   = 16'h090E;   assign reg_cfg_valueB[363]  =8'h00;
assign reg_cfg_addrB[364]   = 16'h091C;   assign reg_cfg_valueB[364]  =8'h04;
assign reg_cfg_addrB[365]   = 16'h0943;   assign reg_cfg_valueB[365]  =8'h00;
assign reg_cfg_addrB[366]   = 16'h0949;   assign reg_cfg_valueB[366]  =8'h01;
assign reg_cfg_addrB[367]   = 16'h094A;   assign reg_cfg_valueB[367]  =8'h10;
assign reg_cfg_addrB[368]   = 16'h094E;   assign reg_cfg_valueB[368]  =8'h49;
assign reg_cfg_addrB[369]   = 16'h094F;   assign reg_cfg_valueB[369]  =8'h02;
assign reg_cfg_addrB[370]   = 16'h095E;   assign reg_cfg_valueB[370]  =8'h00;
assign reg_cfg_addrB[371]   = 16'h0A02;   assign reg_cfg_valueB[371]  =8'h00;
assign reg_cfg_addrB[372]   = 16'h0A03;   assign reg_cfg_valueB[372]  =8'h03;
assign reg_cfg_addrB[373]   = 16'h0A04;   assign reg_cfg_valueB[373]  =8'h01;
assign reg_cfg_addrB[374]   = 16'h0A05;   assign reg_cfg_valueB[374]  =8'h03;
assign reg_cfg_addrB[375]   = 16'h0A14;   assign reg_cfg_valueB[375]  =8'h00;
assign reg_cfg_addrB[376]   = 16'h0A1A;   assign reg_cfg_valueB[376]  =8'h00;
assign reg_cfg_addrB[377]   = 16'h0A20;   assign reg_cfg_valueB[377]  =8'h00;
assign reg_cfg_addrB[378]   = 16'h0A26;   assign reg_cfg_valueB[378]  =8'h00;
assign reg_cfg_addrB[379]   = 16'h0A2C;   assign reg_cfg_valueB[379]  =8'h00;
assign reg_cfg_addrB[380]   = 16'h0B44;   assign reg_cfg_valueB[380]  =8'h0F;
assign reg_cfg_addrB[381]   = 16'h0B4A;   assign reg_cfg_valueB[381]  =8'h1C; 
assign reg_cfg_addrB[382]   = 16'h0B57;   assign reg_cfg_valueB[382]  =8'h03; 
assign reg_cfg_addrB[383]   = 16'h0B58;   assign reg_cfg_valueB[383]  =8'h01; 
 

 
localparam REG_NUMC = 3; 
wire [7:0]    reg_cfg_valueC[REG_NUMC - 1:0];
wire [15:0]   reg_cfg_addrC[REG_NUMC - 1:0];

assign reg_cfg_addrC[0]   = 16'h001C;	assign reg_cfg_valueC[0]   =8'h01;
assign reg_cfg_addrC[1]   = 16'h0B24;	assign reg_cfg_valueC[1]   =8'hC3;
assign reg_cfg_addrC[2]   = 16'h0B25;	assign reg_cfg_valueC[2]   =8'h02;
 
 

 


 
 
 

localparam DELAY_10MS = 1000; 
localparam DELAY_300MS = 30000; 

 
 


 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
       
 
 
 
 
 
 
 
 
 
 
       
 
 
 
 
 
parameter     
   IDLE   = 5'd0,
   power_on     = 5'd1,
   TOGGLE_RESETB        = 5'd2,
   WAIT1                = 5'd3,
   Power_Up_PLL_CFG_S1     = 5'd4,
   WAIT2         = 5'd5,
   Power_Up_PLL_CFG_S2     = 5'd6,
   WAIT3         = 5'd7,
   Power_Up_PLL_CFG_S3     = 5'd8,  
   WAIT4         = 5'd9,
   cfg_done       = 5'd10;
   
(* fsm_safe_state = "reset_state" *)reg  [4:0]  cfg_state=5'b00000;  
reg   flag_reg_wr;
reg   flag_wr_done;
reg   wr_start;

reg   [15:0]  write_addr;
reg   [7:0] write_data;
reg   [7:0] read_data;
reg   [31:0] cnt;
 
reg    flag_wr_done_r0,flag_wr_done_r1;
reg    flag_wr_done_pose;
always@(negedge clk_50m )begin
   if(clk_1M_en)begin
        flag_wr_done_r0<=flag_wr_done;
        flag_wr_done_r1<=flag_wr_done_r0; 
        flag_wr_done_pose<= flag_wr_done_r0&&(~flag_wr_done_r1);
    end else begin
        flag_wr_done_r0<=flag_wr_done_r0;
        flag_wr_done_r1<=flag_wr_done_r1; 
        flag_wr_done_pose<= flag_wr_done_pose;
    end
end
 
always@(posedge clk_50m or posedge sys_rst)begin
   if(sys_rst)begin
           write_addr <= {16{1'b0}};
           write_data <= {8{1'b0}};
           wr_start <= 0;
           dac_cfg_done <= 0;
           cfg_state <= IDLE;
           dac_reset <= 1;
           cnt  <= 0;
   end else begin
      if(clk_1M_en)begin
           case(cfg_state)
               IDLE:
                   begin
                       if(flag_wr_done)begin
                           cfg_state <= power_on;
                       end else  begin
                            cfg_state <= IDLE;

                            dac_reset <= 1;
                            dac_cfg_done <= 0;
                            wr_start <= 0;
                            write_addr <= {16{1'b0}};
                            write_data <= {8{1'b0}};
                            cnt  <= 0;
                        end
                   end
              power_on:
                        begin
                           cfg_state <= WAIT1;
                           dac_reset <= 0;
                        end
               WAIT1:
                        begin
                            if(cnt == 16'd5000)begin
                                    cnt <= 0;
                                    cfg_state <= Power_Up_PLL_CFG_S1;
                            end else begin
                                    cfg_state <= WAIT1;
                                    cnt <= cnt + 1;
                            end
                        end
               Power_Up_PLL_CFG_S1:
                   begin
                       if((flag_wr_done_r1&&(cnt==0))||flag_wr_done_pose) begin 
                           if(cnt == REG_NUMA)begin 
                                   cfg_state <= WAIT2;
                                   cnt <= 0;
                            end else begin
                                   cfg_state <= Power_Up_PLL_CFG_S1;
                                   wr_start <= 1;
                                   write_addr <= reg_cfg_addrA[cnt];
                                   write_data <= reg_cfg_valueA[cnt];
                                   cnt <= cnt + 1;
                            end                
                       end else begin
                                   wr_start <= 0;
                                   cnt <= cnt;
                       end
                   end   
               WAIT2:
                       begin
                           if(cnt == DELAY_300MS)begin
                                   cfg_state <= Power_Up_PLL_CFG_S2;
                                   wr_start <= 0;
                                   write_addr <= {16{1'b0}};
                                   write_data <= {8{1'b0}};
                                   cnt <= 0;
                           end else begin
                                   cfg_state <= WAIT2;
                                   cnt <= cnt + 1;
                           end
                       end
 
               Power_Up_PLL_CFG_S2:
                   begin
                       if((flag_wr_done_r1&&(cnt==0))||flag_wr_done_pose) begin 
                           if(cnt == REG_NUMB)begin 
                                   cfg_state <= WAIT3;
                                   cnt <= 0;
                            end else begin
                                   cfg_state <= Power_Up_PLL_CFG_S2;
                                   wr_start <= 1;
                                   write_addr <= reg_cfg_addrB[cnt];
                                   write_data <= reg_cfg_valueB[cnt];
                                   cnt <= cnt + 1;
                            end                
                       end else begin
                                   wr_start <= 0;
                                   cnt <= cnt;
                       end
                   end 
                     
               WAIT3:
                       begin
                           if(cnt == DELAY_300MS)begin
                                   cfg_state <= Power_Up_PLL_CFG_S3;
                                   wr_start <= 0;
                                   write_addr <= {16{1'b0}};
                                   write_data <= {8{1'b0}};
                                   cnt <= 0;
                           end else begin
                                   cfg_state <= WAIT3;
                                   cnt <= cnt + 1;
                           end
                       end
 
               Power_Up_PLL_CFG_S3:
                   begin
                       if((flag_wr_done_r1&&(cnt==0))||flag_wr_done_pose) begin 
                           if(cnt == REG_NUMC)begin 
                                   cfg_state <= WAIT4;
                                   cnt <= 0;
                            end else begin
                                   cfg_state <= Power_Up_PLL_CFG_S3;
                                   wr_start <= 1;
                                   write_addr <= reg_cfg_addrC[cnt];
                                   write_data <= reg_cfg_valueC[cnt];
                                   cnt <= cnt + 1;
                            end                
                       end else begin
                                   wr_start <= 0;
                                   cnt <= cnt;
                       end
                   end 
 
               WAIT4:
                       begin
                           if(cnt == DELAY_300MS)begin
                                   cfg_state <= cfg_done;
                                   wr_start <= 0;
                                   write_addr <= {16{1'b0}};
                                   write_data <= {8{1'b0}};
                                   cnt <= 0;
                           end else begin
                                   cfg_state <= WAIT4;
                                   cnt <= cnt + 1;
                           end
                       end       
 
               cfg_done:
                   begin
                       wr_start <= 0;
                       write_addr <= {16{1'b0}};
                       write_data <= {8{1'b0}};
                       cnt  <= 0;
                       dac_cfg_done <= 1;
                       cfg_state <= cfg_done;
                   end
               default:
                   begin
                       cfg_state <= IDLE;
                   end
           endcase
           end else begin
               write_addr <= write_addr;
               write_data <= write_data;
               wr_start <= wr_start;
               dac_cfg_done <= dac_cfg_done;
               cfg_state <= cfg_state;
               dac_reset <= dac_reset;
               cnt  <= cnt;
           end
       end
end
 
 
 
 
 
   
 
 
 
 
 
 
 
 
 

     
 
 
 
assign start_spi      = wr_start;
assign reg_addr       = write_addr;
assign config_value   = write_data;

 
 
reg       set_start;
reg [7:0] set_addr;
reg [7:0] set_data;

parameter WR_IDLE     = 3'd0,
   TO_W_PAGE   = 3'd1,
   W_PAGE      = 3'd2,
   TO_W_REG    = 3'd3,
   W_REG       = 3'd4,
   WR_COMPLETE = 3'd5;
        
(* fsm_safe_state = "reset_state" *)reg  [2:0]  wr_state=3'b000;  
 
reg    idle_flag_r0,idle_flag_r1;
reg    idle_flag_pose;
always@(negedge clk_1M )begin
    idle_flag_r0<=idle_flag;
    idle_flag_r1<=idle_flag_r0; 
    idle_flag_pose<= idle_flag_r0&&(~idle_flag_r1);
end
    
always@(posedge clk_50m or posedge sys_rst)begin
    if(sys_rst)begin
        flag_wr_done <= 1'b0;
        set_start <= 1'b0;
        wr_state <= WR_IDLE;
        set_addr <= {8{1'b0}};
        set_data <= {8{1'b0}};
        flag_reg_wr <= 1'b0;
    end else begin
    if(clk_1M_en)begin
    case(wr_state)
        WR_IDLE:
            begin
                if(start_spi & idle_flag_r1)
                    begin
                        set_addr <= 8'h00;
                        set_data <= 8'h01;
                        set_start <= 1'b1;
                        flag_wr_done <= 1'b0;
                        wr_state <= TO_W_PAGE;
                    end
                else
                    begin
                        set_addr <= {8{1'b0}};
                        set_data <= {8{1'b0}};
                        set_start <= 1'b0;
                        flag_wr_done <= 1'b1;
                        wr_state <= WR_IDLE;
                    end
            end
        TO_W_PAGE:
            begin
               if(idle_flag_pose)begin
                  wr_state <= W_PAGE;
                  set_addr <= 8'h40;
                  set_data <= {1'b0,reg_addr[14:8]}; 
                  set_start <= 1'b1;
               end else begin
                  wr_state <= TO_W_PAGE;
                  set_addr <= set_addr;
                  set_data <= set_data;
                  set_start <= 1'b0;
               end
            end
        W_PAGE:
             begin
               if(idle_flag_pose)begin
                  wr_state <= TO_W_REG;
                  set_addr <= 8'h00;
                  set_data <= reg_addr[7:0];
                  set_start <= 1'b1;
               end else begin
                  wr_state <= W_PAGE;
                  set_addr <= set_addr;
                  set_data <= set_data;
                  set_start <= 1'b0;
               end
            end
        TO_W_REG:
            begin
               if(idle_flag_pose)begin
                  wr_state <= W_REG;
                  set_addr <= reg_addr[15]?8'h80:8'h40; 
                  set_data <= reg_addr[15]?8'h00:config_value[7:0]; 
                  set_start <= 1'b1;
               end else begin
                  wr_state <= TO_W_REG;
                  set_addr <= set_addr;
                  set_data <= set_data;
                  set_start <= 1'b0;
               end
            end
        W_REG:
            begin
               if(idle_flag_pose)begin
                  wr_state <= WR_COMPLETE;
                  set_addr <= {8{1'b0}};
                  set_data <= {8{1'b0}};
                  set_start <= 1'b0;
               end else begin
                  wr_state <= W_REG;
                  set_addr <= set_addr;
                  set_data <= set_data;
                  set_start <= 1'b0;
               end
            end
        WR_COMPLETE:
            begin
                flag_wr_done <= 1'b1;
                wr_state <= WR_IDLE;
            end
        default:
            begin
                flag_wr_done <= 1'b0;
                set_start <= 1'b0;
                wr_state <= WR_IDLE;
                set_addr <= {8{1'b0}};
                set_data <= {8{1'b0}};
            end
        endcase
        end else begin
                flag_wr_done <= flag_wr_done;
                set_start <= set_start;
                wr_state <= wr_state;
                set_addr <= set_addr;
                set_data <= set_data;
        end
    end
end
 



wire dac_sclk_temp;
wire dac_sdio_temp;
wire dac_sden_temp;

data_transmit_spi_a8_d8 data_transmit_spi_a8_d8_inst(
                   
                 .idle_flag(idle_flag),
                 .data_read_out1(data_read_out1), 
                 .data_read_out2(data_read_out2), 
                 .data_read_rdy(dac_spi_rdy), 
                 .spi_sclk(dac_sclk_temp), 
                 .spi_sdio(dac_sdio_temp), 
                 .spi_sden(dac_sden_temp), 
                 .direction_ctl(direction_ctl), 
                  
                 .clk(clk_1M),
                 .clk_50m(clk_50m),
                 .clk_1M_en(clk_1M_en),
                 .clk_1M_en_nege(clk_1M_en_nege),               
                 .spi_sdo(dac_sdo),
                 .reset(sys_rst),
                 .reg_addr(set_addr),
                 .config_value(set_data),
                 .start_spi(set_start) 
                 );
 
reg dac_sden_temp_r0,dac_sden_temp_r1;

always@(posedge clk_50m)begin
    dac_sclk<=dac_sclk_temp;
    dac_sdio   <=dac_sdio_temp;
    
    dac_sden_temp_r0   <=dac_sden_temp;      
    dac_sden_temp_r1   <=dac_sden_temp_r0;  
    dac_sden   <=dac_sden_temp_r1;    
end                
 
      
 
 


 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
endmodule

