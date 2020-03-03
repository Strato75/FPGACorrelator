`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera
//
// Create Date:    12:05:56 01/17/2008 
// Design Name: 
// Module Name:    cr_decode 
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
`define STOP        4'b0000
`define START       4'b0001
`define SW_RST      4'b0010
`define LPF1_WE     4'b0100
`define LPF2_WE     4'b0101
`define HTF_WE      4'b0110
`define CLK_GEN_WE  4'b1000

module cr_decode
(
    input clk,
    input rst,
    input we,
    input [3:0] opcodeI,
    
    output start, 
    output stop,    
    output we_lpf_x,
    output we_lpf_y,
    output we_htf,
    output we_clk_gen,
    output sw_rst
);

    parameter IDLE = 0, DECODE = 1;
    
    reg cs, ns;
    reg [6:0] out;

    // Current State Refresh
    always @(posedge clk)
        if (rst)
            cs <= IDLE;
        else
            cs <= ns;
    
    // Next State Logic
    always @(cs, we, opcodeI)
        case (cs)
            IDLE    :   if (we)
                            ns = DECODE;
                        else
                            ns = IDLE;
            
            DECODE  : ns = IDLE;
            default : ns = IDLE;
        endcase
            
    // Mealy outputs
    assign {start, stop, sw_rst, we_lpf_x, we_lpf_y, we_htf, we_clk_gen} = out;
    
    always @(cs, opcodeI)
        case (cs)
            IDLE    :   out = 7'b000_0000;
            DECODE  :   case (opcodeI)
                            `START      :   out = 7'b100_0000;
                            `STOP       :   out = 7'b010_0000;    
                            `SW_RST     :   out = 7'b001_0000;    
                            `LPF1_WE    :   out = 7'b000_1000;    
                            `LPF2_WE    :   out = 7'b000_0100;
                            `HTF_WE     :   out = 7'b000_0010;
                            `CLK_GEN_WE :   out = 7'b000_0001;    
                            default     :   out = 7'b000_0000;
                        endcase
            default :   out = 7'b000_0000;
        endcase 
        
endmodule
