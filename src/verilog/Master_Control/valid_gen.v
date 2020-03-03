`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
// 
// Create Date:    00:38:23 09/21/2007 
// Design Name:   
// Module Name:    valid_gen 
// Project Name:   
// Target Devices: 
// Tool versions: 
// Description:    This modules generates a pulse everytime a byte is incoming 
//                         from serial line
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module valid_gen(clk, rst, ready, valid_r);

    parameter IDLE=0, WAIT=1;

    input clk;
    input rst;
    input ready;

    output reg valid_r;

    reg cs, ns;
    reg valid;

    always @(posedge clk)
        if (rst)
            cs <= IDLE;
        else
            cs <= ns;
        
    always @(cs, ready)
        case (cs)
            IDLE    :   if (~ready) 
                            begin ns = WAIT; valid = 0; end
                        else
                            begin ns = IDLE; valid = 0; end
            
            WAIT    :   if (~ready) 
                            begin ns = WAIT; valid = 0; end
                        else
                            begin ns = IDLE; valid = 1; end
                                
            default :   begin ns = WAIT; valid = 0; end
        endcase

    // Output registred
    always @(posedge clk)
        valid_r <= valid;

endmodule
