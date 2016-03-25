//`default_netlist none
module mercury_top
(
 input  wire         EXT_CLK,
 input  wire         CLK, 

 // buttons
 input  wire         USR_BTN,
 input  wire [03:00] BTN,

 // VGA stuff
 output wire [02:00] RED,
 output wire [02:00] GRN,
 output wire [01:00] BLU,
 output wire         HSYNC,
 output wire         VSYNC,

 // switches
 input  wire [07:00] SW,

 // 7 segment display
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

// Xilinx DCM
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
assign app_arst100_n = ~pll_locked;
assign app_arst50_n = ~pll_locked;
assign app_arst25_n = ~pll_locked;

// lets throw a VGA thing into this
vga_sync vga_module
(
   .app_clk     (app_clk25),
   .app_arst_n  (app_arst25_n),
   .vsync       (vsync_out),
   .hsync       (hsync_out),
   .red         (red_out  ),
   .green       (green_out),
   .blue        (blue_out )
);


// output assignments
assign RED   = red_out;
assign GREEN = green_out;
assign BLUE  = blue_out;
assign HSYNC = hsync_out;
assign VSYNC = vsync_out;

endmodule
