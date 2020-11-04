module lcd1602_driver(
	Clk,
	Rst_n,
	wr_cmd,
	wr_data,
	data,
	wr_done,
	
	LCD1602_RS,
	LCD1602_RW,
	LCD1602_DB,
	LCD1602_E
);

	input	Clk;
	input	Rst_n;
	
	input wr_cmd;
	input wr_data;
	input [7:0]data;
	output reg wr_done;
	output reg LCD1602_RS;
	output reg LCD1602_RW;
	output reg [7:0]	LCD1602_DB;
	output reg LCD1602_E;	
	
	localparam IDLE = 16'b0000_0000_0000_0001;
	localparam DLY1 = 16'b0000_0000_0000_0010;	
	localparam DLY2 = 16'b0000_0000_0000_0100;	
	localparam SET_E = 16'b0000_0000_0000_1000;
	localparam DLY3 = 16'b0000_0000_0001_0000;
	localparam CLR_E = 16'b0000_0000_0010_0000;
	localparam DLY4 = 16'b0000_0000_0100_0000;	

	reg [15:0]state;
	
	reg [7:0]cnt;
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)begin
		state <= IDLE;
		LCD1602_RS <= 1'b0;
		LCD1602_RW <= 1'b0;
		LCD1602_DB <= 8'd0;
		LCD1602_E <= 1'b0;
		wr_done <= 1'b0;
		cnt <= 8'd0;
	end
	else begin
		case(state)
			IDLE:
				begin
					wr_done <= 1'b0;
					cnt <= 8'd0;
					if(wr_cmd)begin
						LCD1602_RS <= 1'b0;
						LCD1602_RW <= 1'b0;
						LCD1602_DB <= data;
						state <= DLY1;
					end
					else if(wr_data)begin
						LCD1602_RS <= 1'b1;
						LCD1602_RW <= 1'b0;
						LCD1602_DB <= data;
						state <= DLY1;
					end
					else 
						state <= IDLE;
				end

			DLY1:state <= DLY2;
			DLY2:state <= SET_E;
			SET_E:
				begin
					LCD1602_E <= 1'b1;
					state <= DLY3;
				end
				
			DLY3:
				begin
				
					if(cnt >= 10)begin
						state <= CLR_E;
						cnt <= 0;
					end
					else begin
						state <= DLY3;
						cnt <= cnt + 1'b1;
					end
				end
			CLR_E:
				begin
					LCD1602_E <= 1'b0;
					state <= DLY4;
				end
				
			DLY4:
				begin
					if(cnt >= 15)begin
						state <= IDLE;
						wr_done <= 1'b1;
						cnt <= 0;
					end
					else begin
						state <= DLY4;
						cnt <= cnt + 1'b1;
					end
				end
			default:state <= IDLE;
		endcase
	end
	
endmodule
