module bcd2(output reg [3:0] hundreds, tens, ones, input [7:0] binary, input clk);

   // Internal variable for storing bits
   integer i;
   
   always @(posedge clk) begin

      //set to 0
      hundreds = 0;      
      tens = 0;      
      ones = 0;     

      // Loop eight times
      for (i = 7; i >= 0; i = i - 1) begin

         if (hundreds >= 5)
            hundreds = hundreds + 3;
            
         if (tens >= 5)
            tens = tens + 3;
            
         if (ones >= 5)
            ones = ones + 3;
         
         // Shift entire register left once
         shift = shift << 1;
      end
      
      //shift left one
      hundreds = hundreds << 1;
      hundreds[0] = tens[3];
      tens = tens << 1;
      tens[0] = ones[3];
      ones = ones << 1;
      ones[0] = binary[i];
   end
 
endmodule
