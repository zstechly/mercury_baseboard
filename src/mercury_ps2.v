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
module ps2_controller(
   input   wire         app_clk,
   input   wire         app_arst_n,
   input   wire         ps2_clk,
   input   wire         ps2_data,
   output  wire         data_ena,
   output  wire [07:00] data_out
);


reg          ps2_clk_dly_r, ps2_clk_dly2_r, ps2_clk_falling_edge_r;
reg [10:00]  data_in_r;
reg [03:00]  data_cnt_r;
reg [07:00]  data_out_r;
reg          data_ena_r;
// edge detect PS2 clock, looking for falling edge to start process
always @(posedge app_clk or negedge app_arst_n) begin
   if (~app_arst_n) begin
      ps2_clk_dly_r           <= 1'b1;
      ps2_clk_dly2_r          <= 1'b1;
      ps2_clk_falling_edge_r  <= 1'b0;
   end else begin
      ps2_clk_dly_r           <= ps2_clk;
      ps2_clk_dly2_r          <= ps2_clk_dly_r;
      ps2_clk_falling_edge_r   <= ~ps2_clk_dly_r & ps2_clk_dly2_r;
   end 
end


// Process data bits, no parity checking or good engineering 
// occuring here
always @(posedge app_clk or negedge app_arst_n) begin
  if (~app_arst_n) begin
      data_in_r    <= 'b0;
      data_cnt_r   <= 'b0;
      data_out_r   <= 'b0;
      data_ena_r   <= 'b0;
   end else begin
      if (ps2_clk_falling_edge_r) begin
          data_in_r[10:00] <= {ps2_data,data_in_r[10:1]};
          data_cnt_r       <= data_cnt_r + 1;
      end else begin
          if (data_cnt_r   == 4'd11) begin
             data_cnt_r    <= 'b0;
             data_out_r    <= data_in_r[8:1];
             data_ena_r    <= 1'b0;
          end else begin
             data_cnt_r    <= data_cnt_r;
             data_out_r    <= data_out_r;
             data_ena_r    <= 1'b0;
          end
      end          
  end
end

assign data_ena = data_ena_r; 
assign data_out = data_out_r;

endmodule
