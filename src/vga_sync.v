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
reg  [09:00]  row_cnt_r;
reg  [09:00]  col_cnt_r;

// make random colors
always @(posedge app_clk or negedge app_arst_n) begin
  if (~app_arst_n) begin
     red_r     <= 'b0; 
     green_r   <= 'b0;
     blue_r    <= 'b0;
     row_cnt_r <= 'b0;
     col_cnt_r <= 'b0;
  end else begin

     if (col_cnt_r == 10'd799) begin
         col_cnt_r   <= 'b0;
         if (row_cnt_r == 10'd520) begin
            row_cnt_r    <= 'b0;
         end else begin
            row_cnt_r    <= row_cnt_r + 1;
         end
     end else begin
         col_cnt_r   <= col_cnt_r + 1;
     end

     red_r     <= {1'b1,1'b0,1'b0};
     green_r   <= {row_cnt_r[0],row_cnt_r[0],row_cnt_r[0]};
     blue_r    <= {col_cnt_r[0],col_cnt_r[0]};
  end
end

// output assignments
assign vsync   = ~(row_cnt_r < 10'd2);;
assign hsync   = ~(col_cnt_r < 10'd96);
assign red     = red_r;
assign green   = green_r;
assign blue    = blue_r;
endmodule
