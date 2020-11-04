/*==============================================================================
*
*  LOGIC CORE:          			
*  MODULE NAME:         Key_Board()
*  COMPANY:             芯航线电子工作室
*                       xiaomeige.taobao.com
*	author:					小梅哥
*	author QQ：528369266  
*	芯航线FPGA技术支持群 472607506
*  REVISION HISTORY:  
*
*    Revision 1.0  25/12/2014     Description: Initial Release.
*
*  FUNCTIONAL DESCRIPTION:
*
*	FileType	：RTL
*
*
===============================================================================*/

module Key_Board(Clk,Rst_n,dly_done,key_in,result,done,Key_Flag,Key_Value);

	input Clk;
	input Rst_n;
	input dly_done;
	input key_in;
	input result;
	input done; //当done为高电平时，result的值传递给cp
	
	output reg Key_Flag;
	output reg [3:0]Key_Value;
	

	localparam Idelay = 3'b001;
	localparam clear  = 3'b010;	
	localparam chushu = 3'b100;
	
	reg clr;
	reg [2:0] current_s;
	reg [4:0] data_cnt;
	reg [24:0]cnt0;
	reg [399:0] cp; 
	reg one;
	
	wire [399:0] result;
	wire key_flag0,key_state0;
	wire dly_done0;
	
	assign dly_done0 = (cnt0 >= 249999);
			
	
key_filter key_filter0(	.clk(Clk),
								.rst_n(Rst_n),
								.key_in(key_in),
								.key_flag(key_flag0),
								.key_state(key_state0)
								);
	

always @ (posedge Clk, negedge Rst_n)
	if(!Rst_n)
		begin
		current_s <= Idelay;
		data_cnt <= 0;
		Key_Flag <= 0;
		Key_Value<= 0;
		cnt0 <= 0;
		cp <= 0;
		one <= 0;
		end
	else if(done && !one)
	begin
		cp <= result;
		one <= 1'b1;
	end
	else 
	begin
		case (current_s)
			Idelay:	
				begin
				if(key_flag0 && !key_state0 == 1)
				begin
					Key_Flag <= 1'b0;
					data_cnt <= 0;
					current_s <= clear;
				end
				else current_s <= current_s;
				end
			clear:
				begin
				clr <= 1;
				current_s <= chushu;
				end
			chushu:
				begin
					if(clr == 1)
						begin
							cnt0 <= cnt0 + 1;
							if(dly_done0)
							begin
							Key_Flag <= 1'b1;
							Key_Value <= 13;
							clr <= 0;
							cnt0 <= 0;
							end
						end
					else	if(dly_done) 
					begin
						case (data_cnt)
						5'd5:
							begin
								Key_Flag <= 1'b1;
								Key_Value <= 10;
								data_cnt <= data_cnt +1;
							end
						5'd11:
							begin
								Key_Flag <= 1'b1;
								Key_Value <= 11;
								data_cnt <= data_cnt +1;
							end
						5'd17:
							begin
								Key_Flag <= 1'b1;
								Key_Value <= 12;
								data_cnt <= data_cnt +1;
							end
						5'd23:
							begin
								current_s <= Idelay;
							end
						default:
							begin
								if(data_cnt == 0)
									begin
									Key_Flag <= 1'b1;
									cp <= cp >> 4;
									Key_Value <= cp[3:0];
									data_cnt <= data_cnt + 1;
									end
								else if(dly_done && data_cnt != 0)
									begin
									Key_Flag <= 1'b1;
									cp <= cp >> 4;
									Key_Value <= cp[3:0];
									data_cnt <= data_cnt + 1;
									end
								else 
									begin
									Key_Flag <= 0;
									cp <= cp;
									Key_Value <= Key_Value;
									data_cnt <= data_cnt;
									end
							end
						endcase
					end
					else begin
					Key_Flag <= 1'b0;
					Key_Value <= Key_Value;
					data_cnt <= data_cnt;
					current_s <= current_s;
					end
				end	
			default:
				begin
				current_s <= Idelay;
				data_cnt <= data_cnt;
				Key_Flag <= Key_Flag;
				Key_Value<= Key_Value;
				end
		endcase
	end		
endmodule //我觉得还是得加一个按键来控制5个数字的显示触发。
