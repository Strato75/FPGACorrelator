`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera
// 
// Create Date:    22:27:31 12/29/2007 
// Design Name: 
// Module Name:    top_corr 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top_corr
#(
// Filter Parameters
// Warning: Do not use a LPF_TAP value greater than HPF_TAP value
    parameter LPF_TAP=32,
    parameter LPF_LOG2=5,
    parameter HPF_TAP=96,
    parameter HPF_LOG2=7,
    parameter NSAMPLES=33'd8589934591,
    parameter LOG2_NSAMPLES=33
)

(

    input sys_clk,
    input clk_2x,
    input rst,
    input adc_dav_1,
    input adc_dav_2,
    input we,
    input sample_cnt_shift,
    
    input [1:0] delay_sel,

    input [7:0] uart_byte,
    input [15:0] data_in_1,
    input [15:0] data_in_2,
    input [31:0] cr_in,
    
    output clk_sample_p,
    output clk_sample_n,
    
    output [31:0] sr_out,
    output [63:0] sum_x_2,
    output [63:0] sum_y_2,
    output [63:0] sum_xy,
    output [63:0] sum_xy90,
    output [63:0] sum_y90_2,
    output [63:0] sum_y_y90
);


    
// Regs
    reg [31:0] sr;
    reg [31:0] cr;

// Nets
    wire fifo_rst;
    wire empty_1;
    wire empty_2;

    wire start;
    wire stop;
    wire stall;
    wire clr;
    wire we_lpf_x;
    wire we_lpf_y;
    wire we_htf;
    wire we_clk_gen;
    wire sw_rst;
    wire en;
    wire done;
    
    wire [3:0] opcodeI;
    wire [7:0] clk_gen_cr;
    wire [15:0] data_out_1;
    wire [15:0] data_out_2;
    
    wire [15:0] x;
    wire [15:0] y;
    wire [15:0] y90;
    
// Interconnections
    
    assign clk          = sys_clk;
    assign opcodeI      = cr [3:0];
    assign clk_gen_cr   = cr [15:8];
    assign sr_out       = sr;
    
// Modules

    // ADC_CONTROL
    adc_control ADC_CONTROL (
        .clk(clk),
        .clk_2x(clk_2x),
        .adc_clk_1(adc_dav_1),
        .adc_clk_2(adc_dav_2),
        .rst(rst),
        .fifo_rst(fifo_rst),     
        .we(we_clk_gen),
         
        .fifo_read(fifo_read),
         
         .delay_sel(delay_sel),
         
        .clk_gen_cr(clk_gen_cr),
        .data_in_1(data_in_1), 
        .data_in_2(data_in_2), 
        .empty_1(empty_1),
        .empty_2(empty_2), 
        .clk_sample_p(clk_sample_p),
        .clk_sample_n(clk_sample_n),
        .data_out_1(data_out_1), 
        .data_out_2(data_out_2)
        );
         
     
     // FILTERS
    filters #(LPF_TAP, LPF_LOG2, HPF_TAP, HPF_LOG2) FILTERS (
        .clk(clk), 
        .rst(rst),
        //.rst(sw_rst), 
        .stall(stall), 
        .clr(clr),
        .we_lpf_x(we_lpf_x), 
        .we_lpf_y(we_lpf_y), 
        .we_htf(we_htf), 
        .data_in_1(data_out_1), 
        .data_in_2(data_out_2), 
        .cr(cr), 
        .x(x), 
        .y(y), 
        .y90(y90)
        );
         
         
     // COMPUTATION CORE
    computation_core #(NSAMPLES, LOG2_NSAMPLES)    COMP_CORE (
        .clk(clk),  
        .en(en),
        .clr(clr),
        .x(x), 
        .y(y), 
        .y90(y90), 
        .sum_x_2(sum_x_2), 
        .sum_xy(sum_xy), 
        .sum_y_2(sum_y_2), 
        .sum_xy90(sum_xy90), 
        .sum_y90_2(sum_y90_2),
        .sum_y_y90(sum_y_y90)
        );
         
     
     // CR DECODE
    cr_decode CR_DECODE (
        .clk(clk), 
        .rst(rst), 
        .we(we), 
        .opcodeI(opcodeI), 
        .start(start), 
        .stop(stop), 
        .we_lpf_x(we_lpf_x), 
        .we_lpf_y(we_lpf_y), 
        .we_htf(we_htf), 
        .we_clk_gen(we_clk_gen), 
        .sw_rst(sw_rst)
        );
        
     // SAMPLE COUNTER
    sample_counter 
        #(NSAMPLES
          LOG2_NSAMPLES)
        
        SAMPLE_COUNTER (
        .clk(clk), 
        .rst(rst), 
        .en(en), 
        .shift(sample_cnt_shift),
        .uart_byte(uart_byte),
        .done(done)
        );
        
     // MAIN CONTROL
    main_control MAIN_CONTROL (
        .clk(clk), 
    //     .rst(sw_rst), // This is only used if reset is de
        .rst(rst), 
        .start(start), 
        .stop(stop), 
        .done(done), 
        .empty_1(empty_1), 
        .empty_2(empty_2), 
        .fifo_read(fifo_read), 
        .fifo_rst(fifo_rst), 
        .stall(stall), 
        .clr(clr), 
        .failure(failure)
        );
         
     // Control REGISTER
     always @(posedge clk)
        if (we)
            cr <= cr_in;
     
     // STATUS REGISTER
     always @(posedge clk)
        sr <= {30'b0, {failure,done}};
        
     // Signal enable
     assign en = ~done & ~stall;
     
endmodule
