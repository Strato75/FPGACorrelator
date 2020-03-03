`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:00:32 10/23/2010 
// Design Name: 
// Module Name:    fifo_write_controller 
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
module fifo_write_controller(
    input clk_in_0,
    input clk_in_2x,
    input rst,
    input adc_dav,
    input we,
    input [7:0] cr,
    
    output fifo_write
    );

    //parameter IDLE=0, SYNC=1, WAIT_RIGHT_POSEDGE=2, STORE_IF_TRIGGED=3, WAIT_TRIGGER=4;
    parameter IDLE=0, P0=1, P1=2, P2=3, W0=4, W1=5, WAIT4WRITE=6, WRITE=7, WAIT_TRIGGER=8;
    
//    reg trigger;
    reg [7:0] counter = 0;
    reg [7:0] max_count_r;
    reg [3:0] ns, cs;
    reg [1:0] out;
    reg [1:0] dav_probe;
    
    wire trigger;
    wire dav_low;
    wire dav_posedge;
    wire dav_negedge;
    wire clr;
    
// MAIN CONTROL
    always @(posedge clk_in_2x)
        if (rst || we)
            cs <= IDLE;
        else
            cs <= ns;

    always @(cs, dav_posedge, dav_low, trigger)
        case (cs)
            IDLE            :   if (dav_low)
                                    ns = P0;
                                else
                                    ns = IDLE;
                                                
            P0              :   if (dav_low)
                                    ns = P1;
                                 else 
                                    ns = IDLE;
                                            
            P1              :   if (dav_posedge)
                                    ns = W0;
                                else if (dav_low)
                                        ns = P2;
                                    else
                                        ns = IDLE;
                                
            P2              :   if (dav_posedge)
                                    ns = W0;
                                else 
                                    ns = IDLE;
            
            W0              :   ns = W1;
            
            W1              :   ns = WAIT4WRITE;
            
            WAIT4WRITE      :   if (trigger)
                                    ns = WRITE;
                                else
                                    ns = WAIT4WRITE;
                                                
            WRITE           :   ns = WAIT_TRIGGER;
                                            
            WAIT_TRIGGER    :   if (trigger)
                                    ns = WAIT4WRITE;
                                else
                                    ns = WAIT_TRIGGER;

            default         :    ns = IDLE;
        endcase

    assign {clr, fifo_write} = out;
    
    always @(cs, dav_posedge, dav_low, trigger)
        case (cs)
            IDLE            :   out = 2'b10;
                                        
            P0              :   out = 2'b10;
                                                
            P1              :   out = 2'b10;
            
            P2              :   out = 2'b10;
                                        
            W0              :   out = 2'b10;
            
            W1              :   out = 2'b10;
            
            WAIT4WRITE      :   if (trigger)
                                    out = 2'b10;
                                else
                                    out = 2'b00;
                                                
            WRITE           :   out = 2'b01;
                                            
            WAIT_TRIGGER    :   if (trigger)
                                    out = 2'b10;
                                else
                                    out = 2'b00;
                                                
            default         :   out = 2'b00;
        endcase

        
// TIME Counter
    always @(posedge clk_in_2x)
        if (clr)
            counter = max_count_r;
        else
            counter = counter - 1;

// Trigger signal
    assign trigger = counter == 0;
            
    
// dav signal edge detector
    always @(posedge clk_in_2x)
        dav_probe = {dav_probe[0], adc_dav};
    
    assign dav_posedge  = dav_probe == 2'b01;
    assign dav_negedge  = dav_probe == 2'b10;
    assign dav_low      = dav_probe == 2'b00;
    
// Maxcount Register
    always @(posedge clk_in_0) 
        if (we)
            max_count_r <= ({1'b0,cr[7:1]}-1);

endmodule
