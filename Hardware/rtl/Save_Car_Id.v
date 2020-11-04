module Save_Car_Id(
       input clk,
		 input rst_n,
		 input [19:0] digit,
		 //input  led,
		 //input  en,
		 output reg done,
		 output reg [399:0] result
);
//reg done_cnt;
reg [4:0]cnt;
reg [399:0] result_0;
reg [22:0] cnt_delay;
reg clk_delay;
reg [19:0] data_0 ;
reg [19:0] data_1 ;
reg key_data;

//wire key_flag0;
//wire key_state0;

always @ (negedge clk, negedge rst_n)
if(!rst_n)
	begin
	cnt_delay <= 0;
	clk_delay <= 0;
	end
else if(cnt_delay >= 5_999_999)
	begin
	clk_delay <= !clk_delay;
	cnt_delay <= 0;
	end
else begin
	clk_delay <= clk_delay;
	cnt_delay <= cnt_delay + 1;
end 
	

always @ (posedge clk_delay, negedge rst_n)
if(!rst_n)
	begin
	data_0 <= 0;
	data_1 <= 0;
	key_data <= 0;
	end
else if(digit)
begin
	data_0 <= digit;
	data_1 <= data_0;
	if(data_1 != data_0)
	begin
		key_data <= 1'b1;
	end
	else begin
		key_data <= 1'b0;
	end	
end



always@(posedge key_data or negedge rst_n )
begin
 if(!rst_n)
   begin
	 cnt <=5'd0;
	 result_0 <=0;
	 done <= 0;
	 result <= 0;
   end
 else if(cnt<='d19)
		begin
		case(cnt)
		5'd0: result_0[19:0]<= {digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd1: result_0[39:20]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd2: result_0[59:40]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd3: result_0[79:60]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd4: result_0[99:80]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd5: result_0[119:100]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd6: result_0[139:120]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd7: result_0[159:140]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd8: result_0[179:160]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd9: result_0[199:180]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd10:result_0[219:200]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd11:result_0[239:220]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd12:result_0[259:240]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd13:result_0[279:260]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd14:result_0[299:280]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd15:result_0[319:300]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd16:result_0[339:320]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd17:result_0[359:340]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd18:result_0[379:360]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		5'd19:result_0[399:380]<={digit[3:0],digit[7:4],digit[11:8],digit[15:12],digit[19:16]};
		default: result_0 <= result_0;
		endcase
      cnt <= cnt + 1;
		end
 else if(cnt=='d20)
     begin
	  done <= 1;
	  result <= result_0;
	  end
else
 begin
		cnt <= cnt;
		result_0 <= result_0;
		result <= result;
		end
end
endmodule 