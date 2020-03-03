`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
//
// Create Date:    10:25:40 09/13/2007 
// Design Name:    
// Module Name:    receiver_dp 
// Project Name:   
// Target Devices: 
// Tool versions: 
// Description:      Uart receiver datapath
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module receiver_dp(clk, rst, RxD, count, load_sr, set_count, 
                            end_count, data);

    // Input Ports
    input clk;
    input rst;
    input RxD;

    input count;
    input load_sr;
    input set_count;


    // Output Ports
    output end_count;
    output [7:0] data;

    // Regs
    reg [7:0] shift_reg;
    reg [2:0] count_reg;
     
    //
    // DATAPATH
    //

    // ShiftReg
    always @(posedge clk)
        if (rst)
            shift_reg <= 0;
        else if (load_sr)
                shift_reg <= {RxD,shift_reg[7:1]};

    // DownCounter
    always @(posedge clk)
        if (rst)
            count_reg <= 3'b111;
        else if (set_count)
                count_reg <= 3'b111;
            else if (count)
                    count_reg <= count_reg - 1;
                                        
    assign end_count = (count_reg == 0);
    assign data = shift_reg;

endmodule
