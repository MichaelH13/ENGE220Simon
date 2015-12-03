module simon(output [7:0] lcd_data, segments_n,
				 output [3:0] anodes,
				 output [2:0] led0, led1, led2, led3,
				 output lcd_regsel, lcd_read, lcd_enable, speaker, nLED0, nLED1, nLED4, nLED6, nLED7, 
				 input SimonBtnTL, SimonBtnTR, SimonBtnBL, SimonBtnBR, nBTN0_step_state,
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
	reg stepPlay, stepGuessed, rerun, randomize, stepGuessed_en;
	wire step = stepPlay | stepGuessed;

	// Buttons, color.
	reg [1:0] lastBtn;
	wire tlPressed;//, trPressed, blPressed, brPressed;
	wire tlHeld, trHeld, blHeld, brHeld;
	assign enable = tlHeld | blHeld | trHeld | brHeld | (state == SIMON_PLAY);
	
	// if we are playing a sequence, continue to do so, otherwise light up a button if the user is holding it.
	wire [2:0] btnColor = (state == SIMON_PLAY) ? {1'b0, random} : tlHeld ? 0 : blHeld ? 2 : trHeld ? 1 : brHeld ? 3 : 4;
	
	assign nLED0 = random[0];
	assign nLED1 = random[1];
	assign nLED4 = stepPlay;
	assign nLED6 = lastBtn[0];
	assign nLED7 = lastBtn[1];
	
	// Keep track of score.
	reg [7:0] scoreCounter;
	reg scoreCounter_en, playedSimonBtnCounter_en, playedPlayerBtnCounter_en;
	wire [3:0] ones, tens;
	reg [3:0] testCounter;
	wire [7:0] bcdOnes, bcdTens;
	assign bcdTens = {4'b0011, tens};
	assign bcdOnes = {4'b0011, ones};
	wire [15:0] displayScore = {bcdTens, bcdOnes};
	
	// Speaker.
	reg speaker_en;
	
	// LCD BLOCK
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
				topline    <= "0000000000000000"; //hopefully remove warnings when compiling.
				bottomline <= "0000000000000000";
				timer <= 0;
			end
			
			// Only run timer for seconds if we are not in randomize and secondTimer < 50000000.
			secondTimer <= secondTimer < 50000000 && (state != RANDOMIZE) ? secondTimer + 1 : 0;
			
			// Step if we have just finished playing a tone.
			stepPlay <= !(secondTimer < 50000000) && (state == SIMON_PLAY) ? 1 : 0;
			stepGuessed <= stepGuessed_en;
			
			if (tlPressed) testCounter <= testCounter + 1;
//			if (scoreCounter_en) scoreCounter <= scoreCounter + 1;
//			if (playedSimonBtnCounter_en) playedSimonBtnCounter <= playedSimonBtnCounter + 1;
//			if (playedPlayerBtnCounter_en) playedPlayerBtnCounter <= playedPlayerBtnCounter + 1;
		end
		
	end

	// DEBOUNCE SIMON BUTTONS
	// module debouncer(output pressed, held, input button, clk, reset);
	debouncer tl(.pressed(tlPressed), .held(tlHeld), .button(~SimonBtnTL), .clk(clk), .reset(reset));
	debouncer tr(.pressed(), .held(trHeld), .button(~SimonBtnTR), .clk(clk), .reset(reset));
	debouncer bl(.pressed(), .held(blHeld), .button(~SimonBtnBL), .clk(clk), .reset(reset));
	debouncer br(.pressed(), .held(brHeld), .button(~SimonBtnBR), .clk(clk), .reset(reset));
	
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
	bcd bcd1(.hundreds(), .tens(tens), .ones(ones), .number(scoreCounter), .clk(clk));
	
	//module seg_ctrl(output [7:0] segments_n, output reg [3:0] anodes_n, input[3:0] D,C,B,A, input clk);
	seg_ctrl seg1(.segments_n(segments_n), .anodes_n(anodes), .D(playedSimonBtnCounter[7:4]),.C(playedSimonBtnCounter[3:0]),.B(playedPlayerBtnCounter[7:4]), .A(playedPlayerBtnCounter[3:0]), .clk(clk));
	
	// STATE MACHINE BLOCK.
	always @* begin
		// Defaults.
		next_state = state;
		stepGuessed_en = 0;
		rerun = 0;
		speaker_en = 0;
		randomize = tlHeld && state == RANDOMIZE;
		playedSimonBtnCounter = playedSimonBtnCounter > 0 ? playedSimonBtnCounter : 0;
		playedPlayerBtnCounter = playedPlayerBtnCounter > 0 ? playedPlayerBtnCounter : 0;
		scoreCounter = scoreCounter > 0 ? scoreCounter : 0;
		
		if (reset) begin
			playedSimonBtnCounter = 0;
			playedPlayerBtnCounter = 0;
			scoreCounter = 0;
			lastBtn = 0;
		end
		else begin
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
					if (playedSimonBtnCounter <= scoreCounter) begin
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
					// if a button is held, then save it.
					if (nBTN0_step_state) begin
						if (enable) begin
							// save last button
							lastBtn = btnColor[1:0];
							next_state = PLAYER_RELEASE;
							speaker_en = 1;
						end
					end
				end
				
				PLAYER_RELEASE: begin
					// if we have had the button they pressed released, 
					// then progress to check if it was correct.
					speaker_en = 1;
					if (nBTN0_step_state) begin
						if (~enable) begin
							next_state = PLAYER_CHECK;
						end
					end
				end
				
				PLAYER_CHECK: begin
					// correct guess.
					if (nBTN0_step_state) begin
						if (lastBtn == random) begin
							playedPlayerBtnCounter = playedPlayerBtnCounter + 1;
							stepGuessed_en = 1;
							// if we still have more buttons to guess, then loop back to accept more guesses.
							if (playedPlayerBtnCounter <= scoreCounter) begin
								next_state = PLAYER_ENTRY;
							end
							else begin
								// end of correct sequence, so add to our score and reset for the larger sequence.
								scoreCounter = scoreCounter + 1; // incrementing our score.
								next_state = SIMON_PLAY; // start playing the sequence again.
								rerun = 1; // reset the sequence generator.
							end
						end
						else begin
							next_state = PLAYER_LOSE;
						end
					end
				end
				
				PLAYER_LOSE: begin
					// play losing tone, reset game.
					
					next_state = IDLE;
					
				end
				
		  endcase
		end
	end

	// ITERATE STATES ON EACH CLK CYCLE.
	always @ (posedge clk or posedge reset) begin
		
		
//		if (secondTimer < 50000000 && (state != RANDOMIZE)) begin
//			secondTimer <= secondTimer + 1;
//			stepPlay <= 0;
//		end
//		else begin
//			secondTimer <= 0;
//			
//			// Step if we have just finished playing a tone.
//			if (state == SIMON_PLAY) begin
//				stepPlay <= 1;
//			end
//		end
		
		if (reset) begin
			state <= IDLE;
		end
		else begin
			state <= next_state;
		end
	end

endmodule
