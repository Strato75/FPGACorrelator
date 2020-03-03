`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:02:02 01/15/2008 
// Design Name: 
// Module Name:    filters 
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
module filters #(parameter LPF_TAP=32, parameter LPF_LOG2=5, parameter HPF_TAP=96, parameter HPF_LOG2=7)
(
    input clk,
    input rst,
    input stall,
    input clr,
    input we_lpf_x,
    input we_lpf_y,
    input we_htf,
    
    input signed[15:0] data_in_1,
    input signed[15:0] data_in_2,    
    input [31:0] cr,
    
    output signed[15:0] x,
    output signed[15:0] y,
    output signed[15:0] y90
    );

     
    parameter DELAY_DEPTH=(HPF_TAP-LPF_TAP)/2;

    wire [15:0] x_lpf;
    wire [15:0] y_lpf;
    
     // LOW PASS FILTER X SIGNAL
    fir #(LPF_TAP, LPF_LOG2) LPF_X (
        .clk(clk), 
        .rst(rst), 
        .we_in(we_lpf_x),
        .stall(stall),
        .clr(clr),
        .cr_in(cr), 
        .data_in(data_in_1), 
        .data_out(x_lpf)
    );
     
     
     // LOW PASS FILTER Y SIGNAL
    fir #(LPF_TAP, LPF_LOG2) LPF_Y (
        .clk(clk), 
        .rst(rst), 
        .we_in(we_lpf_y), 
        .stall(stall),
        .clr(clr),
        .cr_in(cr), 
        .data_in(data_in_2), 
        .data_out(y_lpf)
    );
     
     
     // HILBERT FILTER Y SIGNAL
    fir #(HPF_TAP, HPF_LOG2) HILBERT (
        .clk(clk), 
        .rst(rst), 
        .we_in(we_htf), 
        .stall(stall),
        .clr(clr),
        .cr_in(cr), 
        .data_in(data_in_2), 
        .data_out(y90)
    );
     
     // LPF_X DELAY LINE
    delay_line #(DELAY_DEPTH) LPF_X_DLY_LINE (
        .clk(clk),
        .clr(clr),
        .stall(stall),
        .in_data(x_lpf), 
        .out_data(x)
    );
     
     // LPF_Y DELAY LINE
    delay_line #(DELAY_DEPTH) LPF_Y_DLY_LINE (
        .clk(clk), 
        .clr(clr),
        .stall(stall),
        .in_data(y_lpf), 
        .out_data(y)
    );
     
endmodule
