module RGB_colours(output reg [2:0] RGB, input [1:0] randy, input enable, clk);
	always@* begin
		if (enable) begin
			case(randy)
				0: RGB = 3'b010; //green
				1: RGB = 3'b100; //red
				2: RGB = 3'b001; //blue
				3: RGB = 3'b011; //yellow
				default: RGB = 7;
			endcase
		end
		else begin
			RGB = 0;
		end
	end
endmodule
