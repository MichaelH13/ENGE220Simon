
//Speaker 440Hz Tone

//`define tone_440 (113636)

module speaker(output reg speaker, input [2:0] tone, input speaker_en, clk);

	reg [16:0] count;
	reg [16:0] sound;	

	always @* begin
	/*	tone[14] = n_switch[7];
		tone[13] = n_switch[6];
		tone[12] = n_switch[5];
		tone[11] = n_switch[4];
		tone[10] = n_switch[3];
		tone[9] = n_switch[2];
		tone[8] = n_switch[1];
		tone[7] = n_switch[0];*/
		//to allow for variable tones based on buttons pressed
		
		case(tone)
			0: sound = 113636;
			1:	sound = 101239;
			2:	sound = 90192;
			3:	sound = 85131;
			4:	sound = 75843;
			5:	sound = 67568;
			6:	sound = 60196;
			7:	sound = 56818;
		endcase
	end

	always @(posedge clk) begin

		count <= count - 1;
		if (count <= 0) begin	
			count <= sound;
		end
	end

	always @* begin
		if (speaker_en) begin
			if (count <= sound / 2) begin	//spliting the 440hz into two section for variable frequency
				speaker = 0; 
			end
			else begin
				speaker = 1; 
			end
		end
		else begin
			speaker = 0;	
		end
	end

endmodule 