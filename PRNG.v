module PRNG (output [7:0] random, input step, rerun, randomize, clk, reset);

  LFSR u1 (.random(random[3:0]), .step(step), .rerun(rerun), .randomize(randomize), .clk(clk), .reset(reset));
  LFSR #(.FILL(16'h0001)) u2 (.random(random[7:4]), .step(step), .rerun(rerun), .randomize(randomize), .clk(clk), .reset(reset));

endmodule
