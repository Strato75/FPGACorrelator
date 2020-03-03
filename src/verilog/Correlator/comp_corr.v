`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera
// 
// Create Date:    16:54:57 12/13/2007 
// Design Name: 
// Module Name:    comp_corr 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This module computes values needed to perform a 
//                  cross-correlation between two signal
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module comp_corr 
#(
    parameter   DIM_IN          =   16,             // Fixed Point Q15 2 complement
                NSAMPLES        =   33'd8589934591, // 2^33 samples approximate 10Msamples (f_sample 10MHz)
                LOG2_NSAMPLES   =   33,             // log2 NSAMPLES
                MUL_OUT         =   DIM_IN*2,       //    Fixed Point Q30
                DIM_ADD         =   64              // Output Format Q33,30
)
(
    input clk, 
    input clr,
    input en,
    input [DIM_IN-1:0] x,
    input [DIM_IN-1:0] y,
    
    output [DIM_ADD-1:0] sum_x2,
    output [DIM_ADD-1:0] sum_xy,
    output [DIM_ADD-1:0] sum_y2
);
        
// MAC modules

    mac #(DIM_IN, MUL_OUT, DIM_ADD)
        MAC_1 (
        .clk(clk), 
        .clr(clr), 
        .en(en), 
        .a(x), 
        .b(x), 
        .out(sum_x2)
        );
         
    mac #(DIM_IN, MUL_OUT, DIM_ADD)
        MAC_2 (
        .clk(clk), 
        .clr(clr), 
        .en(en), 
        .a(x), 
        .b(y), 
        .out(sum_xy)
        );
         
    mac #(DIM_IN, MUL_OUT, DIM_ADD)
        MAC_3 (
        .clk(clk), 
        .clr(clr), 
        .en(en), 
        .a(y), 
        .b(y), 
        .out(sum_y2)
        );

endmodule
