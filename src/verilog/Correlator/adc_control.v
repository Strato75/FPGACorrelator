`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Engineer: Giovanni Busonera 
// 
// Create Date:    02:32:12 12/28/2007 
// Design Name: 
// Module Name:    adc_control 
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
module adc_control
(
    input clk,
    input clk_2x,
    input adc_clk_1,
    input adc_clk_2,
    input rst,
    input fifo_rst,
    
    input we,
    input fifo_read,
    
    input [1:0] delay_sel,
    
    input [7:0] clk_gen_cr,
    input [15:0] data_in_1,
    input [15:0] data_in_2,
    
    output empty_1,
    output empty_2,
    output clk_sample_p,
    output clk_sample_n,
    
    output [15:0] data_out_1,
    output [15:0] data_out_2
);

// Nets 
    wire clk_out_p;
    wire clk_out_n;
    wire full_1;
    wire full_2;
    wire fifo_write_1;
    wire fifo_write_2;
    wire [15:0] data_out_2_delay_0;

// Regs
    reg [15:0] data_out_delay_mux;
    reg [15:0] data_out_2_delay_1;
    reg [15:0] data_out_2_delay_3;
    reg [15:0] data_out_2_delay_2;
    
// Connections
    assign wr_en_1 = fifo_write_1;
    assign wr_en_2 = fifo_write_2;
    assign rd_en = fifo_read ;
    assign clk_sample_p = clk_out_p;
    assign clk_sample_n = clk_out_n;
    assign data_out_2 = data_out_delay_mux;
    
// Module Instances
    adc_fifo ADC_FIFO1(
        .din (data_in_1),
        .rd_clk (clk),
        .rd_en (rd_en),
        .rst (fifo_rst),
        .wr_clk (clk_2x),
        .wr_en (wr_en_1),
        .dout (data_out_1),
        .empty (empty_1),
        .full (full_1)
        );
        
    adc_fifo ADC_FIFO2(
        .din (data_in_2),
        .rd_clk (clk),
        .rd_en (rd_en),
        .rst (fifo_rst),
        .wr_clk (clk_2x),
        .wr_en (wr_en_2),
        .dout (data_out_2_delay_0),
        .empty (empty_2),
        .full (full_2)
        );
    
    clk_gen CLKSAMPLE_GEN (
        .clk_in_0(clk),
        .clk_in_2x (clk_2x),
        .we(we), 
        .cr(clk_gen_cr),  
        .clk_out_p(clk_out_p), 
        .clk_out_n(clk_out_n) 
        );
     
    fifo_write_controller FIFO_WR_CNT_1 (
        .clk_in_0(clk), 
        .clk_in_2x(clk_2x), 
        .rst(rst), 
        .adc_dav(adc_clk_1), 
        .we(we), 
        .cr(clk_gen_cr), 
        .fifo_write(fifo_write_1)
        );

    fifo_write_controller FIFO_WR_CNT_2 (
        .clk_in_0(clk), 
        .clk_in_2x(clk_2x), 
        .rst(rst), 
        .adc_dav(adc_clk_2), 
        .we(we), 
        .cr(clk_gen_cr), 
        .fifo_write(fifo_write_2)
        );     
     
     // Data_out_2 can be delayed until 3 sample delay
     always@(posedge clk)
     if (rst)
        begin
            data_out_2_delay_1 <= 0;
            data_out_2_delay_2 <= 0;
            data_out_2_delay_3 <= 0;
        end
     else if(fifo_read)
            begin
                data_out_2_delay_1 <= data_out_2_delay_0;
                data_out_2_delay_2 <= data_out_2_delay_1;
                data_out_2_delay_3 <= data_out_2_delay_2;
            end
    
    always @*
        case (delay_sel)
            2'b00   : data_out_delay_mux = data_out_2_delay_0;
            2'b01   : data_out_delay_mux = data_out_2_delay_1;
            2'b10   : data_out_delay_mux = data_out_2_delay_2;
            2'b11   : data_out_delay_mux = data_out_2_delay_3;
            default : data_out_delay_mux = data_out_2_delay_0;
        endcase
        
endmodule
