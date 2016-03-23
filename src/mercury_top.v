`default_netlist none
module mercury_top
(
 input  wire         EXT_CLK,
 input  wire         CLK, 
 input  wire         PS2_DATA,
 input  wire         PS2_CLK,

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
 input  wire         PS2_CLK,
);

// DCM outputs
wire  app_clk100, app_arst100_n;
wire  app_clk25,  app_arst25_n;
wire  app_clk50,  app_arst50_n;

// VGA output
wire          vsync_out;
wire          hsync_out;
wire [02:00]  red_out;
wire [02:00]  green_out;
wire [01:00]  blue_out;


// Xilinx DCM


// lets throw a VGA thing into this
vga_sync vga
(
   .app_clk     (app_clk25),
   .app_arst_n  (app_arst25_n),
   .vsync       (vsync),
   .hsync       (hsync),
   .red         (red  ),
   .green       (green),
   .blue        (blue ),
);


// output assignments
assign RED   = red_out;
assign GREEN = green_out;
assign BLUE  = blue_out;
assign HSYNC = hsync_out;
assign VSYNC = vsync_out;

endmodule
