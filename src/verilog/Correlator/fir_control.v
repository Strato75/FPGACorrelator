`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera
// 
// Create Date:    18:46:14 12/14/2007 
// Design Name: 
// Module Name:    fir_control 
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
//`define STOP_FILTERING     8'b0000xxxx
//`define START_FILTERING 8'b0001xxxx
//`define CLR                 8'b0010xxxx
`define SET_COEFF         4'b0100
`define CLR_ALL_COEFF     4'b1000


module fir_control
(
    input clk,
    input rst,
    input we_in,
    input [3:0] opcodeII,
    
    output c_clr,
    output c_sto
);

    parameter IDLE=0, DECODE=1, C_STO_ASSERT=2, C_CLR_ASSERT=3;
    
    reg [1:0] cs, ns;
    reg [1:0] moore_out;

// Current State Refresh
    always @(posedge clk)
        if (rst)
            cs <= IDLE;
        else
            cs <= ns;
            
// Next State Logic     
    always @(cs, we_in, opcodeII)
        case (cs)
            IDLE            :   if (we_in)
                                    ns = DECODE;
                                else
                                    ns = IDLE;
            
            DECODE          :   case (opcodeII)
                                    `SET_COEFF      :  ns = C_STO_ASSERT;
                                    `CLR_ALL_COEFF  :  ns = C_CLR_ASSERT;
                                    default         :  ns = IDLE;
                                endcase
            
            C_STO_ASSERT    :   ns = IDLE;
            
            C_CLR_ASSERT    :   ns = IDLE;
            
            default         :   ns = IDLE;
        endcase
        
// Output logic
    
    assign {c_clr, c_sto} = moore_out;
    
    always @(cs)
        case (cs)
            IDLE            :    moore_out = 2'b00;
            DECODE          :    moore_out = 2'b00;
            C_STO_ASSERT    :    moore_out = 2'b01;        
            C_CLR_ASSERT    :    moore_out = 2'b10;
            default         :    moore_out = 2'b00;
        endcase
        
endmodule
