//module top_lab11(output [7:0] segments, lcd_data, output [3:0] anodes, 
//					  output [2:0] TL_LED, TR_LED, BL_LED, BR_LED,
//					  output lcd_regsel, lcd_read, lcd_enable, speaker,
//					  input SimonBtnTL, SimonBtnTR, SimonBtnBL, SimonBtnBR,
//					  input NexysBtnH13, NexysBtnE18, NexysBtnD18, NexysBtnB18, reset, clk);
//					  
//	//module bcd(output reg [3:0] hundreds, tens, ones, input [7:0] number);
//	wire [3:0] NexysOnes, NexysTens, NexysHundreds, SimonOnes, SimonTens, SimonHundreds;
//	wire [3:0] Nexys_btn_pressed, Nexys_btn_held, Simon_btn_pressed, Simon_btn_held;
//	
//	reg [7:0] NexysCounter, SimonCounter;
//	
//	reg [8*16-1:0] topline, bottomline;
//	reg [27:0] timer;
//	reg lcd_string_print;
//	wire lcd_string_available;
//
//	always @(posedge clk or posedge reset) begin
//	  if (reset) begin
//		 timer <= 0;
//		 lcd_string_print <= 0;
//	  end
//	  else begin
//		 if (lcd_string_available) begin
//			timer <= timer + 1;
//		 end
//		 lcd_string_print <= 0;
//		 if (timer == 1) begin
//			topline    <= {"Nexys Buttons:", {4'h3,NexysTens},{4'h3,NexysOnes}};
//			bottomline <= {"Simon Buttons:", {4'h3,SimonTens},{4'h3,SimonOnes}};
//			lcd_string_print <= 1;
//		 end
//		 if (timer == 100000000) begin
//			topline    <= {"Nexys Buttons:", {4'h3,NexysTens},{4'h3,NexysOnes}};
//			bottomline <= {"Simon Buttons:", {4'h3,SimonTens},{4'h3,SimonOnes}};
//			lcd_string_print <= 1;
//		 end
//		 if (timer >= 200000000) begin
//			timer <= 0;
//		 end
//	  end
//	end
//	
//
//	reg [3:0] oldCount;
//	reg start;
//	
//	reg [24:0] stateCounter;
//	
//	localparam IDLE = 0, 
//				  BUTTON1 = 1, 
//				  BUTTON2 = 2, 
//				  BUTTON3 = 3, 
//				  BUTTON4 = 4, 
//				  BUTTON5 = 5, 
//				  BUTTON6 = 6, 
//				  BUTTON7 = 7, 
//				  BUTTON8 = 8;
//	reg [3:0] state, next_state;
//	
//	always@(posedge clk) begin
//		if (!reset) begin
//			if (|Nexys_btn_pressed) NexysCounter <= NexysCounter + 1;
//			if (|Simon_btn_pressed) SimonCounter <= SimonCounter + 1;
//		end
//		else begin
//			NexysCounter <= 0;
//			SimonCounter <= 0;
//		end
//		
//		if (stateCounter >= 25000000) stateCounter <= 0;
//		else if (IDLE != state || start) stateCounter <= stateCounter + 1;
//		
//		oldCount <= SimonOnes;
//		if (oldCount == 9 && SimonOnes == 0) start = 1;
//		else start = 0;
//	end
//	
////	module select_simon_button(output reg [2:0] TL_LED, TR_LED, BL_LED, BR_LED, 
////									input [1:0] button);
//	select_simon_button butt(.TL_LED(TL_LED), .TR_LED(TR_LED), .BL_LED(BL_LED), .BR_LED(BR_LED), .button(state), .button_en(state != IDLE));
//	speaker speak(.speaker(speaker), .tone(state - 1), .speaker_en(IDLE != state), .clk(clk));
//	
//	always @* begin
//	  next_state = state;
//	  
//	  case (state) 
//		 IDLE: begin
//			if (start) begin
//				next_state = BUTTON1;
//			end
//			else begin
//				next_state = IDLE;
//			end
//		 end
//		 BUTTON1: begin
//			if (stateCounter >= 25000000) begin
//				next_state = BUTTON2;
//			end
//			else begin
//				next_state = BUTTON1;
//			end
//		 end
//		 BUTTON2: begin
//			if (stateCounter >= 25000000) begin
//				next_state = BUTTON3;
//			end
//			else begin
//				next_state = BUTTON2;
//			end
//		 end
//		 BUTTON3: begin
//			if (stateCounter >= 25000000) begin
//				next_state = BUTTON4;
//			end
//			else begin
//				next_state = BUTTON3;
//			end
//		 end
//		 BUTTON4: begin
//			if (stateCounter >= 25000000) begin
//				next_state = BUTTON5;
//			end
//			else begin
//				next_state = BUTTON4;
//			end
//		 end	
//		 BUTTON5: begin
//			if (stateCounter >= 25000000) begin
//				next_state = BUTTON6;
//			end
//			else begin
//				next_state = BUTTON5;
//			end
//		 end	
//		 BUTTON6: begin
//			if (stateCounter >= 25000000) begin
//				next_state = BUTTON7;
//			end
//			else begin
//				next_state = BUTTON6;
//			end
//		 end
//		 BUTTON7: begin
//			if (stateCounter >= 25000000) begin
//				next_state = BUTTON8;
//			end
//			else begin
//				next_state = BUTTON7;
//			end
//		 end
//		 BUTTON8: begin
//			if (stateCounter >= 25000000) begin
//				next_state = IDLE;
//			end
//			else begin
//				next_state = BUTTON8;
//			end
//		 end	
//	  endcase
//	end
//
//	always @ (posedge clk or posedge reset) begin
//	  if (reset) begin
//		 state <= IDLE;
//	  end
//	  else begin
//		 state <= next_state;
//	  end
//	end
//	
//	// convert binary to decimal
//	bcd converterNexys(.hundreds(NexysHundreds), .tens(NexysTens), .ones(NexysOnes), .number(NexysCounter), .clk(clk));
//	bcd converterSimon(.hundreds(SimonHundreds), .tens(SimonTens), .ones(SimonOnes), .number(SimonCounter), .clk(clk));
//	
//	// debounce Nexys buttons
//	//module debouncer(output pressed, held, input button, clk, reset);
//	debouncer Nexys_btn1(.pressed(Nexys_btn_pressed[0]), .held(Nexys_btn_held[0]), .clk(clk), .button(NexysBtnH13), .reset(reset));
//	debouncer Nexys_btn2(.pressed(Nexys_btn_pressed[1]), .held(Nexys_btn_held[1]), .clk(clk), .button(NexysBtnE18), .reset(reset));
//	debouncer Nexys_btn3(.pressed(Nexys_btn_pressed[2]), .held(Nexys_btn_held[2]), .clk(clk), .button(NexysBtnD18), .reset(reset));
//	debouncer Nexys_btn4(.pressed(Nexys_btn_pressed[3]), .held(Nexys_btn_held[3]), .clk(clk), .button(NexysBtnB18), .reset(reset));
////	debouncer Nexys_btn4(.pressed(Nexys_btn_pressed), .held(Nexys_btn_held), .clk(clk), .button(NexysBtnB18), .reset());
//	
//	// debounce Simon buttons
//	//module debouncer(output pressed, held, input button, clk, reset);
//	debouncer Simon_btn1(.pressed(Simon_btn_pressed[0]), .held(Simon_btn_held[0]), .clk(clk), .button(SimonBtnTL), .reset(reset));
//	debouncer Simon_btn2(.pressed(Simon_btn_pressed[1]), .held(Simon_btn_held[1]), .clk(clk), .button(SimonBtnTR), .reset(reset));
//	debouncer Simon_btn3(.pressed(Simon_btn_pressed[2]), .held(Simon_btn_held[2]), .clk(clk), .button(SimonBtnBL), .reset(reset));
//	debouncer Simon_btn4(.pressed(Simon_btn_pressed[3]), .held(Simon_btn_held[3]), .clk(clk), .button(SimonBtnBR), .reset(reset));
//
//	//seg_ctrl(output [7:0] segments_n, output reg [3:0] anodes_n, input[3:0] D,C,B,A, input clk);
//	seg_ctrl segh(.segments_n(segments), .anodes_n(anodes), .D(SimonTens), .C(SimonOnes), .B(NexysTens), .A(NexysOnes), .clk(clk));
//
////	module lcd_string(output lcd_regsel, lcd_read, lcd_enable, inout [7:0] lcd_data, 
////                  output reg available,
////                  input print, input [8*16-1:0] topline, bottomline, input reset, clk );
//	lcd_string lcd(.lcd_regsel(lcd_regsel), .lcd_read(lcd_read), .lcd_enable(lcd_enable), .lcd_data(lcd_data), 
//                  .available(lcd_string_available),
//                  .print(lcd_string_print), .topline(topline), .bottomline(bottomline), .reset(reset), .clk(clk));
//endmodule
