`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera
// 
// Create Date:    22:48:57 01/01/2008 
// Design Name: 
// Module Name:    clk_gen 
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
module clk_gen
(
    input clk_in_0,
    input clk_in_2x, 
    input we,
    input [7:0] cr,

    output clk_out_p,
    output clk_out_n  
);

    reg clk_out_p_r = 0;
    reg clk_out_n_r = 1;
    
    reg [7:0] counter = 0;
    reg [7:0] max_count_r;
    
// Maxcount Register
    always @(posedge clk_in_0) 
        if (we)
            max_count_r <= ({1'b0,cr[7:1]}-1);
         
// Counter
    always @(posedge clk_in_2x)
        if (counter == max_count_r)
            begin 
                counter <= 0;
                clk_out_p_r <= ~clk_out_p_r;
                clk_out_n_r <= clk_out_p;
            end
        else
            counter <= counter + 1;
                    
    assign clk_out_p = clk_out_p_r;
    assign clk_out_n = clk_out_n_r;

endmodule
