`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:07:41 10/15/2010 
// Design Name: 
// Module Name:    sample_counter 
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
module sample_counter
#(parameter NSAMPLES = 32'd5000000, // Default samples
            LOG2_NSAMPLES = 32      // log2 NSAMPLES
)
(
    input clk,
    input rst,
    input en,
    input shift,
    input [7:0] uart_byte,
    
    output done
);

    // reg [LOG2_NSAMPLES-1:0] count = 0;
    reg [31:0] count = 0;
    
    always @(posedge clk)
        if (rst)
            count <= NSAMPLES - 1;
        else if (shift)
                count <= {uart_byte, count[31:8]}; // right shift. load LSB first and MSB last
                else if (en)
                    count <= count - 1;
    
    assign done = count == 0;
    
endmodule
