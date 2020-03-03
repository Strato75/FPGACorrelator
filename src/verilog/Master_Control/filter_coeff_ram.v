/*******************************************************************************
*     This file is owned and controlled by Xilinx and must be used             *
*     solely for design, simulation, implementation and creation of            *
*     design files limited to Xilinx devices or technologies. Use              *
*     with non-Xilinx devices or technologies is expressly prohibited          *
*     and immediately terminates your license.                                 *
*                                                                              *
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"            *
*     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                  *
*     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION          *
*     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION              *
*     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS                *
*     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                  *
*     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE         *
*     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY                 *
*     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                  *
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR           *
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF          *
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS          *
*     FOR A PARTICULAR PURPOSE.                                                *
*                                                                              *
*     Xilinx products are not intended for use in life support                 *
*     appliances, devices, or systems. Use in such applications are            *
*     expressly prohibited.                                                    *
*                                                                              *
*     (c) Copyright 1995-2006 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// The synopsys directives "translate_off/translate_on" specified below are
// supported by XST, FPGA Compiler II, Mentor Graphics and Synplicity synthesis
// tools. Ensure they are correct for your synthesis tool(s).

// You must compile the wrapper file filter_coeff_ram.v when simulating
// the core, filter_coeff_ram. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

`timescale 1ns/1ps

module filter_coeff_ram
(
    clka,
    addra,
    douta
);

    input clka;
    input [7 : 0] addra;
    output [15 : 0] douta;

// synopsys translate_off

      BLK_MEM_GEN_V1_1 #(
        8,    // c_addra_width
        8,    // c_addrb_width
        1,    // c_algorithm
        9,    // c_byte_size
        0,    // c_common_clk
        "0",    // c_default_data
        0,    // c_disable_warn_bhv_coll
        0,    // c_disable_warn_bhv_range
        "virtex2p",    // c_family
        0,    // c_has_ena
        0,    // c_has_enb
        0,    // c_has_mem_output_regs
        0,    // c_has_mux_output_regs
        0,    // c_has_regcea
        0,    // c_has_regceb
        0,    // c_has_ssra
        0,    // c_has_ssrb
        "filter_coeff_ram.mif",    // c_init_file_name
        1,    // c_load_init_file
        3,    // c_mem_type
        1,    // c_prim_type
        256,    // c_read_depth_a
        256,    // c_read_depth_b
        16,    // c_read_width_a
        16,    // c_read_width_b
        "ALL",    // c_sim_collision_check
        "0",    // c_sinita_val
        "0",    // c_sinitb_val
        0,    // c_use_byte_wea
        0,    // c_use_byte_web
        1,    // c_use_default_data
        1,    // c_wea_width
        1,    // c_web_width
        256,    // c_write_depth_a
        256,    // c_write_depth_b
        "WRITE_FIRST",    // c_write_mode_a
        "WRITE_FIRST",    // c_write_mode_b
        16,    // c_write_width_a
        16)    // c_write_width_b
    inst (
        .CLKA(clka),
        .ADDRA(addra),
        .DOUTA(douta),
        .DINA(),
        .ENA(),
        .REGCEA(),
        .WEA(),
        .SSRA(),
        .CLKB(),
        .DINB(),
        .ADDRB(),
        .ENB(),
        .REGCEB(),
        .WEB(),
        .SSRB(),
        .DOUTB());

// synopsys translate_on

// FPGA Express black box declaration
// synopsys attribute fpga_dont_touch "true"
// synthesis attribute fpga_dont_touch of filter_coeff_ram is "true"

// XST black box declaration
// box_type "black_box"
// synthesis attribute box_type of filter_coeff_ram is "black_box"

endmodule

