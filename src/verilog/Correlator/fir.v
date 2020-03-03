`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera
// 
// Create Date:    18:35:52 05/16/2007 
// Design Name: 
// Module Name:    fir 
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
module fir(clk, rst, we_in, stall, clr, cr_in, data_in, data_out);
    
    parameter TAP = 32;
    parameter LOG2TAP = 5;
    parameter DIM_DATA = 16;     
    parameter DIM_COEFF = 16;
    parameter DIM_ADDER_IN = 32;
    parameter DIM_ADDER_OUT = 32;

    input clk;
    input rst;
    input we_in;
    input stall;
    input clr;
    input [31:0] cr_in;
    input signed [DIM_DATA-1:0] data_in;

    output signed [DIM_DATA-1:0] data_out;
     
// Declarations
    
    reg [31:0] cr_r;
    reg [DIM_COEFF-1:0] coeff_r [0:TAP-1];
     
    wire [DIM_ADDER_IN-1:0] adder_in [TAP-1:0];
    wire [DIM_ADDER_OUT-1:0] adder_out [TAP-1:0];
    wire [TAP-1:0] c_sto_bus;
    wire [DIM_COEFF-1:0] coeff_value;
    wire [3:0] opcodeII;
    wire [7:0] n_coeff;

// Connections
    assign opcodeII     = cr_r [7:4];
    assign n_coeff      = cr_r [15:8];
    assign coeff_value  = cr_r [31:16];
    assign data_out     = adder_out[TAP-1][30:15];
    assign mac_en       = ~stall;
    assign mac_clr      = clr;

//////////////////////
// CONTROL INSTANCE //
//////////////////////
     
    fir_control FIR_CONTROL (
        .clk(clk), 
        .rst(rst), 
        .we_in(we_in), 
        .opcodeII(opcodeII), 
        .c_clr(c_clr), 
        .c_sto(c_sto)
    );


//////////////
// DATAPATH    //
//////////////
 
// MAC MODULE INSTANCES
     
    genvar i;
     
    fir_bel FIR_BEL_0 (
        .clk(clk), 
        .clr(mac_clr), 
        .en(mac_en),
        .coeff_in(coeff_r[TAP-1]), 
        .data_in(data_in), 
        .adder_in({DIM_ADDER_IN{1'b0}}), 
        .adder_out(adder_out[0])
    );
    
    generate 
        for (i=1; i<TAP; i=i+1)
            begin:FIR_BELS
                fir_bel FIR_BEL (
                    .clk(clk), 
                    .clr(mac_clr), 
                    .en(mac_en),
                    .coeff_in(coeff_r[TAP-1-i]), 
                    .data_in(data_in), 
                    .adder_in(adder_out[i-1]), 
                    .adder_out(adder_out[i])
                );
            end
    endgenerate

// CONTROL REGISTER
    always @(posedge clk)
        if (rst)
            cr_r <= 0;
        else if (we_in)
                cr_r <= cr_in;
                                    
// Coefficients Registers
    generate
        for (i=0 ; i<TAP ; i=i+1)
            begin:coeff_registers
                always @(posedge clk)
                    if (c_clr)
                        coeff_r[i] <= 0;
                    else if (c_sto_bus[i])
                            coeff_r[i] <= coeff_value;
            end
    endgenerate
    
// Parametric Decoder for c_sto signal
    generate 
        for (i=0 ; i<TAP ; i=i+1)
            begin:decoder_par
                assign c_sto_bus[i] = c_sto && (i==n_coeff);
            end
    endgenerate

endmodule
