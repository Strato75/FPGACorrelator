`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera
// 
// Create Date:    17:14:59 05/16/2007 
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
module fir_bel(clk, clr, en, coeff_in, data_in, adder_in, adder_out);

    parameter DIM_DATA = 16;
    parameter DIM_COEFF = 16; 
    parameter DIM_ADDER_IN = 32;
    parameter DIM_ADDER_OUT = 32;
    
    
    input clk, clr, en;
    input signed[DIM_DATA-1:0] data_in;
    input signed[DIM_COEFF-1:0] coeff_in;
    input signed[DIM_ADDER_IN-1:0] adder_in;
    
    output signed[DIM_ADDER_OUT-1:0] adder_out;

// Regs
    reg signed [DIM_DATA+DIM_COEFF-1:0] mul_out_r;
    reg signed [DIM_ADDER_IN-1:0] adder_out_r;
        

// Datapath
    always @(posedge clk)
    if (clr) 
        begin
            mul_out_r   <= 0;
            adder_out_r <= 0;
        end
    else if (en)
                begin
                    mul_out_r   <= data_in * coeff_in;
                    adder_out_r <= adder_in + mul_out_r;
                end
                
// Output Connection        
    assign adder_out = adder_out_r;

endmodule
