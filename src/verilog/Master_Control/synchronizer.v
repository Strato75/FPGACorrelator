`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
//
// Create Date:    13:41:48 10/06/2007 
// Design Name:    
// Module Name:    synchronizer 
// Project Name:   
// Target Devices: 
// Tool versions: 
// Description:    dual ffd synchronizer for serial incoming signal
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module synchronizer
(
    input clk,
    input in,
    output out
);

    reg ffd1_q, ffd2_q;

    assign out = ffd2_q;

    always @(posedge clk)
        begin    
            ffd1_q <= in;
            ffd2_q <= ffd1_q;
        end

endmodule
