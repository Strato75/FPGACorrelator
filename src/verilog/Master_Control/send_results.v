`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera 
// 
// Create Date:    20:39:40 03/25/2009 
// Design Name:      SRT Correlator Master Control
// Module Name:    send_results 
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
module send_results
(

    input sys_clk,
    input sys_rst,
    
    input send_start,
    input uart_busy,
    input [63:0] sum_x_2,
    input [63:0] sum_y_2,
    input [63:0] sum_xy,
    input [63:0] sum_xy90,
    input [63:0] sum_y90_2,
    input [63:0] sum_y_y90,
    
    output send_busy,
    output start_uart_tx_res,
    output [7:0] res_byte
);

    parameter IDLE=0, LD_RES=1, SH_BYTE=2, SEND_BYTE=3, WAIT_UART=4, COUNT_UP=5;
    
    reg [2:0] ns, cs;
    
    reg [5:0] count40_r;
    reg [2:0] count8_r;
    
    reg [7:0] moore_out;
    reg [7:0] res_byte_r;
    reg [383:0] res_r;
    
    wire bit_res;
    wire clr;
    wire ld_res;
    wire sh_res;
    wire sh_byte;
    wire count8; 
    wire count40;
    

//////////////
// DATAPATH //
//////////////
    
    // Registers
    
    always @(posedge sys_clk)
        if (ld_res)    
            res_r <= {sum_x_2, sum_y_2, sum_xy, sum_xy90, sum_y90_2, sum_y_y90};
        else if (sh_res)
                res_r <= {1'b0, res_r[383:1]};
    
    always @(posedge sys_clk) 
        if (sh_byte)
            res_byte_r <= {bit_res, res_byte[7:1]};
    
    assign bit_res = res_r[0];
    assign res_byte = res_byte_r;

    // Counters
        // Counter40
    always @(posedge sys_clk)
        if (clr) 
            count40_r <= 0;
        else if (count40)
                count40_r <= count40_r + 1;
                
        // Counter8
    always @(posedge sys_clk)
        if (clr) 
            count8_r <= 0;
        else if (count8)
                count8_r <= count8_r + 1;

    assign hit40 = (count40_r == 6'd47);
    assign hit8 = (count8_r == 3'd7);
    
/////////////
// CONTROL //
/////////////

    
    // Refresh State 
    always @(posedge sys_clk)
        if (sys_rst)
            cs <= IDLE;
        else
            cs <= ns;
            
    // Next State Logic
    always @(cs, uart_busy, send_start, hit8, hit40)
        case (cs)
            IDLE        :   if (send_start)    
                                ns = LD_RES;
                            else
                                ns = IDLE;

            LD_RES      :   ns = SH_BYTE;
            
            SH_BYTE     :   if (hit8)
                                ns = SEND_BYTE;
                            else
                                ns = SH_BYTE;

            SEND_BYTE   :   ns = WAIT_UART;
            
            WAIT_UART   :   if (uart_busy)    
                                ns = WAIT_UART;
                            else
                                ns = COUNT_UP;
            
            COUNT_UP    :   if (hit40)
                                ns = IDLE;
                            else
                                ns = SH_BYTE;
                                    
            default     :   ns = IDLE;
        endcase
    
    // Moore Outputs
    assign  {clr, send_busy, ld_res, sh_res, sh_byte, count8, count40, start_uart_tx_res} = moore_out;
    
    always @(cs)
        case (cs)
            IDLE        :   moore_out = 8'b1_0_00_0_00_0;
            LD_RES      :   moore_out = 8'b0_1_10_0_00_0;
            SH_BYTE     :   moore_out = 8'b0_1_01_1_10_0;
            SEND_BYTE   :   moore_out = 8'b0_1_00_0_00_1;
            WAIT_UART   :   moore_out = 8'b0_1_00_0_00_0;
            COUNT_UP    :   moore_out = 8'b0_1_00_0_01_0;
            default     :   moore_out = 8'b1_0_00_0_00_0;
        endcase
        
endmodule
