`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
// 
// Create Date:    12:41:34 03/27/2009 
// Design Name:      SRT Correlator Master Control
// Module Name:    uart_src_muxes 
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
module uart_src_muxes
(
    input uart_src_sel,
    input start_uart_tx_res,
    input start_uart_tx_mc,
    input [7:0] res_byte,
    input [7:0] connected_byte,
    
    output TxD_Start,
    output [7:0] Byte_out
);

    assign TxD_Start    = uart_src_sel ? start_uart_tx_res : start_uart_tx_mc;
    assign Byte_out     = uart_src_sel ? res_byte : connected_byte;

endmodule
