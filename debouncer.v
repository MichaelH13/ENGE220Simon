module debouncer(output pressed, held, input button, clk, reset);

    localparam sampletime = (1000000 - 1);
    reg button_sampled, button_debounced, button_debounced_d;
    reg [19:0] timer;
	 
    assign held = button_debounced;
    assign pressed = button_debounced & ~button_debounced_d;
    
    always@(posedge clk) begin
        if (reset) begin
            timer <= sampletime;
        end
        else begin
            timer <= timer - 1;
            if (timer <= 0) 
                timer <= sampletime;
        end
    end
    
    always@(posedge clk) begin
        button_debounced_d <= button_debounced;
        if (timer == 0) begin
            button_sampled <= button;
            if (button_sampled == button)
                button_debounced <= button;
        end
    end
endmodule
