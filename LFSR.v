module LFSR #(parameter FILL=16'hACE1) (output random, input step, rerun, randomize, clk, reset);

reg [15:0] lfsr, rerun_reg;
reg randomize_d;
wire fb = lfsr[0] ^ lfsr[2] ^ lfsr[3] ^ lfsr[5];
wire falling_edge_randomize  = ~randomize & randomize_d;
assign random = lfsr[0];

always @(posedge clk) begin
  if (reset) begin
    lfsr <= FILL; 
    rerun_reg <= FILL;
  end
  else begin
    randomize_d <= randomize;

    if (step | randomize) begin
      lfsr <={fb, lfsr[15:1]};
    end

    if (rerun) begin
      lfsr <= rerun_reg;
    end

    if (falling_edge_randomize) begin
      rerun_reg <= lfsr;
    end
  end
end
endmodule
