// This module controls the lcd (via the lcd_*** pins). When the activate signal is
// pulsed, it holds the enable for 1ms and then waits for 1ms
// to meet the lcd timing requirements.
//
// Technically, we only need 450ns for the enable, and a cycle time of 1ms total. 
// However, a couple of instructions (clear and return home) take 1.64ms, so better
// just to make everybody wait the 2ms. 
// If we do all 32 bytes in succession, we are only looking at 64ms to do the entire display.
// Not really noticeable.

module lcd_ctrl(output reg lcd_regsel, // The register select bit (lcd pin)
                output       lcd_read, // We will likely not be reading anything (lcd pin)
					 output reg lcd_enable, // The output controlled by this module (lcd pin)
					 output reg      ready, // Indicates to the instantiating module that we are ready
				     inout [7:0] lcd_data, // The data lines to the lcd (they are inout as they can be read (lcd pin)
                      input [7:0] din, // The data we want to send to the lcd
				           input activate, // A signal telling us to start the 2ms enable
					         input  regsel, // The regsel input
					           input reset, 
						                clk
							      	        );

reg [26:0] timer;
reg activate_d;
reg [7:0] data; // The registered copy of the din bus
wire activate_pulse = activate & ~activate_d; // rising edge detector on activate

assign lcd_read = 0; // We aren't going to bother with the reads
assign lcd_data = lcd_read?8'bz:data; // pass the data through - 
                                      // I am leaving the tristate hookup even though we have tied read to 0
												  // just to emphasize that this is technically a tristate data bus.

always @ (posedge clk or posedge reset) begin
  if (reset) begin
	 timer <= 0;
	 lcd_enable <= 0;
	 lcd_regsel <= 0;
	 ready <= 1;
	 data <= 0;
  end
  else begin
    activate_d <= activate; // Save activate to form a rising edge detect.
    // If the activate signal pulses, turn off the ready to start the lcd write.
	 // Grab the inputs into our regisers (data and lcd_regsel) to save them for the duration of the write.
	 // We only want the rising edge here. When ready turns back off, we will be waiting for the next
	 // activate_pulse. If activate happnes to show up when we aren't ready, we will ignore it.

    if (activate_pulse & ready) begin
		ready <= 0;
		data <= din;
		lcd_regsel <= regsel;
	 end
	 
	 // When ready goes away, start the lcd write
	 if (!ready ) begin
	   timer <= timer+1; // run the timer = each cycle is 20ns.
		if (timer == 6) begin
		  lcd_enable <= 1; // wait 120ns before turning on enable to ensure setup time for the data
		end
	   if (timer == 50000) begin // Turn off the lcd after 1 ms (we only need 450ns - but a little slack doesn't hurt)
		  lcd_enable <= 0;
	   end
		// Then at 2 ms, end the transaction and turn the ready back on.  
	   if (timer >= 100000) begin
	     timer <= 0;
		  ready <= 1;
	   end
	 end
  end
end

endmodule
