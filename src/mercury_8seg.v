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
module mercury_8seg 
(
     input   wire          app_clk,
     input   wire          app_arst_n,
     
     input   wire          enable, 
     input   wire [06:00]  A_TO_G0_in,
     input   wire [06:00]  A_TO_G1_in,
     input   wire [06:00]  A_TO_G2_in,
     input   wire [06:00]  A_TO_G3_in,
     input   wire [03:00]  DOTS_in,
     
     output  wire [06:00]  A_TO_G_out,
     output  wire          DOTS_out,
     output  wire [03:00]  AN_out     
);


// assume running off 50MHz
// want each of the four to update 60 times per second
// so 50e6/240= ~18-bit counter. 
reg [17:00] cnt_r;
reg [01:00] sel_r;
always @(posedge app_clk or negedge app_arst_n) begin
   if (~app_arst_n) begin
      cnt_r   <= 'b0;
      sel_r   <= 'b0;
   end else begin
      cnt_r   <= cnt_r + 1;
      sel_r   <= sel_r + &cnt_r;
   end
end

// register the enable signal
reg   enable_r;
always @(posedge app_clk or negedge app_arst_n) begin
  if (~app_arst_n) begin
      enable_r      <= 1'b0;
  end else begin
      enable_r      <= enable;
  end
end


// mux the 4 characters
reg  [06:00] A_TO_G_r;
reg          dots_out_r;
reg  [03:00] an_r;
always @(posedge app_clk or negedge app_arst_n) begin
   if (~app_arst_n) begin
      A_TO_G_r    <= 'b0;
      dots_out_r  <= 1'b0;
      an_r        <= 4'b1111;
   end else begin
    if (enable_r) begin
      case(sel_r)
         2'b00: begin
                 A_TO_G_r   <= A_TO_G0_in;
                 an_r       <= 4'b0111;
                 dots_out_r <= DOTS_in[0];
                end
         2'b01: begin
                 A_TO_G_r   <= A_TO_G1_in;
                 an_r       <= 4'b1011;
                 dots_out_r <= DOTS_in[1];
                end
         2'b10: begin
                 A_TO_G_r   <= A_TO_G2_in;
                 an_r       <= 4'b1101;
                 dots_out_r <= DOTS_in[2];
                end
       default: begin
                 A_TO_G_r   <= A_TO_G3_in;
                 an_r       <= 4'b1110;
                 dots_out_r <= DOTS_in[3];
                end
      endcase   
    end else begin
        A_TO_G_r   <= 'b0;
        an_r       <= 4'b1111; // set all off
        dots_out_r <= 1'b1;
    end  
   end
end

//assign outputs
assign A_TO_G_out  = A_TO_G_r;
assign DOTS_out    = dots_out_r;
assign AN_out      = an_r;

endmodule
