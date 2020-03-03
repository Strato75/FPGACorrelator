`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera
// 
// Create Date:    11:49:29 03/20/2009 
// Design Name: 
// Module Name:    delay_line 
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
module delay_line #(parameter DEPTH=0, parameter DIM=16) 
(
    input clk,
    input clr,
    input stall,
    input [DIM-1:0] in_data,
    output [DIM-1:0] out_data
);

    generate 
        genvar i;
        if (DEPTH==0)
            begin:no_delay_line
                assign out_data = in_data;
            end
        else 
            begin:delay_line_generation
                reg [DIM-1:0] data_pipe_r [0:DEPTH-1]; 
                
                always @(posedge clk)
                    if (clr) 
                        data_pipe_r[0] <= 0;
                    else if (~stall)
                            data_pipe_r[0] <= in_data;
                
                for (i=1 ; i<DEPTH ; i=i+1)
                    begin:delay_line
                        always @(posedge clk)
                            if (clr)
                                data_pipe_r[i] <= 0;
                            else if (~stall)
                                    data_pipe_r[i] <= data_pipe_r[i-1];
                    end
                
                assign out_data=data_pipe_r[DEPTH-1];
            end
    endgenerate

endmodule
