`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
// 
// Create Date:    15:11:15 03/27/2009 
// Design Name:    SRT Correlator Master Control
// Module Name:    sr_decode 
// Project Name:   SRT Correlator 
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
module sr_decode(
    
    input [31:0] sr,
    
    output corr_busy,
    output failure
);

    assign done         = sr[0];
    assign failure      = sr[1];
    assign corr_busy    = ~done;

endmodule
