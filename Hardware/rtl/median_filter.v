
`timescale 1ns/1ps

module median_filter(
	input             clk,
	input             rst_n,

	input [7:0]       data_in,
	input             data_in_en,
	input             hs_in,
	input             vs_in,

	output[7:0]      data_out,
	output            data_out_en,

	output            hs_out,
	output            vs_out
);
		 
	wire [7:0] line0;
	wire [7:0] line1;
	wire [7:0] line2;

	//--------------------------------------
	//pipeline control signal
	//--------------------------------------
	reg         hs0;
	reg         hs1;
	reg         hs2;

	reg         vs0;
	reg         vs1;
	reg         vs2;

	reg         de0;
	reg         de1;
	reg         de2;
	//-------------------------------------
	//pipeline data
	//-------------------------------------
	reg [7:0] line0_data0;
	reg [7:0] line0_data1;
	reg [7:0] line0_data2;

	reg [7:0] line1_data0;
	reg [7:0] line1_data1;
	reg [7:0] line1_data2;

	reg [7:0] line2_data0;
	reg [7:0] line2_data1;
	reg [7:0] line2_data2;

	//--------------------------------------
	//define line max mid min
	//--------------------------------------
	reg [7:0] line0_max;
	reg [7:0] line0_mid;
	reg [7:0] line0_min;

	reg [7:0] line1_max;
	reg [7:0] line1_mid;
	reg [7:0] line1_min;

	reg [7:0] line2_max;
	reg [7:0] line2_mid;
	reg [7:0] line2_min;

	//----------------------------------------------
	// define //max of min //mid of mid// min of max
	//----------------------------------------------

	reg [7:0] max_max;
	reg [7:0] max_mid;
	reg [7:0] max_min;

	reg [7:0] mid_max;
	reg [7:0] mid_mid;
	reg [7:0] mid_min;

	reg [7:0] min_max;
	reg [7:0] min_mid;
	reg [7:0] min_min;

	//---------------------------------------------
	// define mid of mid
	//---------------------------------------------

	reg [7:0] mid;

		line_buffer line3x3(
			.clken(data_in_en),
			.clock(clk),
			.shiftin(data_in),
			.shiftout(),
			.taps0x(line0),
			.taps1x(line1),
			.taps2x(line2)
		);

	//----------------------------------------------------
	//delay control signal
	//----------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
	  if(!rst_n) begin
		 hs0 <= 1'b0;
		 hs1 <= 1'b0;
		 hs2 <= 1'b0;

		 vs0 <= 1'b0;
		 vs1 <= 1'b0;
		 vs2 <= 1'b0;

		 de0 <= 1'b0;
		 de1 <= 1'b0;
		 de2 <= 1'b0;
	  end
	  else if(data_in_en) begin
		 hs0 <= hs_in;
		 hs1 <= hs0;
		 hs2 <= hs1;

		 vs0 <= vs_in;
		 vs1 <= vs0;
		 vs2 <= vs1;

		 de0 <= data_in_en;
		 de1 <= de0;
		 de2 <= de1;  
	  end
	end
	//----------------------------------------------------
	// Form an image matrix of three multiplied by three
	//----------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
	  if(!rst_n) begin
		 line0_data0 <= 8'b0;
		 line0_data1 <= 8'b0;
		 line0_data2 <= 8'b0;
		 
		 line1_data0 <= 8'b0;
		 line1_data1 <= 8'b0;
		 line1_data2 <= 8'b0;
		 
		 line2_data0 <= 8'b0;
		 line2_data1 <= 8'b0;
		 line2_data2 <= 8'b0;
	  end
	  else if(data_in_en) begin
		 line0_data0 <= line0;
		 line0_data1 <= line0_data0;
		 line0_data2 <= line0_data1;
		 
		 line1_data0 <= line1;
		 line1_data1 <= line1_data0;
		 line1_data2 <= line1_data1;
		 
		 line2_data0 <= line2;
		 line2_data1 <= line2_data0;
		 line2_data2 <= line2_data1;	 
	  end
	  else ;
	end
	//-----------------------------------------------------------------------------------
	//(line0 line1 line2) of (max mid min)
	//-----------------------------------------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
	  if(!rst_n) begin
		 line0_max <= 8'd0;
		 line0_mid <= 8'd0;
		 line0_min <= 8'd0;
	  end
	  else if(data_in_en) begin
		 if((line0_data0 >= line0_data1) && (line0_data0 >= line0_data2)) begin
			line0_max <= line0_data0;
			if(line0_data1 >= line0_data2) begin
			  line0_mid <= line0_data1;
			  line0_min <= line0_data2;
			end 
			else begin
			  line0_mid <= line0_data2;
			  line0_min <= line0_data1;
			end
		 end
		 else if((line0_data1 > line0_data0) && (line0_data1 >= line0_data2)) begin
			line0_max <= line0_data1;
			if(line0_data0 >= line0_data2) begin
			  line0_mid <= line0_data0;
			  line0_min <= line0_data2;
			end 
			else begin
			  line0_mid <= line0_data2;
			  line0_min <= line0_data0;
			end
		 end
		 else if((line0_data2 > line0_data0) && (line0_data2 > line0_data1)) begin
			line0_max <= line0_data2;
			if(line0_data0 >= line0_data1) begin
			  line0_mid <= line0_data0;
			  line0_min <= line0_data1;
			end 
			else begin
			  line0_mid <= line0_data1;
			  line0_min <= line0_data0;
			end
		 end
	  end
	end

	always @(posedge clk or negedge rst_n) begin
	  if(!rst_n) begin
		 line1_max <= 8'd0;
		 line1_mid <= 8'd0;
		 line1_min <= 8'd0;
	  end
	  else if(data_in_en) begin
		 if((line1_data0 >= line1_data1) && (line1_data0 >= line1_data2)) begin
			line1_max <= line1_data0;
			if(line1_data1 >= line1_data2) begin
			  line1_mid <= line1_data1;
			  line1_min <= line1_data2;
			end 
			else begin
			  line1_mid <= line1_data2;
			  line1_min <= line1_data1;
			end
		 end
		 else if((line1_data1 > line1_data0) && (line1_data1 >= line1_data2)) begin
			line1_max <= line1_data1;
			if(line1_data0 >= line1_data2) begin
			  line1_mid <= line1_data0;
			  line1_min <= line1_data2;
			end 
			else begin
			  line1_mid <= line1_data2;
			  line1_min <= line1_data0;
			end	 
		 end
		 else if((line1_data2 > line1_data0) && (line1_data2 > line1_data1)) begin
			line1_max <= line1_data2;
			if(line1_data0 >= line1_data1) begin
			  line1_mid <= line1_data0;
			  line1_min <= line1_data1;
			end 
			else begin
			  line1_mid <= line1_data1;
			  line1_min <= line1_data0;
			end	 
		 end
	  end
	end

	always @(posedge clk or negedge rst_n) begin
	  if(!rst_n) begin
		 line2_max <= 8'd0;
		 line2_mid <= 8'd0;
		 line2_min <= 8'd0;
	  end
	  else if(data_in_en) begin
		 if((line2_data0 >= line2_data1) && (line2_data0 >= line2_data2)) begin
			line2_max <= line2_data0;
			if(line2_data1 > line2_data2) begin
			  line2_mid <= line2_data1;
			  line2_min <= line2_data2;
			end 
			else begin
			  line2_mid <= line2_data2;
			  line2_min <= line2_data1;
			end
		 end
		 else if((line2_data1 > line2_data0) && (line2_data1 >= line2_data2)) begin
			line2_max <= line2_data1;
			if(line2_data0 >= line2_data2) begin
			  line2_mid <= line2_data0;
			  line2_min <= line2_data2;
			end 
			else begin
			  line2_mid <= line2_data2;
			  line2_min <= line2_data0;
			end	 
		 end
		 else if((line2_data2 > line2_data0) && (line2_data2 > line2_data1)) begin
			line2_max <= line2_data2;
			if(line2_data0 >= line2_data1) begin
			  line2_mid <= line2_data0;
			  line2_min <= line2_data1;
			end 
			else begin
			  line2_mid <= line2_data1;
			  line2_min <= line2_data0;
			end	 
		 end
	  end
	end
	//----------------------------------------------------------------------------------
	// (max_max max_mid max_min) of ((line0 line1 line2) of max)
	//----------------------------------------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
	  if(!rst_n) begin
		 max_max <= 8'd0;
		 max_mid <= 8'd0;
		 max_min <= 8'd0;
	  end
	  else if(data_in_en) begin
		 if((line0_max >= line1_max) && (line0_max >= line2_max)) begin
			max_max <= line0_max;
			if(line1_max >= line2_max) begin
			  max_mid <= line1_max;
			  max_min <= line2_max;
			end 
			else begin
			  max_mid <= line2_max;
			  max_min <= line1_max;
			end
		 end
		 else if((line1_max > line0_max) && (line1_max >= line2_max)) begin
			max_max <= line1_max;
			if(line0_max >= line2_max) begin
			  max_mid <= line0_max;
			  max_min <= line2_max;
			end 
			else begin
			  max_mid <= line2_max;
			  max_min <= line0_max;
			end
		 end
		 else if((line2_max > line0_max) && (line2_max > line1_max)) begin
			max_max <= line2_max;
			if(line0_max >= line1_max) begin
			  max_mid <= line0_max;
			  max_min <= line1_max;
			end 
			else begin
			  max_mid <= line1_max;
			  max_min <= line0_max;
			end
		 end
	  end
	end
	//------------------------------------------------------------------------------
	// (mid_max mid_mid mid_min) of ((line0 line1 line2)of mid)
	//------------------------------------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
	  if(!rst_n) begin
		 mid_max <= 8'd0;
		 mid_mid <= 8'd0;
		 mid_min <= 8'd0;
	  end
	  else if(data_in_en) begin
		 if((line0_mid >= line1_mid) && (line0_mid >= line2_mid)) begin
			mid_max <= line0_mid;
			if(line1_mid >= line2_mid) begin
			  mid_mid <= line1_mid;
			  mid_min <= line2_mid;
			end 
			else begin
			  mid_mid <= line2_mid;
			  mid_min <= line1_mid;
			end
		 end
		 else if((line1_mid > line0_mid) && (line1_mid >= line2_mid)) begin
			mid_mid <= line1_mid;
			if(line0_mid >= line2_mid) begin
			  mid_mid <= line0_mid;
			  mid_min <= line2_mid;
			end 
			else begin
			  mid_mid <= line2_mid;
			  mid_min <= line0_mid;
			end
		 end
		 else if((line2_mid > line0_mid) && (line2_mid > line1_mid)) begin
			mid_max <= line2_mid;
			if(line0_mid >= line1_mid) begin
			  mid_mid <= line0_mid;
			  mid_min <= line1_mid;
			end 
			else begin
			  mid_mid <= line1_mid;
			  mid_min <= line0_mid;
			end
		 end
	  end
	end
	//------------------------------------------------------------------------------
	// (min_max min_mid min_min) of ((line0 line1 line2)of min)
	//------------------------------------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
	  if(!rst_n) begin
		 min_max <= 8'd0;
		 min_mid <= 8'd0;
		 min_min <= 8'd0;
	  end
	  else if(data_in_en) begin
		 if((line0_min >= line1_min) && (line0_min >= line2_min)) begin
			min_max <= line0_min;
			if(line1_min >= line2_min) begin
			  min_mid <= line1_min;
			  min_min <= line2_min;
			end 
			else begin
			  min_mid <= line2_min;
			  min_min <= line1_min;
			end
		 end
		 else if((line1_min > line0_min) && (line1_min >= line2_min)) begin
			min_max <= line1_min;
			if(line0_min >= line2_min) begin
			  min_mid <= line0_min;
			  min_min <= line2_min;
			end 
			else begin
			  min_mid <= line2_min;
			  min_min <= line0_min;
			end
		 end
		 else if((line2_min > line0_min) && (line2_min > line1_min)) begin
			min_max <= line2_min;
			if(line0_min >= line1_min) begin
			  min_mid <= line0_min;
			  min_min <= line1_min;
			end 
			else begin
			  min_mid <= line1_min;
			  min_min <= line0_min;
			end
		 end
	  end
	end
	//------------------------------------------------------------------------------
	// middle
	//------------------------------------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
	  if(!rst_n)
		 mid <= 8'd0;
	  else if(data_in_en) begin
		 if(((max_mid >= mid_mid) && (max_mid < min_mid)) || ((max_mid >= min_mid) && (max_mid < mid_mid)))
			mid <= max_mid;
		 else if(((mid_mid > max_mid) && (mid_mid < min_mid)) || ((min_mid >= min_mid) && (mid_mid < max_mid)))
			mid <= mid_mid;
		 else if(((min_mid > max_mid) && (min_mid < mid_mid)) || ((min_mid > mid_mid) && (mid_min < max_mid)))
			mid <= min_mid;
	  end
	  else ;
	end
	//------------------------------------------------------------------------------------------------------
	//result
	//------------------------------------------------------------------------------------------------------
	assign data_out = mid;
	assign data_out_en = de2;
	assign hs_out = hs2;
	assign vs_out = vs2;
	
endmodule 