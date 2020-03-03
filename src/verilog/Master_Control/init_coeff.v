`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Giovanni Busonera
// 
// Create Date:    00:47:51 03/27/2009 
// Design Name:     SRT Correlator Master Control
// Module Name:    init_coeff 
// Project Name:  SRT Correlator
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
module init_coeff
#(parameter LPF_X_COEFF = 32, LPF_Y_COEFF = 32, parameter HPF_COEFF = 96)
(

    input sys_clk,
    input sys_rst,
    input coeff_init,
    
    output coeff_busy,
    output we_coeff,
    output [31:0] cr_coeff

);

    parameter IDLE = 0, CLR = 1, WAIT_RD = 2, SEND = 3, UP = 4;
    parameter LPF_X_WE_OP = 8'b0100_0100;
    parameter LPF_Y_WE_OP = 8'b0100_0101;
    parameter HPF_WE_OP = 8'b0100_0110;

    reg [2:0] ns, cs;
    reg [1:0] filter_sel;
    reg [7:0] num_coeff;
    reg [7:0] opcodes; 
    reg [7:0] num_coeff_r;
    reg [7:0] opcodes_r; 

    reg [7:0] count_lpf_x;
    reg [7:0] count_lpf_y;
    reg [7:0] count_hpf;
    reg [3:0] moore_out;

    wire clr;
    wire hit_lpf_x;
    wire hit_lpf_y;
    wire hit_hpf;
    wire up;
    wire [7:0] addra;
    wire [15:0] douta;


    // ROM Module
    filter_coeff_ram ROM_COEFF(
        .clk (sys_clk),
        .a (addra),
        .qspo (douta)
        );

// Delay Registers. Used because ROM shows a 1 tick latency.
    always @(posedge sys_clk)
        begin
            num_coeff_r <= num_coeff;
            opcodes_r   <= opcodes;
        end
        
// Counters
    always @(posedge sys_clk)
        if (clr) 
            count_lpf_x <= 0;
        else if (~hit_lpf_x & up)
                count_lpf_x <= count_lpf_x + 1;
    assign hit_lpf_x = (count_lpf_x == LPF_X_COEFF);        

    always @(posedge sys_clk)
        if (clr) 
            count_lpf_y <= 0;
        else if (hit_lpf_x & ~hit_lpf_y & up)
                count_lpf_y <= count_lpf_y + 1;
    assign hit_lpf_y = (count_lpf_y == LPF_Y_COEFF);    

    always @(posedge sys_clk)
        if (clr) 
            count_hpf <= 0;
        else if (hit_lpf_y & ~hit_hpf & up)
                count_hpf <= count_hpf + 1;
    assign hit_hpf = (count_hpf == HPF_COEFF);        
                    
// Encoder
    always@*
        case ({hit_lpf_y, hit_lpf_x})
            2'b00   :   filter_sel = 2'b00;
            2'b01   :   filter_sel = 2'b01;
            2'b11   :   filter_sel = 2'b10;
            default :   filter_sel = 2'bx;
        endcase

// Muxes
    always @*
        case (filter_sel)
            2'b00   :   num_coeff = count_lpf_x;
            2'b01   :   num_coeff = count_lpf_y;
            2'b10   :   num_coeff = count_hpf;
            default :   num_coeff = 8'bx;
        endcase
        
    always @*
        case (filter_sel)
            2'b00   :   opcodes = LPF_X_WE_OP;
            2'b01   :   opcodes = LPF_Y_WE_OP;
            2'b10   :   opcodes = HPF_WE_OP;
            default :   opcodes = 8'bx;
        endcase
    
// Assigns
    assign addra = count_lpf_x + count_lpf_y + count_hpf;
    assign cr_coeff = {douta, num_coeff_r, opcodes_r};

// FSM
    // Refresh cr
    always @(posedge sys_clk)
        if (sys_rst)
            cs <= IDLE;
        else
            cs <= ns;
            
    // Next State Logic
    always @*
        case (cs)
            IDLE    :   if (coeff_init)
                            ns = CLR;
                        else
                            ns = IDLE;
                                
            CLR     :   ns = WAIT_RD;
            
            WAIT_RD :   ns = SEND;
            
            SEND    :   if (hit_hpf)
                            ns = IDLE;
                        else
                            ns = UP;
            
            UP      :   ns = WAIT_RD;
                            
            default :   ns = IDLE;
        endcase
    
    // Moore Outputs
    assign {clr, we_coeff, coeff_busy, up} = moore_out;
    
    always @*
        case (cs)
            IDLE    :   moore_out = 4'b0000;
            CLR     :   moore_out = 4'b1010;
            WAIT_RD :   moore_out = 4'b0010;
            SEND    :   moore_out = 4'b0110;
            UP      :   moore_out = 4'b0011;
            default :   moore_out = 4'b0000;
        endcase
    
endmodule
