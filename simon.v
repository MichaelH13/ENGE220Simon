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
	wire random;
	wire tlPressed, trPressed, blPressed, brPressed;
	wire tlHeld, trHeld, blHeld, brHeld;
	assign enable = tlHeld | blHeld | trHeld | brHeld;
	wire [2:0] btnColor = tlHeld ? 0 : blHeld ? 2 : trHeld ? 1 : brHeld ? 3 : 4;
	
	// NOT IMPLEMENTED YET:
	wire step, rerun;
	assign step = 0;
	assign rerun = 0;
	
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
			bottomline <= "Press GRN button";
			lcd_string_print <= 1;
		 end
		 if (timer == 100000000) begin
			topline    <= "Welcome to Simon";
			bottomline <= {"Random:        ", {7'b0011000, random}};
			lcd_string_print <= 1;
		 end
		 if (timer >= 200000000) begin
			timer <= 0;
		 end
	  end
	end

	// DEBOUNCE SIMON BUTTONS
	// module debouncer(output pressed, held, input button, clk, reset);
	debouncer tl(.pressed(tlPressed), .held(tlHeld), .button(~SimonBtnTL), .clk(clk), .reset(reset));
	debouncer tr(.pressed(trPressed), .held(trHeld), .button(~SimonBtnTR), .clk(clk), .reset(reset));
	debouncer bl(.pressed(blPressed), .held(blHeld), .button(~SimonBtnBL), .clk(clk), .reset(reset));
	debouncer br(.pressed(brPressed), .held(brHeld), .button(~SimonBtnBR), .clk(clk), .reset(reset));

	// LCD DISPLAY
	lcd_string lcd(.lcd_regsel(lcd_regsel), .lcd_read(lcd_read), .lcd_enable(lcd_enable), .lcd_data(lcd_data), 
					.available(lcd_string_available),
					.print(lcd_string_print), .topline(topline), .bottomline(bottomline), .reset(reset), .clk(clk));

	
	//	module simon_led_ctrl(output reg [2:0] led0, led1, led2, led3, input[1:0] color, input enable, clk);
	simon_led_ctrl leds(.led0(led0), .led1(led1), .led2(led2), .led3(led3), .color(btnColor[1:0]), .enable(enable), .clk(clk));
	
	//module LFSR #(parameter FILL=16'hACE1) (output random, input step, rerun, randomize, clk, reset);
	LFSR shifter(.random(random), .step(step), .rerun(rerun), .randomize(tlHeld), .clk(clk), .reset(reset));

	localparam INIT = 0,
				  IDLE = 1,
				  RANDOMIZE = 2,
				  SIMON_PLAY = 3,
				  SIMON_REST = 3,
				  SIMON_CHECK = 4,
				  SIMON_SIMON_NEXT = 5,
				  PLAYER_INIT = 6,
				  PLAYER_ENTRY = 7,
				  PLAYER_RELEASE = 8,
				  PLAYER_CHECK = 9,
				  PLAYER_LOSE = 10;
				  
	reg [3:0] state, next_state;
					 
	always @* begin
		next_state = state;
	  
		case (state) 
			INIT: begin
			end
			
			IDLE: begin
			end
			
			RANDOMIZE: begin
			end
			
			SIMON_PLAY: begin
			end
			
			SIMON_REST: begin
			end
			
			SIMON_CHECK: begin
			end
			
			SIMON_SIMON_NEXT: begin
			end
			
			PLAYER_INIT: begin
			end
			
			PLAYER_ENTRY: begin
			end
			
			PLAYER_RELEASE: begin
			end
			
			PLAYER_CHECK: begin
			end
			
			PLAYER_LOSE: begin
			end
			
	  endcase
	end

	always @ (posedge clk or posedge reset) begin
	  if (reset) begin
		 state <= INIT;
	  end
	  else begin
		 state <= next_state;
	  end
	end

endmodule
