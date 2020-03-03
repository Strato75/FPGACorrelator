`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera 
// 
// Create Date:    16:02:33 03/22/2009 
// Design Name: 
// Module Name:    master_fsm 
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
module master_fsm(

    input sys_clk,
    input sys_rst,
    
        // from outside
    input start_button,
        // from decoder
    input start,
    input connect,
    input sw_reset,
    input set_samples,
        // from init_coeff
    input coeff_busy,
        // from send_results 
    input send_busy,
        // from uart 
    input uart_busy,
    input valid,
        // from Correlator
    input corr_busy,
    
        // to init_coeff
    output coeff_init,
        // to send_result
    output send_start,
        // to cr_muxes
    output [1:0] cr_sel,
        // uart_src_muxes
    output uart_src_sel,    
    output start_uart_tx_mc,
        // To write cr start stop clk_gen
    output we_mc,
        // To correlator
    output corr_reset,
    output sample_cnt_shift
);

    parameter   INIT_COEFF=0, INIT_CLK_GEN=1, WAIT_CONN=2, 
                CONN_ACK=3, WAIT_CORR=4, ELABORATION0=5, 
                ELABORATION1=6, SEND_RESULTS0=7, SEND_RESULTS1=8, 
                RESET_CORR=9, WAIT_CORR_BUSY=10, WAIT_SAMPLE_BYTE=11, SET_SAMPLES=12;

    reg [3:0] ns, cs;
    reg [8:0] moore_out;

    // Current State Refresh
    always @(posedge sys_clk)
        if (sys_rst)
            cs <= RESET_CORR;
        else
            cs <= ns;

    // Next State Logic
    always @*
        case (cs)
            RESET_CORR          :   ns = INIT_COEFF;
            
            INIT_COEFF          :   if (~coeff_busy)    
                                        ns = INIT_CLK_GEN;
                                    else
                                        ns = INIT_COEFF;
            
            INIT_CLK_GEN        :   ns = WAIT_CONN;
            
            WAIT_CONN           :   if (valid && connect)
                                        ns = CONN_ACK;
                                    else if (valid && sw_reset)
                                            ns = RESET_CORR;
                                        else
                                            ns = WAIT_CONN;
            
            CONN_ACK            :   if (uart_busy)
                                        ns = CONN_ACK;
                                    else
                                        ns = WAIT_CORR;
            
            WAIT_CORR           :   if ((valid && start) || start_button)
                                        ns = ELABORATION0;
                                    else if (valid && sw_reset)
                                            ns = RESET_CORR;
                                        else if (valid && set_samples)
                                                ns = WAIT_SAMPLE_BYTE;
                                            else
                                                ns = WAIT_CORR;
                            
            WAIT_SAMPLE_BYTE    :   if (valid)
                                        ns = SET_SAMPLES;
                                    else
                                        ns = WAIT_SAMPLE_BYTE;
            
            SET_SAMPLES         :   ns = CONN_ACK;
            
            ELABORATION0        :   ns = WAIT_CORR_BUSY;
                                            
            WAIT_CORR_BUSY      :   if (valid && sw_reset)
                                        ns = RESET_CORR;
                                    else if (corr_busy)
                                            ns = ELABORATION1;
                                        else
                                            ns = WAIT_CORR_BUSY;
            
            ELABORATION1        :   if (valid && sw_reset)
                                        ns = RESET_CORR;
                                    else if (corr_busy)
                                            ns = ELABORATION1;
                                        else
                                            ns = SEND_RESULTS0;
                                            
            SEND_RESULTS0       :   ns = SEND_RESULTS1;
            
            SEND_RESULTS1       :   if (send_busy)
                                        ns = SEND_RESULTS1;
                                    else
                                        ns = WAIT_CONN;
                
            default             :   ns = RESET_CORR;
        endcase
        
    // Moore Outputs
    assign {coeff_init, send_start, cr_sel, uart_src_sel, we_mc, start_uart_tx_mc, corr_reset, sample_cnt_shift} = moore_out;

    always @*
        case (cs)
            RESET_CORR          :   moore_out = 9'b1_0_00_0_0_0_1_0;
            INIT_COEFF          :   moore_out = 9'b1_0_00_0_0_0_0_0;
            INIT_CLK_GEN        :   moore_out = 9'b0_0_11_0_1_0_0_0;
            WAIT_CONN           :   moore_out = 9'b0_0_xx_0_0_0_0_0;
            CONN_ACK            :   moore_out = 9'b0_0_xx_0_0_1_0_0;
            WAIT_CORR           :   moore_out = 9'b0_0_xx_0_0_0_0_0;
            WAIT_SAMPLE_BYTE    :   moore_out = 9'b0_0_xx_0_0_0_0_0;
            SET_SAMPLES         :   moore_out = 9'b0_0_xx_0_0_0_0_1;
            ELABORATION0        :   moore_out = 9'b0_0_10_0_1_0_0_0;
            WAIT_CORR_BUSY      :   moore_out = 9'b0_0_xx_0_0_0_0_0;
            ELABORATION1        :   moore_out = 9'b0_0_xx_0_0_0_0_0;
            SEND_RESULTS0       :   moore_out = 9'b0_1_xx_1_0_0_0_0;
            SEND_RESULTS1       :   moore_out = 9'b0_0_xx_1_0_0_0_0;
            default             :   moore_out = 9'b1_0_00_0_0_0_1_0;
        endcase
        
endmodule
    
