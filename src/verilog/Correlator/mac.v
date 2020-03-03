`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera 
// 
// Create Date:    00:49:06 01/20/2008 
// Design Name: 
// Module Name:    mac 
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
module mac
    #(parameter DIM_IN = 16, MUL_OUT = DIM_IN*2, DIM_ADD = 64)
(
    input clk,
    input clr,
    input en,
    
    input  signed [DIM_IN-1:0] a,
    input  signed [DIM_IN-1:0] b,
    
    output signed [DIM_ADD-1:0] out
);
    
    reg signed [DIM_IN-1:0] a_r;
    reg signed [DIM_IN-1:0] b_r;
    reg signed [MUL_OUT-1:0] mout_r_pipe;
    reg signed [MUL_OUT-1:0] mout_r;
    reg signed [DIM_ADD-1:0] aout_r;
    
    wire signed [MUL_OUT-1:0] mout;
    wire signed [DIM_ADD-1:0] aout; 
    
            
    //////////////
    // Datapath //
    //////////////
    
        // Registers
    always @(posedge clk)
    if (clr)
        begin    
            a_r         <= 0;        
            b_r         <= 0;
            mout_r      <= 0;
            mout_r_pipe <= 0;
            aout_r      <= 0;
        end
    else if (en)
                begin    
                    a_r         <= a;
                    b_r         <= b;    
                    mout_r_pipe <= ((a_r[15:0] == 16'h8000) && (b_r[15:0] == 16'h8000)) ? 32'h3FFFFFFF : mout; // -1 * -1 management
                    mout_r      <= mout_r_pipe; 
                    aout_r      <= aout;
                end
    
        // Multiplier
    assign mout = a_r * b_r;
    
        // Adder
    assign aout = mout_r + aout_r;
    
        // output signal
    assign out = aout_r;

endmodule
