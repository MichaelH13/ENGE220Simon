//module simon(output [2:0] led0, led1, led2, led3, input clk, reset);
module simon(output [7:0] lcd_data, 
				 output [2:0] led0, led1, led2, led3,
				 output lcd_regsel, lcd_read, lcd_enable,
				 input SimonBtnTL, SimonBtnTR, SimonBtnBL, SimonBtnBR,
				 input clk, reset);
	
	reg [8*16-1:0] topline, bottomline;
	reg [27:0] timer;
	reg lcd_string_print;
	wire lcd_string_available;
	assign enable = ~SimonBtnTL | ~SimonBtnTR | ~SimonBtnBL | ~SimonBtnBR;
	wire [1:0] btnColor = ~SimonBtnTL ? 0 : ~SimonBtnBL ? 2 : ~SimonBtnTR ? 1 : ~SimonBtnBR ? 3 : -1;
	
	always @(posedge clk or posedge reset) begin
	  if (reset) begin
		 timer <= 0;
		 lcd_string_print <= 0;
	  end
	  else begin
		 if (lcd_string_available) begin
			timer <= timer + 1;
		 end
		 lcd_string_print <= 0;
		 if (timer == 1) begin
			topline    <= "Welcome to Simon";
			bottomline <= "Press RED button";
			lcd_string_print <= 1;
		 end
		 if (timer >= 200000000) begin
			timer <= 0;
		 end
	  end
	end
	
	lcd_string lcd(.lcd_regsel(lcd_regsel), .lcd_read(lcd_read), .lcd_enable(lcd_enable), .lcd_data(lcd_data), 
					.available(lcd_string_available),
					.print(lcd_string_print), .topline(topline), .bottomline(bottomline), .reset(reset), .clk(clk));
	
	//	module simon_led_ctrl(output reg [2:0] led0, led1, led2, led3, input[1:0] color, input enable, clk);
	simon_led_ctrl leds(.led0(led0), .led1(led1), .led2(led2), .led3(led3), .color(btnColor), .enable(enable), .clk(clk));

endmodule
