`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
//
// Create Date:    09:50:46 09/13/2007 
// Design Name:     
// Module Name:    receiver_db
// Project Name:   
// Target Devices: 
// Tool versions: 
// Description:      UART Receiver module
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module receiver_db(clk, rst, RxD, baud_pulse, 
                        baud_gen_init, baud_gen_en, ready, data);

    // Input Ports
    input clk;
    input rst;
    input RxD;
    input baud_pulse;

    // Output Ports
    output baud_gen_init;
    output baud_gen_en;
    output ready;
    output [7:0] data;

    // Nets
    wire clk;
    wire rst;
    wire RxD;
    wire baud_pulse;
    wire ready;
    wire [7:0] data;

    wire baud_gen_init;
    wire count;
    wire load_sr;
    wire set_count;
    wire end_count;


    // Module Instances

    // Datapath
    receiver_dp RECEIVER_DP (
        .clk(clk), 
        .rst(rst), 
        .RxD(RxD), 
        .count(count), 
        .load_sr(load_sr), 
        .set_count(set_count), 
        .end_count(end_count), 
        .data(data)
        );

    // Control

    receiver_fsm RECEIVER_FSM (
        .clk(clk), 
        .rst(rst), 
        .RxD(RxD), 
        .baud_pulse(baud_pulse), 
        .end_count(end_count), 
        .count(count), 
        .load_sr(load_sr), 
        .set_count(set_count), 
         .baud_gen_init (baud_gen_init),
        .en(baud_gen_en), 
        .ready(ready)
        );


endmodule
