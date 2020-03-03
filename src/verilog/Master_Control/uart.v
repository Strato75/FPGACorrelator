`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Giovanni Busonera
//
// Create Date:    18:16:01 09/12/2007 
// Design Name:       
// Module Name:    uart 
// Project Name:       
// Target Devices: 
// Tool versions: 
// Description: Top module of a baud configurable serial line
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart(clk, rst, RxD, TxD_Start, TxD_Data,
                    TxD, valid, busy, Byte_Data);

    // UART Parameters

    parameter CLKFREQ   = 100000000;    // Hz
    parameter BAUD      = 115200;       // Baud per second

    // Input Ports

    input clk;              // System clock (Set parameter CLKFREQ)
    input rst;              // Reset: Reset all counters and FSMs
    input RxD;              // RS232 RD signal
    input TxD_Start;        // Signal to be issued to start a serial transmission
    input [7:0] TxD_Data;   // Byte Data to be serialized and transmitted

    // Output Ports
    output TxD;             // RS232 TD signal
    output valid;           // Byte_Data has got a valid data (Pulse behavior)
    output busy;            // No trasmission can be issued if busy is high
    output [7:0]Byte_Data;  // Deserialized data
     
    //Wires
    wire clk;
    wire rst;

    wire baud_gen_init_rx;
    wire baud_gen_init_tx;
    wire en_rx;
    wire en_tx;
    wire baud_pulse;
    wire RxD_r;

    // Module Instances

    // Baud half period pulse generator
    baud_gen #(CLKFREQ, BAUD) BAUD_GEN (
        .clk(clk), 
        .init_tx(baud_gen_init_tx),
        .init_rx(baud_gen_init_rx),    
        .en_tx(en_tx),
        .en_rx(en_rx),    
        .baud_pulse(baud_pulse)
        );
     
    // Receiver Side
    receiver_db UART_RX (
        .clk(clk), 
        .rst(rst), 
        .RxD(RxD_r), 
        .baud_pulse(baud_pulse),
        .baud_gen_init(baud_gen_init_rx),
        .baud_gen_en (en_rx),
        .ready(ready), 
        .data(Byte_Data)
        );
         
    // Transmitter Side
    transmitter_db UART_TX (
        .clk(clk), 
        .rst(rst), 
        .TxD_Start(TxD_Start), 
        .baud_pulse(baud_pulse), 
        .TxD_Data(TxD_Data), 
        .baud_gen_init(baud_gen_init_tx), 
        .baud_gen_en(en_tx), 
        .TxD(TxD), 
        .busy(busy)
        );
         
    // Synchronizer
    synchronizer SYNCH (
        .clk(clk),
        .in(RxD),
        .out(RxD_r)
        );

    // Valid generator
    valid_gen VALID_GEN (
        .clk(clk), 
        .rst(rst), 
        .ready(ready), 
        .valid_r(valid)
        );
         
endmodule
