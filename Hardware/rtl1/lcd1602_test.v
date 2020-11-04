module lcd1602_test(
	Clk,
	Rst_n,
	key_in,
	result,
	done,
	
	LCD1602_RS,
	LCD1602_RW,
	LCD1602_DB,
	LCD1602_E,
	LCD1602_VL
);
	input	Clk;
	input	Rst_n;
	input key_in;
	input wire [399:0] result;
	input done;
	
	output LCD1602_RS;
	output LCD1602_RW;
	output [7:0]LCD1602_DB;
	output LCD1602_E;
	output LCD1602_VL;
	
	
	reg Set_Cursor,Set_Data,Clr_Screen;
	reg [7:0]Pos,Data;
	wire init_done;
	wire dly_done;
	
	lcd1602_ctrl lcd1602_ctrl(
		Clk,
		Rst_n,
		Pos,
		Set_Cursor,
		Data,
		Set_Data,
		Clr_Screen,
		init_done,
		
		LCD1602_RS,
		LCD1602_RW,
		LCD1602_DB,
		LCD1602_E,
		LCD1602_VL,
		dly_done
	);
	
	wire Key_Flag;
	wire [3:0]Key_Value;
	
	Key_Board Key_Board_inst(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.dly_done(dly_done),
		.key_in(key_in),
		.result(result),
		.done(done),
		.Key_Flag(Key_Flag),
		.Key_Value(Key_Value)
	);
		
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)begin
		Set_Cursor <= 1'b0;
		Set_Data <= 1'b0;
		Clr_Screen <= 1'b0;
		Pos <= 8'd0;
		Data <= 8'd0;		
	end
	else if(init_done && Key_Flag)begin
		case(Key_Value)
			4'd0:begin Data <= "0";Set_Data <= 1;end
			4'd1:begin Data <= "1";Set_Data <= 1;end
			4'd2:begin Data <= "2";Set_Data <= 1;end
			4'd3:begin Data <= "3";Set_Data <= 1;end
			4'd4:begin Data <= "4";Set_Data <= 1;end
			4'd5:begin Data <= "5";Set_Data <= 1;end			
			4'd6:begin Data <= "6";Set_Data <= 1;end
			4'd7:begin Data <= "7";Set_Data <= 1;end
			4'd8:begin Data <= "8";Set_Data <= 1;end
			4'd9:begin Data <= "9";Set_Data <= 1;end
			4'd10:begin Pos <= 7;Set_Cursor <= 1;end
			4'd11:begin Pos <= 16;Set_Cursor <= 1;end
			4'd12:begin Pos <= 23;Set_Cursor <= 1;end
			4'd13:begin Clr_Screen <= 1;end
			default:begin Set_Cursor <= 0;Set_Data <= 0;Clr_Screen <= 1'b0;end
		endcase
	end
	else begin
		Set_Cursor <= 0;
		Set_Data <= 0;
		Clr_Screen <= 1'b0;
	end
	
endmodule
