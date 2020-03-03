`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
//
// Create Date:    00:04:46 09/14/2007 
// Design Name:    
// Module Name:    transmitter_db 
// Project Name:   
// Target Devices: 
// Tool versions: 
// Description:      Uart Transmitter module
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module transmitter_db(clk, rst, TxD_Start, baud_pulse, TxD_Data,
                            baud_gen_init, baud_gen_en, TxD, busy);
                            
    // Input Ports
    input clk;
    input rst;
    input TxD_Start;
    input baud_pulse;
    input [7:0] TxD_Data;

    // Output Ports
    output baud_gen_init;
    output baud_gen_en;
    output TxD;
    output busy;

    // Wires
    wire load_data;
    wire shift;
    wire count;
    wire set_count;
    wire end_count;
    wire [1:0] out_sel;

    // Modules Instances

    transmitter_dp TRANSMITTER_DP (
        .clk(clk), 
        .load_data(load_data), 
        .shift(shift), 
        .count(count), 
        .set_count(set_count), 
        .out_sel(out_sel), 
        .TxD_Data(TxD_Data), 
        .end_count(end_count), 
        .TxD(TxD)
        );


    transmitter_fsm TRANSMITTER_FSM (
        .clk(clk), 
        .rst(rst), 
        .TxD_Start(TxD_Start), 
        .end_count(end_count), 
        .baud_pulse(baud_pulse), 
        .load_data(load_data), 
        .count(count), 
        .shift(shift), 
        .set_count(set_count), 
        .out_sel(out_sel), 
        .baud_gen_init(baud_gen_init), 
        .baud_gen_en(baud_gen_en), 
        .busy(busy)
        );                            


endmodule
