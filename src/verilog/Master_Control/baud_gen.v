`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Giovanni Busonera
//
// Create Date:    18:19:23 09/12/2007 
// Design Name:      
// Module Name:    baud_gen 
// Project Name:       
// Target Devices: 
// Tool versions: 
// Description:    pulse train generator with configurable baud freq.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module baud_gen(clk, init_tx, init_rx, en_tx, en_rx, baud_pulse);

    parameter CLKFREQ = 100000000;
    parameter BAUD = 115200;

    parameter MAXCOUNT = (CLKFREQ/BAUD);
    parameter RESETVAL = MAXCOUNT/2;

    parameter DIM_CNT = 16;                 // Worst case dimension

    input clk;                              // Clock 
    input init_tx;                          // Set Counter to 0 
    input init_rx;                          // Set Counter to half MAXVALUE 
    input en_tx;                            // enable signal. If asserted pulses are generated
    input en_rx;                                    

    output reg baud_pulse;                  // Pulse train: period = 1/(2*BAUD)

    reg [DIM_CNT-1:0] count = RESETVAL;     // Initialization Safe Value

    assign en = en_tx | en_rx;

    always @(posedge clk)
        if (init_rx || init_tx)
            begin
                count <= init_tx ? 1 : RESETVAL;
                baud_pulse <= 0;
            end
        else 
            if (en)
                if (count == MAXCOUNT-1)    
                    begin
                        count <= 0;
                        baud_pulse <= 1;
                    end
                else
                    begin
                        count <= count + 1;
                        baud_pulse <= 0;
                    end

endmodule
