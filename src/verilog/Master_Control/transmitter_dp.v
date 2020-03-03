`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
//
// Create Date:    00:16:07 09/14/2007 
// Design Name:    
// Module Name:    transmitter_dp 
// Project Name:   
// Target Devices: 
// Tool versions: 
// Description:    Uart transmitter datapath
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module transmitter_dp(clk, load_data, shift, count, set_count, out_sel, TxD_Data, 
                                end_count, TxD);

    input clk;
    input load_data;
    input shift;
    input count;
    input set_count;
    input [1:0] out_sel;
    input [7:0] TxD_Data;

    output end_count;
    output reg TxD;

    reg end_count;
    reg mux_out;
    reg [2:0] count_reg;
    reg [7:0] shift_reg;

    // Shift Register
    always @(posedge clk)
        if (load_data)
            shift_reg <= TxD_Data;
        else if (shift)
                shift_reg <= {1'b1,shift_reg[7:1]};
            
    //Mux
    always @(out_sel, shift_reg)
        case(out_sel)
            2'b00   : mux_out = 0;
            2'b01   : mux_out = shift_reg[0];
            2'b10   : mux_out = 1;
            default : mux_out = 1;
        endcase

    // DownCounter
    always @(posedge clk)
        if (set_count)
            begin
                count_reg <= 3'b111;
                end_count <= 1'b0;
            end
        else if (count)
                begin
                    count_reg <= count_reg - 1;
                    end_count <= (count_reg == 0);
                end
            else 
                end_count <= 1'b0;

    // output reg
    always @(posedge clk)
        TxD <= mux_out;
        
endmodule
