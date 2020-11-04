`timescale 1ns/1ns

module lcd1602_ctrl_tb;
	
	reg	Clk;
	reg	Rst_n;
	reg   key_in;

	wire LCD1602_RS;
	wire LCD1602_RW;
	wire [7:0]LCD1602_DB;
	wire LCD1602_E;	

lcd1602_test lcd1602_test0(
	.Clk(Clk),
	.Rst_n(Rst_n),
	.key_in(key_in),
	
	.LCD1602_RS(LCD1602_RS),
	.LCD1602_RW(LCD1602_RW),
	.LCD1602_DB(LCD1602_DB),
	.LCD1602_E(LCD1602_E),
	.LCD1602_VL(LCD1602_VL)
);
	
	
	initial Clk = 1;
	always #10 Clk = ~Clk;
			
	initial begin
		Rst_n = 1;
		#100
		Rst_n = 0;
		#100
		#202;
		Rst_n = 1;
		#200
		#2000000
		key_in = 1;
		#40000000
		key_in = 0;
		#40000000
		
		key_in = 1;
		#200000000
		key_in = 0;
		#40000000;
		key_in = 1;
		#40000000
		$stop;
	end

endmodule