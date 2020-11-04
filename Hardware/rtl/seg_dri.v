module seg_dri(
     input        [19:0]    num    ,        // 6个数码管要显示的数值
     //output
	  output  reg  [6:0]     DIG0   ,        
	  output  reg  [6:0]     DIG1   , 
	  output  reg  [6:0]     DIG2   , 
	  output  reg  [6:0]     DIG3   , 
	  output  reg  [6:0]     DIG4    
	 // output  reg  [6:0]     DIG5    

);
 /***************数码管共阳极接法************************/
		 parameter 
		    D0 =7'b1000_000,
			 D1 =7'b1111_001,
			 D2 =7'b0100_100,
			 D3 =7'b0110_000,
			 D4 =7'b0011_001,
			 D5 =7'b0010_010,
			 D6 =7'b0000_010,
			 D7 =7'b1111_000,
			 D8 =7'b0000_000,
			 D9 =7'b0010_000,
			 DE =7'b1000_000;

   always @ (*)
       begin
	       case(num[3:0])
			 4'd0 :  DIG0=D0;
			 4'd1 :  DIG0=D1;
			 4'd2 :  DIG0=D2;
			 4'd3 :  DIG0=D3;
			 4'd4 :  DIG0=D4;
			 4'd5 :  DIG0=D5;
			 4'd6 :  DIG0=D6;
			 4'd7 :  DIG0=D7;
		    4'd8 :  DIG0=D8;
          4'd9 :  DIG0=D9;
			 default : DIG0 =DE;
			 endcase
			end
   always @ (*)
       begin
	         case(num[7:4])
			 4'd0 :  DIG1=D0;
			 4'd1 :  DIG1=D1;
			 4'd2 :  DIG1=D2;
			 4'd3 :  DIG1=D3;
			 4'd4 :  DIG1=D4;
			 4'd5 :  DIG1=D5;
			 4'd6 :  DIG1=D6;
			 4'd7 :  DIG1=D7;
		    4'd8 :  DIG1=D8;
          4'd9 :  DIG1=D9;
			 default : DIG1 =DE;
		  endcase
		end
	always @ (*)
       begin
	         case(num[11:8])
			 4'd0 :  DIG2=D0;
			 4'd1 :  DIG2=D1;
			 4'd2 :  DIG2=D2;
			 4'd3 :  DIG2=D3;
			 4'd4 :  DIG2=D4;
			 4'd5 :  DIG2=D5;
			 4'd6 :  DIG2=D6;
			 4'd7 :  DIG2=D7;
		    4'd8 :  DIG2=D8;
          4'd9 :  DIG2=D9;
			 default : DIG2 =DE;
		  endcase
		end
	always @ (*)
       begin
	         case(num[15:12])
			 4'd0 :  DIG3=D0;
			 4'd1 :  DIG3=D1;
			 4'd2 :  DIG3=D2;
			 4'd3 :  DIG3=D3;
			 4'd4 :  DIG3=D4;
			 4'd5 :  DIG3=D5;
			 4'd6 :  DIG3=D6;
			 4'd7 :  DIG3=D7;
		    4'd8 :  DIG3=D8;
          4'd9 :  DIG3=D9;
			 default : DIG3 =DE;
		  endcase
		end
	always @ (*)
       begin
	         case(num[19:16])
			 4'd0 :  DIG4=D0;
			 4'd1 :  DIG4=D1;
			 4'd2 :  DIG4=D2;
			 4'd3 :  DIG4=D3;
			 4'd4 :  DIG4=D4;
			 4'd5 :  DIG4=D5;
			 4'd6 :  DIG4=D6;
			 4'd7 :  DIG4=D7;
		    4'd8 :  DIG4=D8;
          4'd9 :  DIG4=D9;
			 default : DIG4 =DE;
		  endcase
		end
	/*always @ (*)
       begin
	         case(num[23:20])
			 4'd0 :  DIG5=D0;
			 4'd1 :  DIG5=D1;
			 4'd2 :  DIG5=D2;
			 4'd3 :  DIG5=D3;
			 4'd4 :  DIG5=D4;
			 4'd5 :  DIG5=D5;
			 4'd6 :  DIG5=D6;
			 4'd7 :  DIG5=D7;
		    4'd8 :  DIG5=D8;
          4'd9 :  DIG5=D9;
			 default : DIG5 =DE;
		  endcase
		end*/
endmodule
