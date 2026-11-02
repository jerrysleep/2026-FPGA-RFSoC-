`timescale 1ns/1ps
module tb_control;
  reg clk=0;
  always #5 clk=~clk;
  reg rst=1, bram_en=1;
  reg [12:0] bram_addr=0;
  reg [3:0] bram_we=0;
  reg [31:0] bram_wrdata=0;
  wire [31:0] bram_rddata;
  wire [7:0] pulse_sel, pulse_sel_d;
  wire [15:0] near_prt;
  Analysis_RadarParameter ana(
    .sys_clk(clk),.bram_clk(clk),.rst(rst),.bram_rst(rst),
    .bram_addr(bram_addr),.bram_en(bram_en),.bram_we(bram_we),
    .bram_wrdata(bram_wrdata),.bram_rddata(bram_rddata),
    .use_PulseCompress(pulse_sel),.PRT_near_dout(near_prt));
  RadarParameter_OutputDelay delay1(
    .clk(clk),.use_PulseCompress_in(pulse_sel),.use_PulseCompress_out(pulse_sel_d));

  reg pc_tx=0, just_rx=0, frame_ref_in=0;
  reg [7:0] setup_mode=8'h11;
  wire tx_on, rx_on, far_near;
  wire [3:0] radar_mode;
  wire [15:0] prt_period;
  Processor_Ctrl ctrl(
    .clk(clk),.rst(rst),.pc_tx_on_off(pc_tx),.just_receive(just_rx),
    .program_start(1'b0),.program_reset(1'b0),
    .program_wait_time(16'd0),.program_hold_time(16'd0),
    .serch_or_track(1'b0),.current_range_gate(8'd0),.switch_range_gate(8'd0),
    .Setup_para_mode(setup_mode),.subarray_select_mode(8'h00),
    .detect_phase_state(2'b00),.frame_ref(frame_ref_in),
    .far_prt_period(16'd15),.near_prt_period(16'd7),
    .far_frame_period(32'd63),.near_frame_period(32'd31),
    .far_prt_num(16'd4),.near_prt_num(16'd4),
    .far_delay_tf_pm(16'd2),.far_length_tf_pm(16'd3),
    .near_delay_tf_pm(16'd1),.near_length_tf_pm(16'd2),
    .radar_mode(radar_mode),.tx_on_off(tx_on),.receive_on(rx_on),
    .far_or_near(far_near),.prt_period(prt_period));

  wire frame_ref, prt_ref, tf_pm, gate_buff_o;
  RF_Timer timer(
    .clk(clk),.rst(rst),.tx_on_off(1'b1),.receive_en(1'b1),
    .decimate_16(1'b0),.far_or_near(1'b1),
    .upc_delay_tf_pm(16'd2),.upc_length_tf_pm(16'd3),
    .upc_delay_tf_pc(16'd3),.upc_length_tf_pc(16'd3),
    .upc_delay_tr_k(16'd1),.upc_length_tr_k(16'd3),
    .upc_delay_ADC(16'd2),.upc_length_ADC(16'd5),
    .upc_delay_PhaseRef(16'd1),.upc_length_PhaseRef(16'd2),
    .prt_period(16'd15),.frame_period(32'd63),.prt_num(16'd4),
    .frame_ref(frame_ref),.prt_ref(prt_ref),.TF_pm(tf_pm),.gate_buff_o(gate_buff_o));
  integer fd, i, errors=0, frame_count=0, prt_count=0;
  initial begin
    fd=$fopen("control.csv","w");
    $fwrite(fd,"cycle,rst,bram_addr,bram_we,bram_wrdata,pulse_sel,pulse_sel_d,near_prt,pc_tx,tx_on,radar_mode,far_near,prt_period,frame_ref,prt_ref,tf_pm,gate_buff\n");
    for(i=0;i<120;i=i+1) begin
      @(negedge clk);
      if(i==4) rst=0;
      if(i==12) begin bram_addr=13'h108; bram_we=4'hf; bram_wrdata=0; end
      if(i==13) bram_we=0;
      if(i==28) pc_tx=1;
      if(i==50) begin setup_mode=8'h00; frame_ref_in=1; end
      if(i==51) frame_ref_in=0;
      if(i==55) frame_ref_in=1;
      if(i==56) frame_ref_in=0;
      #1;
      $fwrite(fd,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",i,rst,bram_addr,bram_we,bram_wrdata,pulse_sel,pulse_sel_d,near_prt,pc_tx,tx_on,radar_mode,far_near,prt_period,frame_ref,prt_ref,tf_pm,gate_buff_o);
      if(frame_ref) frame_count=frame_count+1;
      if(prt_ref) prt_count=prt_count+1;
      if(i==25 && (pulse_sel!==8'h00 || pulse_sel_d!==8'h00)) errors=errors+1;
      if(i==40 && tx_on!==1'b1) errors=errors+1;
      if(i==65 && far_near!==1'b0) errors=errors+1;
    end
    if(frame_count<1 || prt_count<2) errors=errors+1;
    $fclose(fd);
    if(errors) $fatal(1,"CONTROL FAIL errors=%0d",errors);
    $display("CONTROL PASS frame=%0d prt=%0d",frame_count,prt_count);
    $finish;
  end
endmodule
