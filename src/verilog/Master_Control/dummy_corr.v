`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:32:20 03/27/2009 
// Design Name: 
// Module Name:    dummy_corr 
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
module dummy_corr(

    input sys_clk,
    //input clk_2x,
    //input rst,
    input corr_reset,
    //input adc_dav_1,
    //input adc_dav_2,
    input we,

    //input [15:0] data_in_1,
    //input [15:0] data_in_2,
    input [31:0] cr_in,
    
    //output clk_sample_p,
    //output clk_sample_n,
    
    output reg [31:0] sr_out,
    output [63:0] sum_x_2,
    output [63:0] sum_y_2,
    output [63:0] sum_xy,
    output [63:0] sum_xy90,
    output [63:0] sum_y90_2
    
);

    assign sum_x_2      = 64'hAAFF00FF00FF0081;
    assign sum_y_2      = 64'hAA0FF00FF00FF0081;
    assign sum_xy       = 64'hAAFF00FF00FF0081;
    assign sum_xy90     = 64'hAAFF00FF00FF0081;
    assign sum_y90_2    = 64'hAAFF00FF00FF0081;


    always @(posedge sys_clk)
        if (we)
            sr_out = 32'h00000001;
            
        else
            sr_out = 32'h00000000;
            
endmodule
