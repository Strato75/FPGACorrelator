`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
// 
// Create Date:    19:55:21 03/27/2009 
// Design Name:    SRT Correlator Top MODULE
// Module Name:    srt_corr_top 
// Project Name:      SRT Correlator
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
module srt_corr_top
(
    input sys_clk_in,
    input sys_rst,
    
    input uart_rx, 
    
    input start_button, 
    
    input adc_dav_1,
    input adc_dav_2,
    
    input [1:0] delay_sel,
    
    input [15:0] data_in_1,
    input [15:0] data_in_2,
    
    // DEBUG PINS -- TO BE REMOVED
    output done,
    output failure,
    //
    
    output clk_sample_p_1,
    output clk_sample_p_2,
    output uart_tx    
);


// PAR SIMULATION PARAMETERS
//    parameter LPF_TAP=32;
//    parameter LPF_LOG2=5;
//    parameter HPF_TAP=64;
//    parameter HPF_LOG2=6;
//    parameter NSAMPLES = 25'd1024;  
//    parameter LOG2_NSAMPLES = 25;

// IMPLEMENTATION PARAMETERS
    parameter LPF_TAP       = 32;
    parameter LPF_LOG2      = 5;
    parameter HPF_TAP       = 64;
    parameter HPF_LOG2      = 6;

    parameter NSAMPLES      = 32'd5000000; // default 5E06 samples (0.200 sec. at 25Mhz) 
    parameter LOG2_NSAMPLES = 32;

    wire locked_out;
    wire [7:0] uart_byte;
    wire [31:0] cr;
    wire [31:0] sr_out;
    wire [63:0] sum_x_2;
    wire [63:0] sum_y_2;
    wire [63:0] sum_xy;
    wire [63:0] sum_xy90;
    wire [63:0] sum_y90_2;
    wire [63:0] sum_y_y90;
    
    wire clk_sample_p;
    wire sample_cnt_shift;
    
    assign master_reset     = ~sys_rst | ~locked_out;
    assign clk_sample_p_1   = clk_sample_p;
    assign clk_sample_p_2   = clk_sample_p;
    
    // DEBUG SIGNALS
    assign done = sr_out[0];
    assign failure = sr_out[1];
    //
    
// MASTER CONTROL
master_top MASTER_CONTROL (
    .sys_clk(sys_clk), 
    .sys_rst(master_reset), 
    .start_button(start_button), 
    .uart_rx(uart_rx), 
    .sr_in(sr_out), 
    .sum_x_2(sum_x_2), 
    .sum_y_2(sum_y_2), 
    .sum_xy(sum_xy), 
    .sum_xy90(sum_xy90), 
    .sum_y90_2(sum_y90_2),
    .sum_y_y90(sum_y_y90),    
    .uart_tx(uart_tx), 
    .corr_reset(corr_reset), 
    .we(we), 
    .sample_cnt_shift(sample_cnt_shift),
    .uart_byte(uart_byte),
    .cr(cr)
    );

// CORRELATOR
top_corr 
    #(
    // Filter Parameters
    // Warning: Do not use a LPF_TAP value greater than HPF_TAP value
        LPF_TAP,
        LPF_LOG2,
        HPF_TAP,
        HPF_LOG2,
        NSAMPLES,
        LOG2_NSAMPLES
    )
    CORRELATOR (
    .sys_clk(sys_clk), 
    .clk_2x(clk_2x), 
    .rst(corr_reset), 
    .adc_dav_1(adc_dav_1), 
    .adc_dav_2(adc_dav_2), 
    .we(we), 
    .sample_cnt_shift(sample_cnt_shift),
    .delay_sel(delay_sel),
    .data_in_1(data_in_1), 
    .data_in_2(data_in_2), 
    .uart_byte(uart_byte),
    .cr_in(cr), 
    .clk_sample_p(clk_sample_p), 
    .clk_sample_n(clk_sample_n), 
    .sr_out(sr_out), 
    .sum_x_2(sum_x_2), 
    .sum_y_2(sum_y_2), 
    .sum_xy(sum_xy), 
    .sum_xy90(sum_xy90), 
    .sum_y90_2(sum_y90_2),
    .sum_y_y90(sum_y_y90)
    );
     
// DCM MODULE --> 2x
dcm_module DCM_MODULE (
    .CLKIN_IN(sys_clk_in), 
    .RST_IN(~sys_rst), 
    .CLKIN_IBUFG_OUT(sys_clk_in_ibuf), 
    .CLK0_OUT(sys_clk), 
    .CLK2X_OUT(clk_2x), 
    .LOCKED_OUT(locked_out)
    );
     
endmodule
