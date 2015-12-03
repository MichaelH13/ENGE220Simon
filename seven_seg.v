
module seven_seg(output reg[7:0] seg, input [3:0] hex);

always@* begin

	case(hex)
		0: seg= ~8'b10111111;
		1: seg= ~8'b10000110;
		2: seg= ~8'b11011011;
		3: seg= ~8'b11001111;
		4: seg= ~8'b11100110;
		5: seg= ~8'b11101101;
		6: seg= ~8'b11111101;
		7: seg= ~8'b10000111;
		8: seg= ~8'b11111111;
		9: seg= ~8'b11101111;
		10: seg= ~8'b11110111;
		11: seg= ~8'b11111100;
		12: seg= ~8'b10111001;
		13: seg= ~8'b11011110;
		14: seg= ~8'b11111001;
		15: seg= ~8'b11110001;
	default: seg= ~8'b10000000;
	
	endcase
end

endmodule
