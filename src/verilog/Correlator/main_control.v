`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  
//     
// Engineer: Giovanni Busonera 
// 
// Create Date:    15:59:36 01/17/2008 
// Design Name: 
// Module Name:    main_control 
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
module main_control
(
    input clk,
    input rst,
    input start,
    input stop,
    input done,
    input empty_1,
    input empty_2,
    
    output fifo_read,
    output fifo_rst,
    output stall,
    output clr,
    output failure
);
    
    parameter IDLE=0, CLR_EMPTY_FIFO=1, WAIT_NO_EMPTY=2, COMPUTE=3, FAILURE=4;
    
    reg [2:0] ns, cs;
    reg [2:0] out;
    reg [1:0] mealy_out;
    //reg [4:0] out;
    
    // Current State refresh
    always @(posedge clk)
        if (rst)
            cs <= IDLE;
        else
            cs <= ns;
    
    // Next State Logic
    always @(cs, start, stop, done, empty_1, empty_2)
        case (cs)
            IDLE            :   if (start)
                                    ns = CLR_EMPTY_FIFO;
                                else 
                                    ns = IDLE;
            
            CLR_EMPTY_FIFO  :   if (~empty_1 && ~empty_2)
                                    ns = CLR_EMPTY_FIFO;
                                else    
                                    ns = WAIT_NO_EMPTY;
            
            WAIT_NO_EMPTY   :   if (stop)
                                    ns = IDLE;
                                else if (~empty_1 && ~empty_2)
                                        ns = COMPUTE;
                                    else
                                        ns = WAIT_NO_EMPTY;
            
            COMPUTE         :   if (stop || done)
                                    ns = IDLE;
                                else if (empty_1 || empty_2)
                                        ns = WAIT_NO_EMPTY;
                                    else
                                        ns = COMPUTE;
                                    
                                    
            FAILURE         :   ns = FAILURE;
            
            default         :   ns = IDLE;
        endcase
        
    // Output Logic
    
    assign {fifo_rst, clr, failure} = out;
    
    always @(cs)
        case (cs)
            IDLE            :    out = 3'b000;
            CLR_EMPTY_FIFO  :    out = 3'b110;
            WAIT_NO_EMPTY   :    out = 3'b000;
            COMPUTE         :    out = 3'b000;
            FAILURE         :    out = 3'b001;
            default         :    out = 3'b000;
        endcase
        
    assign {fifo_read, stall} = mealy_out;
    
    always @*
        case (cs)
            CLR_EMPTY_FIFO  :   mealy_out = 2'b01;
            WAIT_NO_EMPTY   :   if (~empty_1 && ~empty_2)
                                    mealy_out = 2'b11;
                                else
                                    mealy_out = 2'b01;
            COMPUTE         :   if (stop || done)
                                    mealy_out = 2'b01;
                                else if (~empty_1 && ~empty_2)
                                        mealy_out = 2'b10;
                                    else if (empty_1 || empty_2)
                                            mealy_out = 2'b00;                                    
            default         :   mealy_out = 2'b01;
        endcase
        
endmodule


///////////////////////////////////////////////////////////
/// ALL MOORE OUTPUT IMPLEMENTATION OF THE MAIN CONTROL ///
///////////////////////////////////////////////////////////

module main_control_moore(

    input clk,
    input rst,
    input start,
    input stop,
    input done,
    input empty_1,
    input empty_2,
    
    output fifo_read,
    output fifo_rst,
    output stall,
    output clr,
    output failure
    );
    
    parameter IDLE=0, CLR_EMPTY_FIFO=1, WAIT_NO_EMPTY=2, RAISE_READ=3, COMPUTE_NOT_READ=4, FAILURE=5;
    
    reg [2:0] ns, cs;
    reg [4:0] out;
    
    // Current State refresh
    always @(posedge clk)
        if (rst)
            cs <= IDLE;
        else
            cs <= ns;
    
    // Next State Logic
    always @(cs, start, stop, done, empty_1, empty_2)
        case (cs)
            IDLE                :   if (start)
                                        ns = CLR_EMPTY_FIFO;
                                    else 
                                        ns = IDLE;
                
            CLR_EMPTY_FIFO      :   if (~empty_1 && ~empty_2)
                                        ns = CLR_EMPTY_FIFO;
                                    else    
                                        ns = WAIT_NO_EMPTY;
            
            WAIT_NO_EMPTY       :   if (stop)
                                        ns = IDLE;
                                    else if (~empty_1 && ~empty_2)
                                            ns = RAISE_READ;
                                        else
                                            ns = WAIT_NO_EMPTY;

            RAISE_READ          :   ns = COMPUTE_NOT_READ;
                    
            COMPUTE_NOT_READ    :   if (stop || done)
                                        ns = IDLE;
                                    else if (empty_1 || empty_2)
                                            ns = WAIT_NO_EMPTY;
                                        else
                                            ns = RAISE_READ;
                                        
            FAILURE             :    ns = FAILURE;
            
            default             :    ns = IDLE;
        endcase
        
    // Output Logic
    
    assign {fifo_rst, clr, failure, fifo_read, stall} = out;
    
    always @(cs)
        case (cs)
            IDLE                :    out = 5'b00001;
            CLR_EMPTY_FIFO      :    out = 5'b11001;
            WAIT_NO_EMPTY       :    out = 5'b00001;
            RAISE_READ          :    out = 5'b00011;
            COMPUTE_NOT_READ    :    out = 5'b00000;
            default             :    out = 5'b00001;
        endcase
            
endmodule
