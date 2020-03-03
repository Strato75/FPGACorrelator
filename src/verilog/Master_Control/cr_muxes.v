`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
// 
// Create Date:    12:29:35 03/27/2009 
// Design Name:    SRT Correlator Master Control
// Module Name:    muxes_module 
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
module cr_muxes(

    input we_coeff,
    input we_mc,
    input [1:0] cr_sel,
    input [31:0] cr_coeff,
    input [31:0] cr_start,
    input [31:0] cr_stop,
    input [31:0] cr_clk_gen,
    
    output reg we,
    output reg [31:0] cr
    
);

    always @*
        case (cr_sel)
            2'b00   :   we = we_coeff;
            default :   we = we_mc;
        endcase
    
    always @*
        case (cr_sel)
            2'b00   :   cr = cr_coeff;
            2'b01   :   cr = cr_stop;
            2'b10   :   cr = cr_start;
            2'b11   :   cr = cr_clk_gen;
            default :   cr = cr_coeff;
        endcase

endmodule
