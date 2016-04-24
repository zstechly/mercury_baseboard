/*
MIT License

Copyright (c) [2016] [Zach Stechly]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
module mercury_top
(
 input  wire         EXT_CLK,
 input  wire         CLK, 

 // buttons, logic low when pressed
// input  wire         USR_BTN,
// input  wire [03:00] BTN,

 // VGA stuff
 output wire [02:00] RED,
 output wire [02:00] GRN,
 output wire [01:00] BLU,
 output wire         HSYNC,
 output wire         VSYNC,

 // switches, logic high when in the up position, logic low when in the low position
 input  wire [07:00] SW,

 // 7 segment display
 // Output 0 to AN3 to control segmengs A-G, dot on 
 // the left most character.
 // AN's are active low, A_TO_G, DOT, active low
 output wire [03:00] AN,
 output wire [06:00] A_TO_G,
 output wire         DOT,

 // PS/2 inputs 
 input  wire         PS2_DATA,
 input  wire         PS2_CLK
);

// hang reset off of pll_locked and button pushes
wire  pll_reset;

// DCM outputs
wire  app_clk100, app_arst100_n;
wire  app_clk25,  app_arst25_n;
wire  app_clk50,  app_arst50_n;
wire  pll_locked;

// VGA output
wire          vsync_out;
wire          hsync_out;
wire [02:00]  red_out;
wire [02:00]  green_out;
wire [01:00]  blue_out;
reg           red_in_r;
// Eight Segment display logic
wire [06:00]  A_TO_G0_in;
wire [06:00]  A_TO_G1_in;
wire [06:00]  A_TO_G2_in;
wire [06:00]  A_TO_G3_in;
wire [03:00]  DOTS_in;
wire [06:00]  A_TO_G_out;
wire          DOTS_out;
wire [03:00]  AN_out;     

// ps/2 data
wire         ps2_data_ena;
wire [07:00] ps2_data_out;

// Xilinx DCM
// should be active high reset
assign pll_reset = SW[0];

mercury_dcm merc_dcm
(
  .CLKIN_IN            (CLK),
  .RST_IN              (pll_reset), 
  .CLKDV_OUT           (app_clk25), 
  .CLKIN_IBUFG_OUT     (app_clk50), 
  .CLK0_OUT            (), 
  .CLK2X_OUT           (app_clk100), 
  .LOCKED_OUT          (pll_locked)
);

// hold modules in reset until pll is locked
assign app_arst100_n = pll_locked;
assign app_arst50_n  = pll_locked;
assign app_arst25_n  = pll_locked;

// lets throw a VGA thing into this
always @(posedge app_clk25) begin
  red_in_r    <= (ps2_data_out == 8'h15);
end

vga_sync vga_module
(
   .app_clk     (   app_clk25),
   .app_arst_n  (app_arst25_n),
   .red_in      (    red_in_r),
   .vsync       (   vsync_out),
   .hsync       (   hsync_out),
   .red         (   red_out  ),
   .green       (   green_out),
   .blue        (   blue_out )
);

// 8 segment display module
assign A_TO_G0_in = 7'b1001111; //1
assign A_TO_G1_in = 7'b0010010; //2 
assign A_TO_G2_in = 7'b0000110; //3 
assign A_TO_G3_in = 7'b1001100; //4 
assign DOTS_in    = 4'b1010; // off on off on
mercury_8seg eight_seg
(
     .app_clk         (   app_clk50),
     .app_arst_n      (app_arst50_n),
     
     .enable          (       SW[1]), 
     .A_TO_G0_in      (  A_TO_G0_in),
     .A_TO_G1_in      (  A_TO_G1_in),
     .A_TO_G2_in      (  A_TO_G2_in),
     .A_TO_G3_in      (  A_TO_G3_in),
     .DOTS_in         (  DOTS_in   ),
     
     .A_TO_G_out      ( A_TO_G_out),
     .DOTS_out        ( DOTS_out   ),
     .AN_out          ( AN_out     )
);


// ps/2 port
ps2_controller ps2_cont(
   .app_clk           (app_clk25   ),
   .app_arst_n        (app_arst25_n),
   .ps2_clk           (PS2_CLK     ),
   .ps2_data          (PS2_DATA    ),
   .data_ena          (ps2_data_ena),
   .data_out          (ps2_data_out)
);

// output assignments
assign RED    = red_out;
assign GRN    = green_out;
assign BLU    = blue_out;
assign HSYNC  = hsync_out;
assign VSYNC  = vsync_out;
assign AN     = AN_out;
assign A_TO_G = A_TO_G_out;
assign DOT    = DOTS_out;

endmodule
