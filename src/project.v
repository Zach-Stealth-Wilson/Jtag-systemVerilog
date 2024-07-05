/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
 
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings .a(ui_in[7:0]), .b(uio_in[7:0])
    wire _unused = &{ena, uio_in[7:0], ui_in[7:6], 1'b0};

    tt_um_jtag_test_logic top(.tck(clk), .tms(ui_in[0]), .tdi(ui_in[1]), .trst(rst_n), .tdo(uo_out[0]), .bsr_tdi(uo_out[1]), .bsr_clk(uo_out[2]), .bsr_update(uo_out[3]), .bsr_shift(uo_out[4]), .bsr_mode(uo_out[5]), .bsr_tdo(ui_in[2]), .sys_clk(ui_in[3]), .dbg_clk(uo_out[6]), .dm_reset(uo_out[7]), shiftIR(ui_in[4]), updateDRstate(ui_in[5]) );

endmodule
