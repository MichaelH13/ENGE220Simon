`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:26:59 11/21/2015 
// Design Name: 
// Module Name:    select_simon_button 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module select_simon_button(output reg [2:0] TL_LED, TR_LED, BL_LED, BR_LED, 
									input [3:0] button,
									input button_en);
									
	always@* begin
		TL_LED = 0;
		TR_LED = 0;
		BL_LED = 0;
		BR_LED = 0;
		
		if (button_en) begin
			case(button)
				1: begin
					TL_LED = 2;
				end
				2: begin
					TR_LED = 1;
				end
				3: begin
					BL_LED = 4;
				end
				4: begin
					BR_LED = 3;
				end
				5: begin
					TL_LED = 2;
				end
				6: begin
					TR_LED = 1;
				end
				7: begin
					BL_LED = 4;
				end
				8: begin
					BR_LED = 3;
				end
			endcase
		end
	end
endmodule
