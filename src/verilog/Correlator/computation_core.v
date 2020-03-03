`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera
// 
// Create Date:    18:51:35 12/13/2007 
// Design Name: 
// Module Name:    computation_core 
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
module computation_core
#(
    parameter   NSAMPLES        = 33'd8589934591,   // 2^33 samples approximate 10Msamples (f_sample 10MHz)
                LOG2_NSAMPLES   = 33,               // log2 NSAMPLES
                DIM_IN          = 16,               // Fixed Point Q15 2 complement
                MUL_OUT         = DIM_IN*2,         // Fixed Point Q30
                DIM_ADD         = 64,               // Output Format Q33,30
                DIM_OUT         = 64                // Output 32 Most significant bits
)    
(
    input clk,    
    input en,
    input clr,
    input  [DIM_IN-1:0] x,
    input  [DIM_IN-1:0] y,
    input  [DIM_IN-1:0] y90,

    output [DIM_OUT-1:0] sum_x_2,
    output [DIM_OUT-1:0] sum_xy,
    output [DIM_OUT-1:0] sum_y_2,
    output [DIM_OUT-1:0] sum_xy90,
    output [DIM_OUT-1:0] sum_y90_2,
    output [DIM_OUT-1:0] sum_y_y90
    
);

// Nets
    // DEBUGGING: the sample counter is sent back as sum_x_2
    //wire [63:0] dummy1;
    //wire [63:0] dummy2;
    //assign sum_x_2 = {{DIM_OUT-LOG2_NSAMPLES{1'b0}}, count};
    //assign sum_y_2 = {{DIM_OUT-LOG2_NSAMPLES{1'b0}}, NSAMPLES};
                
// Modules Instantiation
    
    comp_corr 
        #(DIM_IN,            
          NSAMPLES,
          LOG2_NSAMPLES,
          MUL_OUT,
          DIM_ADD)
            
        COMP_CORR1 (
        .clk(clk), 
        .clr(clr), 
        .en(en),
        .x(x), 
        .y(y), 
        //.sum_x2(dummy1), // DEBUGGING: the sample counter is sent back as sum_x_2
        .sum_x2(sum_x_2), 
        .sum_xy(sum_xy),
        //.sum_y2(dummy2) // DEBUGGING: the sample counter is sent back as sum_y_2                 
        .sum_y2(sum_y_2)
        );

    comp_corr  
        #(DIM_IN,            
          NSAMPLES,
          LOG2_NSAMPLES,
          MUL_OUT,
          DIM_ADD)
            
        COMP_CORR2 (
        .clk(clk), 
        .clr(clr),
        .en(en),                     
        .x(x), 
        .y(y90), 
        .sum_x2(Not_used), 
        .sum_xy(sum_xy90), 
        .sum_y2(sum_y90_2)
        );

    comp_corr 
        #(DIM_IN,            
          NSAMPLES,
          LOG2_NSAMPLES,
          MUL_OUT,
          DIM_ADD)
            
        COMP_CORR3 (
        .clk(clk), 
        .clr(clr), 
        .en(en),
        .x(y), 
        .y(y90), 
        //.sum_x2(dummy1), // DEBUGGING: the sample counter is sent back as sum_x_2
        .sum_x2(Not_used_2), 
        .sum_xy(sum_y_y90),
        //.sum_y2(dummy2) // DEBUGGING: the sample counter is sent back as sum_y_2                 
        .sum_y2(Not_used_3)
        );

endmodule
