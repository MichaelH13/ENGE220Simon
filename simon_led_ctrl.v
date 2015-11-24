//Simon led Control

module simon_led_ctrl(output reg [2:0] led0,led1,led2,led3, input[1:0] color, input enable, clk);

localparam Red=3'b100, Green=3'b010, Blue 3'b001, Yellow= 3'b110, Black=3'b000, ms=50000;
reg [17:0] timer;

always @ * begin

	if (timer< 1*ms-1) begin
		led0 = Red
		led1 = Green
		led2 = Blue
		led3 = Yellow
	end
	else begin
		led0 = Black
		led1 = Black
		led2 = Black
		led3 = Black
	end
	
	if (enable) begin
		case(color)
			led0 = Red
			led1 = Green
			led2 = Blue
			led3 = Yellow
		endcase
	end
end

always @ (posedge clk) begin

	timer <= timer+1
	
	if(timer>= 5*ms-1)begin
		timer<= 0
	end
end
endmodule
