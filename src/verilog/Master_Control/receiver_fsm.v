`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
//
// Create Date:    13:22:45 09/13/2007 
// Design Name:      
// Module Name:    receiver_fsm 
// Project Name:   
// Target Devices: 
// Tool versions: 
// Description:      UART Receiver FSM
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module receiver_fsm(clk, rst, RxD, baud_pulse, end_count, 
                            count, load_sr, set_count, baud_gen_init, en, ready);
                            
    parameter IDLE=0, INIT=1, CHECK_START=2, WAIT_BIT=3, GET_BIT=4, WAIT_STOP=5, ERROR=6;
    // Input Ports
    input clk;
    input rst;
    input RxD;
    input baud_pulse;
    input end_count;

    // Output Ports
    output reg count;
    output reg load_sr;
    output reg set_count;
    output reg baud_gen_init;
    output reg en;
    output reg ready;

    // regs

    reg [2:0] cs, ns;

    // Current state refresh
    always @(posedge clk)
        if (rst) 
            cs <= IDLE;
        else
            cs <= ns;

    // Next State Logic
    always @(cs, RxD, baud_pulse, end_count)
        case (cs)
            IDLE        : ns = (~RxD) ? INIT : IDLE;
            
            INIT        : ns = CHECK_START;
            
            CHECK_START : ns = (baud_pulse) ? ((~RxD) ? WAIT_BIT : IDLE) : CHECK_START;
            
            WAIT_BIT    : ns = (baud_pulse) ? GET_BIT : WAIT_BIT;
                
            GET_BIT     : ns = (end_count) ? WAIT_STOP : WAIT_BIT;
            
            WAIT_STOP   : ns = (baud_pulse) ? (RxD ? IDLE : ERROR) : WAIT_STOP;
            
            ERROR       : ns = (~RxD) ? CHECK_START : ERROR;
            
            default     : ns = IDLE;
            
        endcase

    // Moore Output 

    always @(cs)
        case (cs)
            IDLE        : {count, ready, set_count, load_sr, en, baud_gen_init} = 6'b010000;
            
            INIT        : {count, ready, set_count, load_sr, en, baud_gen_init} = 6'b011001;
            
            CHECK_START : {count, ready, set_count, load_sr, en, baud_gen_init} = 6'b011010;
            
            WAIT_BIT    : {count, ready, set_count, load_sr, en, baud_gen_init} = 6'b000010;
                
            GET_BIT     : {count, ready, set_count, load_sr, en, baud_gen_init} = 6'b100110;
            
            WAIT_STOP   : {count, ready, set_count, load_sr, en, baud_gen_init} = 6'b000010;
            
            ERROR       : {count, ready, set_count, load_sr, en, baud_gen_init} = 6'b00x001;
            
            default     : {count, ready, set_count, load_sr, en, baud_gen_init} = 6'b01x001;
            
        endcase

endmodule
