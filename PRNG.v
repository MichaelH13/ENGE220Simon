module PRNG (output [1:0] random, input step, rerun, randomize, clk, reset);

  LFSR u1 (.random(random[0]), .step(step), .rerun(rerun), .randomize(randomize), .clk(clk), .reset(reset));

  LFSR #(.FILL(16'h0001)) u2 (.random(random[1]), .step(step), .rerun(rerun), .randomize(randomize), .clk(clk), .reset(reset));

endmodule
