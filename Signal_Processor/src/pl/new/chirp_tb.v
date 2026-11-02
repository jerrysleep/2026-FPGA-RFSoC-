`timescale 1ns / 1ps

module ChirpGen_tb_final;

     
     
     
    localparam real FC          = 2.70154958677685;         
    localparam real BW          = 0;        
    localparam real PULSE_WIDTH = 40.0;        
    localparam real PULSE_PERIOD = 196.0;      
 
 

     
     
     
    localparam integer C_DDS_CHNL_NUM      = 32;            
    localparam integer C_DDS_PHASE_WIDTH   = 32;            
    localparam integer C_S00_AXI_DATA_WIDTH = 32;
    localparam integer C_S00_AXI_ADDR_WIDTH = 11;

    localparam real CLK_PERIOD = 4;                        
    localparam real T_CLK_S = 4 * 1e-9;                        
    localparam real TS = 0.125;                       

     
     
     
    localparam real FC_HZ       = FC * 1e9;                   
    localparam real BW_HZ       = BW * 1e6;                   
    localparam real F_START     = FC_HZ - BW_HZ/2;            
    localparam real F_STOP      = FC_HZ + BW_HZ/2;            
    localparam real MU          = BW_HZ / PULSE_WIDTH * 1e9;  

     
    localparam real T_FS_S     = TS * 1e-9;          
    localparam real f_dds       = 1.0 / T_CLK_S;              
    localparam real f_s       =   1.0 / T_FS_S;              
    localparam real PINC1_REAL  =  MU * T_CLK_S * T_CLK_S * 2.0**32;
    localparam integer PINC1    = $rtoi(PINC1_REAL) & 32'hFFFFFFFF;  

     
    localparam integer TOTAL_SAMPLES = $rtoi(PULSE_WIDTH / TS);   
    localparam integer CYCLES_NEEDED = (TOTAL_SAMPLES + C_DDS_CHNL_NUM - 1) / C_DDS_CHNL_NUM;  

     
    localparam [63:0] TWO_POW_32 = 64'd4294967296;

     
     
     
    reg                             m00_axis_aclk;
    reg                             clk_500M;
    reg                             m00_axis_aresetn;
    wire                            mm_axis_tvalid;
    wire [C_DDS_CHNL_NUM*32-1:0]    mm_axis_tdata;

 
 
 
 
    reg  [31:0]                     axi_chirp_width;
    reg  [31:0]                     axi_pulse_period;
 
    reg                             prt_ref;
 

 
 
 
 
 

     
    integer i; 
    reg [63:0] f0_scale, mu_scale;           
    reg [63:0] f0_scale2, mu_scale2;         
 
 


chirp_top chirp_top(
    .m00_axis_aclk                  (m00_axis_aclk),
    .clk_500M                       (clk_500M),
    .m00_axis_aresetn               (m00_axis_aresetn),
    .PINC1                          (PINC1),               
    .f0_scale                       (f0_scale[31:0]),            
    .mu_scale                       (mu_scale[31:0]),             
    .f0_scale2                      (f0_scale2[31:0]),            
    .mu_scale2                      (mu_scale2[31:0]),           
    .axi_chirp_width                (axi_chirp_width),           
    .axi_pulse_period               (axi_pulse_period),           
 
    .prt_ref                        (prt_ref),           
    .pulse_delay                    (32'd0),           

    
    .mm_axis_tvalid                 (mm_axis_tvalid),
    .mm_axis_tdata                  (mm_axis_tdata),
    .m_axis_tvalid_converter        (m_axis_tvalid_converter),
    .m_axis_tdata_converter         (m_axis_tdata_converter)
    );
     
     
     
    initial begin
        m00_axis_aclk = 0;
        forever #(CLK_PERIOD/2) m00_axis_aclk = ~m00_axis_aclk;
    end
    initial begin
        clk_500M = 0;
        forever #(CLK_PERIOD/4) clk_500M = ~clk_500M;
    end
    
    
 
    initial begin
       
        prt_ref = 0;
        #400;   
        forever begin
            @(posedge m00_axis_aclk);
            prt_ref = 1;
            @(posedge m00_axis_aclk);
            prt_ref = 0;
            repeat(PULSE_PERIOD-1) @(posedge m00_axis_aclk);   
        end
    end
    
    
     
     
     
    initial begin
         
 
        m00_axis_aresetn = 0;

         
 
 
        f0_scale   = 64'd3462595535; 
        mu_scale   = $rtoi(MU * TS * 1e-9 / f_dds * TWO_POW_32 + 0.5);
        f0_scale2  = $rtoi(F_START * TS * 1e-9 * TWO_POW_32 + 0.5);
        mu_scale2  = $rtoi(0.5 * MU * (TS * 1e-9) * (TS * 1e-9) * TWO_POW_32 + 0.5);
 
        axi_chirp_width = 32'hFFFFFFFF;  
        axi_pulse_period = $rtoi(PULSE_PERIOD/4); 
 
 
                                                        
        #200;
        m00_axis_aresetn = 1;
             
       
         
        #500000;
        $stop;
    end

     
     
     
    integer file_id;
    reg [15:0] sample_i [0:C_DDS_CHNL_NUM-1];

    initial begin
         
        @(posedge mm_axis_tvalid);
        file_id = $fopen("C:/Users/zhang/Desktop/chirp_i_data.txt", "w");
        if (file_id == 0) begin
            $display("Error: Could not open file.");
            $finish;
        end

         
        fork
            begin
                while (1) begin
                    @(posedge m00_axis_aclk);
                    if (mm_axis_tvalid || !mm_axis_tvalid) begin
                        for (i = 0; i < C_DDS_CHNL_NUM; i = i + 1) begin
                            sample_i[i] = mm_axis_tdata[32*i+16 +: 16];
                            $fwrite(file_id, "%d ", $signed(sample_i[i]));
                        end
                        $fwrite(file_id, "\n");
                    end
                end
            end
            begin
                 
                #300000;   
                $fclose(file_id);
                $display("Data written to chirp_i_data.txt");
                $finish;
            end
        join
    end

endmodule