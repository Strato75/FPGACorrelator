`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
//
// Create Date:    00:18:55 09/14/2007 
// Design Name:    
// Module Name:    transmitter_fsm 
// Project Name:   
// Target Devices: 
// Tool versions: 
// Description:      Uart Transmitter FSM
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module transmitter_fsm(clk, rst, TxD_Start, end_count, baud_pulse,
                                load_data, count, shift, set_count, out_sel, baud_gen_init, baud_gen_en, busy);

    parameter IDLE = 0, START_BIT = 1, SEND_BIT = 2, STOP_BIT = 3;
                                    
    input clk;
    input rst;
    input TxD_Start;
    input end_count;
    input baud_pulse;

    output  load_data;
    output  count;
    output  shift;
    output  set_count;
    output  baud_gen_init;
    output  baud_gen_en;
    output  busy;
    output  [1:0] out_sel;

    reg [1:0] ns, cs;
    reg [4:0] mealy_out;
    reg [3:0] moore_out;

    // Current state refresh
    always @(posedge clk)
        if (rst) 
            cs <= IDLE;
        else
            cs <= ns;

    // Next State Logic
    always @(cs, TxD_Start, baud_pulse, end_count)
        case(cs)
            IDLE        : ns = TxD_Start  ? START_BIT : IDLE;
            START_BIT   : ns = baud_pulse ? SEND_BIT : START_BIT;
            SEND_BIT    : ns = end_count  ? STOP_BIT : SEND_BIT;
            STOP_BIT    : ns = (TxD_Start & baud_pulse) ? START_BIT : (~TxD_Start & baud_pulse) ? IDLE : STOP_BIT;
            default     : ns = IDLE;
        endcase

    // Mealy outputs

    assign {load_data, set_count, baud_gen_init, count, shift} = mealy_out;

    always @(cs, TxD_Start, baud_pulse, end_count)
        case(cs)
            IDLE        : mealy_out = TxD_Start  ? 5'b1_1_1_0_0 : 5'b0_0_0_0_0;
            START_BIT   : mealy_out = 5'b0_0_0_0_0;
            SEND_BIT    : mealy_out = (end_count) ? 5'b0_0_0_0_0 : (baud_pulse) ? 5'b0_0_0_1_1 : 5'b0_0_0_0_0;
            STOP_BIT    : mealy_out = (TxD_Start & baud_pulse) ? 5'b1_1_1_0_0 : 5'b0_0_0_0_0;
            default     : mealy_out = 5'b0_0_0_0_0;
        endcase

    // Moore outputs

    assign {baud_gen_en, out_sel, busy} = moore_out;

    always @(cs)
        case(cs)
            IDLE        : moore_out = 4'b0_10_0;
            START_BIT   : moore_out = 4'b1_00_1;
            SEND_BIT    : moore_out = 4'b1_01_1;
            STOP_BIT    : moore_out = 9'b1_10_1;
            default     : moore_out = 9'b0_10_0;
        endcase

endmodule
