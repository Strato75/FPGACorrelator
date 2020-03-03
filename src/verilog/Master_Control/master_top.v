`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
// 
// Create Date:    20:11:46 03/25/2009 
// Design Name:    SRT Correlator Master Control
// Module Name:    master_top 
// Project Name:   SRT Correlator 
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
module master_top(

    input sys_clk,
    input sys_rst,
    input start_button,
    input uart_rx,
    
    input [31:0] sr_in,
    input [63:0] sum_x_2,
    input [63:0] sum_y_2,
    input [63:0] sum_xy,
    input [63:0] sum_xy90,
    input [63:0] sum_y90_2,
    input [63:0] sum_y_y90,
    
    output uart_tx,
    output corr_reset,
    output we,
    
    output sample_cnt_shift,
    output [7:0] uart_byte,
    output [31:0] cr
);


    wire [1:0] cr_sel;
    wire [7:0] res_byte;
    wire [7:0] connected_byte;
    wire [7:0] Byte_out;
    wire [7:0] Byte_in;

    wire [31:0] cr_coeff;
    wire [31:0] cr_clk_gen; 
    wire [31:0] cr_start; 
    wire [31:0] cr_stop;

    // CONSTANT VALUES

    //  // 12 val in Clk_gen (--> about 16,75MHz Sampling clock if clk_2x=200MHz --> 200/12(1100) = 16,666...)
    //  assign cr_clk_gen    = 32'b0000000000000000_00001100_00001000; 
    //  8 val in Clk_gen (--> 25Mhz Sampling clock if clk_2x=200MHz --> 200/8(1000) = 25...)
    assign cr_clk_gen    = 32'b0000000000000000_00001000_00001000; 
    // Start and stop CR
    assign cr_start     = 32'b0000000000000000_00000000_00000001; 
    assign cr_stop      = 32'b0000000000000000_00000000_00000000;
    // Conncected byte response: A char
    assign connected_byte = 8'd65;
    // Send incoming byte outside the module
    assign uart_byte = Byte_in;

    // SR_DECODE
    sr_decode SR_DECODE (
        .sr(sr_in), 
        .corr_busy(corr_busy), 
        .failure(failure)
        );
         
    // INIT COEFF MODULE
    init_coeff INIT_COEFF (
        .sys_clk(sys_clk), 
        .sys_rst(sys_rst), 
        .coeff_init(coeff_init), 
        .coeff_busy(coeff_busy), 
        .we_coeff(we_coeff), 
        .cr_coeff(cr_coeff)
        );
         
    // SEND RESULT MODULE
    send_results SEND_RESULTS (
        .sys_clk(sys_clk), 
        .sys_rst(sys_rst), 
        .send_start(send_start), 
        .uart_busy(uart_busy), 
        .sum_x_2(sum_x_2), 
        .sum_y_2(sum_y_2), 
        .sum_xy(sum_xy), 
        .sum_xy90(sum_xy90), 
        .sum_y90_2(sum_y90_2),
        .sum_y_y90(sum_y_y90),
        .send_busy(send_busy), 
        .start_uart_tx_res(start_uart_tx_res), 
        .res_byte(res_byte)
        );

    // DECODER
    decoder DECODER (
        .Byte_in(Byte_in), 
        .start(start), 
        .connect(connect),
        .sw_reset(sw_reset),
        .set_samples(set_samples)
        );

    // CR MUXES
    cr_muxes CR_MUXES (
        .we_coeff(we_coeff), 
        .we_mc(we_mc), 
        .cr_sel(cr_sel), 
        .cr_coeff(cr_coeff), 
        .cr_start(cr_start), 
        .cr_stop(cr_stop), 
        .cr_clk_gen(cr_clk_gen), 
        .we(we), 
        .cr(cr)
        );
         
    // UART_SRC_MUXES
    uart_src_muxes UART_SRC_MUXES (
        .uart_src_sel(uart_src_sel), 
        .start_uart_tx_res(start_uart_tx_res), 
        .start_uart_tx_mc(start_uart_tx_mc), 
        .res_byte(res_byte), 
        .connected_byte(connected_byte),
        .TxD_Start(TxD_Start),
        .Byte_out(Byte_out)
        );

    // UART MODULE
    uart #(100000000, 115200)
        UART_MODULE (
        .clk(sys_clk), 
        .rst(sys_rst), 
        .RxD(uart_rx), 
        .TxD_Start(TxD_Start), 
        .TxD_Data(Byte_out), 
        .TxD(uart_tx), 
        .valid(valid), 
        .busy(uart_busy), 
        .Byte_Data(Byte_in)
        );

    // MASTER FSM
    master_fsm MASTER_FSM (
        .sys_clk(sys_clk), 
        .sys_rst(sys_rst), 
        .start_button(start_button),
        .start(start), 
        .connect(connect), 
        .sw_reset(sw_reset),
        .set_samples(set_samples),
        .coeff_busy(coeff_busy), 
        .send_busy(send_busy), 
        .uart_busy(uart_busy), 
        .valid(valid), 
        .corr_busy(corr_busy),
        .coeff_init(coeff_init), 
        .send_start(send_start), 
        .cr_sel(cr_sel), 
        .uart_src_sel(uart_src_sel),
        .start_uart_tx_mc(start_uart_tx_mc),     
        .we_mc(we_mc),
        .corr_reset(corr_reset),
        .sample_cnt_shift(sample_cnt_shift)
        );

endmodule
