module simon(output [7:0] lcd_data, 
				 output [2:0] led0, led1, led2, led3,
				 output lcd_regsel, lcd_read, lcd_enable, speaker, LED0, LED1, LED6, LED7,
				 input SimonBtnTL, SimonBtnTR, SimonBtnBL, SimonBtnBR,
				 input clk, reset);
	
	// State-machine variables.
	localparam IDLE = 0,
				  RANDOMIZE = 1,
				  SIMON_PLAY = 2,
				  SIMON_REST = 3,
				  SIMON_CHECK = 4,
				  SIMON_NEXT = 5,
				  PLAYER_INIT = 6,
				  PLAYER_ENTRY = 7,
				  PLAYER_RELEASE = 8,
				  PLAYER_CHECK = 9,
				  PLAYER_LOSE = 10;
				  
	reg [7:0] state, next_state;
	
	// LCD Variables.
	reg [8*16-1:0] topline, bottomline;
	reg [27:0] timer, secondTimer;
	reg lcd_string_print;
	wire lcd_string_available;
	
	// Random sequence memory for both simon and human.
	wire [1:0] random;
	reg [7:0] playedSimonBtnCounter, playedPlayerBtnCounter;
	reg stepPlay, stepGuessed, rerun, randomize;
	wire step = stepPlay | stepGuessed;

	// Buttons, color.
	reg [1:0] lastBtn;
	wire tlPressed, trPressed, blPressed, brPressed;
	wire tlHeld, trHeld, blHeld, brHeld;
	assign enable = tlHeld | blHeld | trHeld | brHeld | (state == SIMON_PLAY);
	
	// if we are playing a sequence, continue to do so, otherwise light up a button if the user is holding it.
	wire [2:0] btnColor = (state == SIMON_PLAY) ? {1'b0, random} : tlHeld ? 0 : blHeld ? 2 : trHeld ? 1 : brHeld ? 3 : 4;
	
	assign LED0 = random[0];
	assign LED1 = random[1];
	assign LED6 = btnColor[0];
	assign LED7 = btnColor[1];
	
	// Keep track of score.
	reg [7:0] scoreBinary;
	wire [3:0] ones, tens;
	wire [7:0] upperScore, lowerScore;
	assign upperScore = {4'b0011, tens};
	assign lowerScore = {4'b0011, ones};
	wire [15:0] displayScore = {upperScore, lowerScore};
	
	// Speaker.
	reg speaker_en;
	
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			timer <= 0;
			secondTimer <= 0;
			lcd_string_print <= 0;
			
		end
		else begin
			if (lcd_string_available) begin
				timer <= timer + 1;
			end
		
			lcd_string_print <= 0;
			if (timer == 1) begin
				if (state == IDLE) begin
					topline    <= "Welcome to Simon";
					bottomline <= "Press GRN button";
					lcd_string_print <= 1;
				end else if (state == RANDOMIZE) begin
					topline    <= "RANDOMIZE:      ";
					bottomline <= {"Your Score:   ", displayScore};
					lcd_string_print <= 1;
				end else if (state == SIMON_PLAY) begin
					topline    <= "SIMON_PLAY......";
					bottomline <= {"Your Score:   ", displayScore};
					lcd_string_print <= 1;
				end else if (state == SIMON_REST) begin
					topline    <= "SIMON_REST......";
					bottomline <= {"Your Score:   ", displayScore};
					lcd_string_print <= 1;
				end else if (state == PLAYER_INIT) begin
					topline    <= "PLAYER_INIT.....";
					bottomline <= {"Your Score:   ", displayScore};
					lcd_string_print <= 1;
				end else if (state == PLAYER_ENTRY) begin
					topline    <= "PLAYER_ENTRY....";
					bottomline <= {"Your Score:   ", displayScore};
					lcd_string_print <= 1;
				end else if (state == PLAYER_RELEASE) begin
					topline    <= "PLAYER_RELEASE..";
					bottomline <= {"Your Score:   ", displayScore};
					lcd_string_print <= 1;
				end else if (state == PLAYER_CHECK) begin
					topline    <= "PLAYER_CHECK....";
					bottomline <= {"Your Score:   ", displayScore};
					lcd_string_print <= 1;
				end else if (state == PLAYER_LOSE) begin
					topline    <= "PLAYER_LOSE.....";
					bottomline <= {"Your Score:   ", displayScore};
					lcd_string_print <= 1;
				end
			end
			if (timer >= 20000000) begin
				timer <= 0;
			end
			
			secondTimer <= secondTimer < 50000000 && (state != RANDOMIZE) ? secondTimer + 1 : 0;
			
			//Step if we have just finished playing a tone.
			stepPlay <= (state == SIMON_PLAY) && secondTimer >= 50000000;
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
	
	// Random sequence generator.
	//module PRNG (output [1:0] random, input step, rerun, randomize, clk, reset);
	PRNG randomGenerator(.random(random), .step(step), .rerun(rerun), .randomize(randomize), .clk(clk), .reset(reset));
	
	//module speaker(output reg speaker, input [2:0] tone, input speaker_en, clk);
	speaker speaker1(.speaker(speaker), .tone({1'b1, random}), .speaker_en(speaker_en), .clk(clk));
	
	//module bcd(output reg [3:0] hundreds, tens, ones, input [7:0] number, input clk);
	bcd bcd1(.hundreds(), .tens(tens), .ones(ones), .number(scoreBinary), .clk(clk));
					 
	always @* begin
		// Defaults.
		next_state = state;
		stepGuessed = 0;
		rerun = 0;
		speaker_en = 0;
		randomize = tlHeld && state == RANDOMIZE;
		
		if (reset) begin
			playedSimonBtnCounter = 0;
			playedPlayerBtnCounter = 0;
			scoreBinary = 0;
		end

		case (state) 
			IDLE: begin // Wait for button press
				if (tlHeld) next_state = RANDOMIZE;
			end
			
			RANDOMIZE: begin
				if (~tlHeld) begin
					next_state = SIMON_PLAY;
				end
			end
			
			SIMON_PLAY: begin
				if (playedSimonBtnCounter <= scoreBinary) begin
					// play tone
					// shift for next tone 
					playedSimonBtnCounter = playedSimonBtnCounter + step; //Add one to our count of how many buttons we have played so far.
					speaker_en = secondTimer < (50000000 / 4) * 3; //only turn on speaker for 3/4 second.
				end
				else begin
					next_state = SIMON_REST;
				end
			end
			
			SIMON_REST: begin
				playedSimonBtnCounter = 0; //reset counter
				next_state = PLAYER_INIT;
			end
			
			SIMON_CHECK: begin
			end
			
			SIMON_NEXT: begin
			end
			
			PLAYER_INIT: begin
				// initally the player hasn't made any guesses.
				// we want to rerun our random generator, so set rerun to 1.
				playedPlayerBtnCounter = 0;
				rerun = 1;
				next_state = PLAYER_ENTRY;
			end
			
			PLAYER_ENTRY: begin
				if (btnColor != 3'b100) begin
					// save last button
					lastBtn = btnColor[1:0];
					next_state = PLAYER_RELEASE;
					speaker_en = 1;
				end
			end
			
			PLAYER_RELEASE: begin
				// if we have had the button they pressed released, 
				// then progress to check if it was correct.
				speaker_en = 1;
				if (btnColor != {1'b0, lastBtn}) begin
					next_state = PLAYER_CHECK;
				end
			end
			
			PLAYER_CHECK: begin
				// correct guess.
				if (lastBtn == random) begin
					playedPlayerBtnCounter = playedPlayerBtnCounter + 1;
					stepGuessed = 1;
					// if we still have more buttons to guess, then loop back to accept more guesses.
					if (playedPlayerBtnCounter <= scoreBinary) begin
						next_state = PLAYER_ENTRY;
					end
					else begin
						// end of correct sequence, so add to our score and reset for the larger sequence.
						scoreBinary = scoreBinary + 1; // incrementing our score.
						next_state = SIMON_PLAY; // start playing the sequence again.
						rerun = 1; // reset the sequence generator.
					end
				end
				else begin
					next_state = PLAYER_LOSE;
				end	
			end
			
			PLAYER_LOSE: begin
				// play losing tone, reset game.
			end
			
	  endcase
	end

	always @ (posedge clk or posedge reset) begin
	  if (reset) begin
		 state <= IDLE;
	  end
	  else begin
		 state <= next_state;
	  end
	end

endmodule
