module lcd1602_ctrl(
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

	input	Clk;
	input	Rst_n;
	
	input	[4:0]Pos;
	input Set_Cursor;
	
	input	[7:0]Data;
	input Set_Data;
	input Clr_Screen;
	
	output reg init_done;

	output LCD1602_RS;
	output LCD1602_RW;
	output [7:0]LCD1602_DB;
	output LCD1602_E;
	output LCD1602_VL;
	output dly_done;
	
	localparam IDLE = 16'b0000_0000_0000_0001;
	localparam DELAY15MS = 16'b0000_0000_0000_0010;	
	localparam CMD38H1 = 16'b0000_0000_0000_0100;	
	localparam DELAY5MS = 16'b0000_0000_0000_1000;
	localparam CMD38H2 = 16'b0000_0000_0001_0000;
	localparam CMD08H = 16'b0000_0000_0010_0000;
	localparam CMD01H = 16'b0000_0000_0100_0000;	
	localparam CMD06H = 16'b0000_0000_1000_0000;	
	localparam CMD0CH = 16'b0000_0001_0000_0000;
	localparam USER_CMD = 16'b0000_0100_0000_0000;
	localparam WAIT_DONE = 16'b0000_1000_0000_0000;
	
	reg [15:0]state;
	reg [3:0]vl_cnt;
	reg [24:0]cnt;
	reg wr_cmd;
	reg wr_data;
	reg [7:0]data;
	
	wire dly_done;
	
	assign dly_done = (cnt >= 249999);
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)begin
		state <= IDLE;
		cnt <= 25'd0;
		wr_data <= 1'b0;
		wr_cmd <= 1'b0;
		data <= 8'd0;
		init_done <= 1'b0;
	end
	else begin
		case(state)
			IDLE:
				state <= DELAY15MS;
			
			DELAY15MS:
				begin
					if(cnt >= 749999)begin

						state <= CMD38H1;
						cnt <= 0;
					end
					else begin
						state <= DELAY15MS;
						cnt <= cnt + 1'b1;
					end
				end
			
			CMD38H1:
				begin
					wr_cmd <= 1'b1;
					data <= 8'h38;
					state <= DELAY5MS;
				end
			
			DELAY5MS:
				begin
					wr_cmd <= 1'b0;
					if(dly_done)begin
						state <= CMD38H2;
						cnt <= 0;
					end
					else begin
						state <= DELAY5MS;
						cnt <= cnt + 1'b1;
					end
				end
				
			CMD38H2:
				begin
					wr_cmd <= 1'b1;
					data <= 8'h38;
					state <= CMD08H;
				end
			
			CMD08H:
				begin
					if(dly_done)begin
						state <= CMD01H;
						cnt <= 0;
						wr_cmd <= 1'b1;
						data <= 8'h08;
					end
					else begin
						state <= CMD08H;
						cnt <= cnt + 1'b1;
						wr_cmd <= 1'b0;
					end
				end
				
			CMD01H:
				begin
					if(dly_done)begin
						state <= CMD06H;
						cnt <= 0;
						wr_cmd <= 1'b1;
						data <= 8'h01;
					end
					else begin
						state <= CMD01H;
						cnt <= cnt + 1'b1;
						wr_cmd <= 1'b0;
					end
				end

			CMD06H:
				begin
					if(dly_done)begin
						state <= CMD0CH;
						cnt <= 0;
						wr_cmd <= 1'b1;
						data <= 8'h06;
					end
					else begin
						state <= CMD06H;
						cnt <= cnt + 1'b1;
						wr_cmd <= 1'b0;
					end
				end
				
			CMD0CH:
				begin
					if(dly_done)begin
						state <= USER_CMD;
						init_done <= 1'b1;
						cnt <= 0;
						wr_cmd <= 1'b1;
						data <= 8'h0F;
					end
					else begin
						state <= CMD0CH;
						cnt <= cnt + 1'b1;
						wr_cmd <= 1'b0;
					end
				end
				
			USER_CMD:
				begin
					state <= USER_CMD;
					wr_cmd <= 1'b0;
					wr_data <= 1'b0;
					if(Set_Cursor)begin
						wr_cmd <= 1'b1;
						data <= {1'b1,Pos[4],2'd0,Pos[3:0]};
						state <= WAIT_DONE;
					end
					if(Set_Data)begin
						wr_data <= 1'b1;
						data <= Data;
						state <= WAIT_DONE;
					end
					if(Clr_Screen)begin
						wr_cmd <= 1'b1;
						data <= 8'h01;
						state <= WAIT_DONE;
					end
				end
					
			WAIT_DONE:
				begin
					wr_cmd <= 1'b0;
					wr_data <= 1'b0;
					if(dly_done)begin
						state <= USER_CMD;
						cnt <= 0;
					end
					else begin
						state <= WAIT_DONE;
						cnt <= cnt + 1'b1;
					end
				end
				
			default:state <= IDLE;
		endcase
	end
	
	lcd1602_driver lcd1602_driver(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.wr_cmd(wr_cmd),
		.wr_data(wr_data),
		.data(data),
		.wr_done(),
		.LCD1602_RS(LCD1602_RS),
		.LCD1602_RW(LCD1602_RW),
		.LCD1602_DB(LCD1602_DB),
		.LCD1602_E(LCD1602_E)
	);
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		vl_cnt <= 4'd0;
	else 
		vl_cnt <= vl_cnt + 4'd1;
		
	assign LCD1602_VL = (vl_cnt > 9);

endmodule
