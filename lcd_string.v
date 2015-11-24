// This module takes in two strings that are set to ASCII characters.
// as in:
//
// reg [8*16-1:0] topline, bottomline;
// topline    = "0123456789ABCDEF";
// bottomline = "  HELLO WORLD!  ";
// 
// To print the strings, wait for the available output to be high, then assert the print input.
// The lcd_XXXX lines should be tied directly to the LCD pins on the SIMON board.
module lcd_string(output lcd_regsel, lcd_read, lcd_enable, inout [7:0] lcd_data, 
                  output reg available,
                  input print, input [8*16-1:0] topline, bottomline, input reset, clk );
localparam INIT = 0, FUNCTION_SET = 1, WAIT = 2, ENTRY_MODE_SET = 3, 
           DISPLAY_ON = 4, ENABLE = 5, CLEAR_DISPLAY = 6, RETURN_HOME = 7, 
			  PRINT_LINE_1 = 8, PRINT_LINE_1_ADDR = 9, PRINT_LINE_1_CHAR = 10,
			  PRINT_LINE_2 = 11, PRINT_LINE_2_ADDR = 12, PRINT_LINE_2_CHAR = 13;
reg [7:0] state, next_state;
reg [7:0] pending_state, next_pending_state;
reg [7:0] data;
reg activate, regsel;
reg [7:0] address, next_address;
reg [8*16-1:0] line1, line2, next_line1, next_line2;

// Instantiate the lcd controller. 
lcd_ctrl lcd1 (.lcd_regsel(lcd_regsel), .lcd_read(lcd_read), .lcd_enable(lcd_enable), .lcd_data(lcd_data), 
               .ready(ready), .din(data), .activate(activate), .regsel(regsel), 
					.reset(reset), .clk(clk) );
					 
always @* begin
  next_state = state;
  next_address = address;
  next_pending_state = pending_state;
  next_line1 = line1;
  next_line2 = line2;
  activate = 0;
  regsel = 0;
  data = 0;
  available = 0;
  case (state) 
    INIT: begin
	   next_state = FUNCTION_SET;
	 end
	 FUNCTION_SET: begin
	   regsel = 0;
	   data = 8'b00111000; // Setup for 8 bit interface, 2 lines, 5x7 dots.
		activate = 1;
		next_state = ENABLE;
		next_pending_state = ENTRY_MODE_SET;
	 end
	 ENTRY_MODE_SET: begin
	   regsel = 0;
	   data = 8'b00000110; // Set cursor to move right
		activate = 1;
		next_state = ENABLE;	  
		next_pending_state = DISPLAY_ON;	
	 end
	 DISPLAY_ON: begin
	   regsel = 0;
	   data = 8'b00001111; // Turn the display on,  turn cursor on, blink cursor
		activate = 1;
		next_state = ENABLE;
      next_pending_state = CLEAR_DISPLAY;
	 end	
	 CLEAR_DISPLAY: begin
	   regsel = 0;
	   data = 8'b00000001; // Clears the entire display and sets the RAM address to 0
		activate = 1;
		next_state = ENABLE;
      next_pending_state = RETURN_HOME;
	 end	
	 RETURN_HOME: begin
	   regsel = 0;
	   data = 8'b00000010; // sets the cursor to 0,0
		activate = 1;
		next_state = ENABLE;
      next_pending_state = WAIT;
	 end		 
	 
	 // ENABLE: Turn off the activate and wait for the LCD write to complete
	 //         When it has completed, go to the pending state and continue.
	 ENABLE: begin  
      activate = 0;
		if (ready)
		  next_state = pending_state;
	 end
	 
	 // WAIT: We will sit here until we get a print command 
	 WAIT: begin
	   available = 1;
	   if (print) begin
		  next_state = PRINT_LINE_1;
		  next_line1 = topline;
		  next_line2 = bottomline;		
		end
	 end
	 PRINT_LINE_1: begin
		next_address = 8'h80;
		next_state = PRINT_LINE_1_ADDR;
	 end
	 PRINT_LINE_1_ADDR: begin
	   activate = 1;
		data = address;
		next_state = ENABLE;
		next_pending_state = PRINT_LINE_1_CHAR;
	 end
	 PRINT_LINE_1_CHAR: begin
	   activate = 1;
		regsel = 1;
		data = line1[16*8-1:16*8-8]; // Set the data to the next character to print
		next_state = ENABLE;
		next_address = address+1;
		next_line1 = line1 << 8; // Go through each character, shifting upward each time.
		if (address[3:0] == 4'hf) // When we have gone through the 16 characters, 
		  next_pending_state = PRINT_LINE_2; // Go to the next line
		else 
		  next_pending_state = PRINT_LINE_1_CHAR; // Until then, go to the next character.
	 end
	 PRINT_LINE_2: begin
		next_address = 8'hC0;
		next_state = PRINT_LINE_2_ADDR;
	 end
	 PRINT_LINE_2_ADDR: begin
	   activate = 1;
		data = address;
		next_state = ENABLE;
		next_pending_state = PRINT_LINE_2_CHAR;
	 end
	 PRINT_LINE_2_CHAR: begin
	   activate = 1;
		regsel = 1;
		data = line2[16*8-1:16*8-8];
		next_state = ENABLE;
		next_address = address+1;
		next_line2 = line2 << 8;
		if (address[3:0] == 4'hf) 
		  next_pending_state = WAIT; // When we are finished, go back to wait.
		else 
		  next_pending_state = PRINT_LINE_2_CHAR;
	 end
  endcase
end

always @ (posedge clk or posedge reset) begin
  if (reset) begin
    state <= INIT;
	 pending_state <= INIT;
	 address <= 0;
	 line1 <= 0;
	 line2 <= 0;
  end
  else begin
    state <= next_state;
	 pending_state <= next_pending_state;
	 address <= next_address;
	 line1 <= next_line1;
	 line2 <= next_line2;
  end
end

endmodule
