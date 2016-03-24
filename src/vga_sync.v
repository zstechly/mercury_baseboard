//`default_netlist none
// goal is for screen to be updated at 60Hz
// 640x480=307200 pixels.  
// app clock should be 25MHz
// actually it seems like 794*528
module vga_sync
(
   input   wire          app_clk,
   input   wire          app_arst_n,
   output  wire          vsync,
   output  wire          hsync,
   output  wire [02:00]  red,
   output  wire [02:00]  green,
   output  wire [01:00]  blue
);

// internal signals
reg  [02:00]  red_r, green_r;
reg  [01:00]  blue_r;
reg           vsync_r, hsync_r;
reg  [08:00]  row_cnt_r;
reg  [09:00]  col_cnt_r;

// make random colors
always @(posedge app_clk or negedge app_arst_n) begin
  if (~app_arst_n) begin
     red_r     <= 'b0; 
     green_r   <= 'b0;
     blue_r    <= 'b0;
     vsync_r   <= 1'b0;
     hsync_r   <= 1'b0;
     row_cnt_r <= 'b0;
     col_cnt_r <= 'b0;
  end else begin
     col_cnt_r <= (col_cnt_r == 10'd793) ? 0 : col_cnt_r + 1;
     row_cnt_r <= (row_cnt_r == 9'd652)  ? 0 : row_cnt_r + {8'd0,~|col_cnt_r};
     hsync_r   <= (col_cnt_r < 10'd639);
     vsync_r   <= (row_cnt_r < 9'd479);
     red_r     <= {1'b1,1'b0,1'b0};
     green_r   <= {row_cnt_r[0],row_cnt_r[0],row_cnt_r[0]};
     blue_r    <= {col_cnt_r[0],col_cnt_r[0]};
  end
end
assign vsync   = vsync_r;
assign hsync   = hsync_r;
assign red     = red_r;
assign green   = green_r;
assign blue    = blue_r;
endmodule
