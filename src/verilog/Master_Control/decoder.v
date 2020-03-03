`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:15:42 03/27/2009 
// Design Name: 
// Module Name:    decoder 
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
module decoder(

    input [7:0] Byte_in,
    output start,
    output connect,
    output sw_reset,
    output set_samples
    
);

    parameter CONNECT_BYTE      = 8'd99; // Char c --> connection request
    parameter START_BYTE        = 8'd115; // Char s --> start correlation request
    parameter RESET_BYTE        = 8'd114; // Char r --> Force a system reset
    parameter SET_SAMPLES_BYTE  = 8'd116; // Char t --> if followed by a byte o the 4 word lenght sample_counter  
    reg [3:0] out;

    always @(Byte_in)
        case (Byte_in)
            CONNECT_BYTE        : out = 4'b0100;    
            START_BYTE          : out = 4'b0010;
            RESET_BYTE          : out = 4'b1000;
            SET_SAMPLES_BYTE    : out = 4'b0001;
            default             : out = 4'b0000;
        endcase
        
    assign {sw_reset, connect, start, set_samples} = out;

endmodule
