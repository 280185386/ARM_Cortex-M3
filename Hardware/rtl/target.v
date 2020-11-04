module target(
    input clk,
	 input rst_n,
		
	  //图像处理前的数据接口
    input               pre_frame_vsync ,   // vsync信号
    input               pre_frame_hsync ,   // hsync信号
    input               pre_frame_de    ,   // 灰度处理之后的信号
	 
	 input         [7:0]        gray_b              ,    // 二值化图像的数据输入
    input         [10:0]       xpos              ,
    input         [10:0]       ypos              ,
	 input                      X_Y_P               ,     //目标确定信号
	 //图像处理后的数据接口
	 // output              post_frame_vsync,   // vsync信号
    //output              post_frame_hsync,   // hsync信号
    //output              post_frame_de   ,  // 二值化处理之前的信号
	 
	 output           reg [10:0] save_x_st,  //车牌边界初始x值
    output           reg [10:0] save_y_st,  //车牌边界初始y值
    output           reg [10:0] save_x_end, //车牌边界结束x值
    output           reg [10:0] save_y_end,  //车牌边界结束y值
    output           reg        project_done_flag
);
//localparam define
localparam st_init    = 3'b001;
localparam st_project = 3'b010;
localparam st_process = 3'b100;

parameter DEPBIT  = 10  ;
parameter H_PIXEL = 1024;
parameter V_PIXEL = 768 ;
//reg define
reg [ 4:0]          cur_state         ;
reg [ 4:0]          nxt_state         ;
reg [10:0]          cnt               ;
reg                 frame_vsync_d0    ;
//ram interface
reg                 h_we              ;   
reg [10:0]          h_waddr           ;
reg [10:0]          h_raddr           ;
reg                 h_data_i          ; //写的行数据
reg                 h_do_d0           ; //行输出数据
reg                 v_we              ;
reg [10:0]          v_waddr           ;
reg [10:0]          v_raddr           ;
reg                 v_data_i          ; //列写数据
reg                 v_do_d0           ; //列读数据


//reg [10:0] cnt_h[V_PIXEL]; //行计数, 一共有768行
//reg [10:0] cnt_v[H_PIXEL]; //列计数，一共有1024列
reg    [1:0]      frame_cnt;      

reg [10:0] save_x_st_0;  //车牌边界初始x值
reg [10:0] save_y_st_0;  //车牌边界初始y值
reg [10:0] save_x_end_0; //车牌边界结束x值
reg [10:0] save_y_end_0; //车牌边界结束y值

wire                h_data_o;
wire                v_data_o;
wire                target_flag;
wire                target_flag_0;
wire                target_flag_1;
wire                frame_vsync_fall  ;

assign frame_vsync_fall = frame_vsync_d0 & ~pre_frame_vsync; //
/******判断条件********/
assign                target_flag=(gray_b==8'd255)?1:0;

assign h_rise =  h_data_o & ~h_do_d0; //当h_rise为1时表示，前一个数据为1，后一个数据为0.即前一个为黑后一个为白，数字行信号的后边界
assign h_fall = ~h_data_o &  h_do_d0; //当h_fall为1时表示，前一个数据为0，后一个数据为1.即前一个为白后一个为黑，数字行信号的前边界
assign v_rise =  v_data_o & ~v_do_d0; //当v_rise为1时表示，前一个数据为1，后一个数据为0.即前一个为黑后一个为白，数字列信号的后边界
assign v_fall = ~v_data_o &  v_do_d0; //当v_fall为1时表示，前一个数据为1，后一个数据为0.即前一个为黑后一个为白，数字列信号的前边界
//投影结束后输出采集到的行列数
always @(*) begin
    if(project_done_flag && cur_state == st_process)begin
        save_x_st = save_x_st_0;
		  save_y_st = save_y_st_0;
		  save_x_end = save_x_end_0;
		  save_y_end = save_y_end_0;
     end
	  else begin
        save_x_st = save_x_st;
		  save_y_st = save_y_st;
		  save_x_end = save_x_end;
		  save_y_end = save_y_end ;
     end
end
//打拍采沿
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        h_do_d0 <= 1'b0;
        v_do_d0 <= 1'b0;
    end
    else begin
        h_do_d0 <= h_data_o;
        v_do_d0 <= v_data_o;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        frame_vsync_d0 <= 1'b0;
    else
        frame_vsync_d0 <= pre_frame_vsync;
end

//帧计数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        frame_cnt <=2'd0;
    else if(frame_cnt == 2'd3)
        frame_cnt <=2'd0;
    else if(frame_vsync_fall)
        frame_cnt <= frame_cnt + 1'd1;
end

//(三段式状态机)状态转移
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
      cur_state <= st_init;
  else
      cur_state <= nxt_state;
end

//状态转移条件
always @( * ) begin
    case(cur_state)
        st_init: begin
            if(frame_cnt == 2'd1)      // initial myram
                nxt_state = st_project;
            else
                nxt_state = st_init;
        end
        st_project:begin
            if(frame_cnt == 2'd2)
                nxt_state = st_process;
            else
                nxt_state = st_project;
        end
        st_process:begin
            if(frame_cnt == 2'd0)
                nxt_state = st_init;
            else
                nxt_state = st_process;
        end
    endcase
end
//状态任务
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin	 
	     h_we    <= 1'b0;
        h_waddr <= 11'b0;
        h_raddr <= 11'b0;
        h_data_i<= 1'b0;
        v_we    <= 1'b0;
        v_waddr <= 11'b0;
        v_raddr <= 11'b0;
        v_data_i<= 1'b0;
        cnt     <= 11'd0;
		  project_done_flag<= 1'b0;
		  save_x_st_0 = 0;
		  save_y_st_0 = 0;
		  save_x_end_0 = 1024;
		  save_y_end_0 = 768 ;
	     end
	 else case(nxt_state)
	      st_init: begin
			 if(cnt == H_PIXEL) begin  //如果计数值达到行像素点的值后，清零
                cnt     <=  'd0;
                h_we    <= 1'b0;
                h_waddr <=  'd0;     //行写地址
                h_raddr <=  'd0;     //行读地址
                v_raddr <=  'd0;     //列读地址
                h_data_i<= 1'b0;
                v_we    <= 1'b0;
                v_waddr <=  'd0;    //列写地址
                v_data_i<= 1'b0;
					 save_x_st_0 = 0;
		          save_y_st_0 = 0;
		          save_x_end_0 = 1024;
		          save_y_end_0 = 768 ;
					 end
			  else
			     begin
				    cnt  <= cnt +1'b1;  //计数
                h_we <= 1'b1;       //
                h_waddr <= h_waddr + 1'b1;
                h_data_i <= 1'b0;
                v_we <= 1'b1;
                v_waddr <= v_waddr + 1'b1;
                v_data_i <= 1'b0;
				  
				  end
			  
			end
			
			 st_project:begin
			 if(pre_frame_de && target_flag&&X_Y_P) begin 
                h_we <= 1'b1;                    
                h_waddr <= ypos;                
                h_data_i<= 1'b1;
                v_we <= 1'b1;
                v_waddr <= xpos;
                v_data_i <= 1'b1;
            end
            else begin
                h_we <= 1'b0;
                h_waddr <= 'd0;
                h_data_i <= 1'b0;
                v_we <= 1'b0;
                v_waddr <= 'd0;
                v_data_i <= 1'b0;
            end			 
             
           end
			  
			 st_process:begin 
			 if(v_raddr==H_PIXEL)
			    project_done_flag <= 1'b1;   //投影完成
			 else begin
			       cnt <= 'd0;
                v_raddr <= v_raddr + 1'b1;
                h_raddr <= (h_raddr == V_PIXEL) ? h_raddr : (h_raddr + 1'b1);
                project_done_flag <= 1'b0;

               end
			 if(h_rise)  //如果满足上边界
				   save_y_st_0 <=h_raddr+17;
			 else if(h_fall)  //如果满足下边界
				        save_y_end_0 <=h_raddr-17;
			
			 if(v_rise)  //如果满足前边界
				   save_x_st_0 <=v_raddr+12;
			 else  if(v_fall) //如果满足后边界
				   save_x_end_0 <= v_raddr-15;
			  
        end
		 endcase
end
//垂直投影
myram #(
    .WIDTH(1  ),
    .DEPTH(H_PIXEL),
    .DEPBIT(DEPBIT)
)u_h_myram(
    //module clock
    .clk(clk),
    //ram interface
    .we(v_we),  //垂直投影的写使能
    .waddr(v_waddr),  //行地址
    .raddr(v_raddr),
    .dq_i(v_data_i),   //写的行数据
    .dq_o(v_data_o)    //读取的行数据
);	  
//水平投影
myram #(
    .WIDTH(1  ),
    .DEPTH(V_PIXEL),
    .DEPBIT(DEPBIT)
)u_v_myram(
    //module clock
    .clk(clk),
    //ram interface
    .we(h_we),
    .waddr(h_waddr),
    .raddr(h_raddr),
    .dq_i(h_data_i),
    .dq_o(h_data_o)
);
		  
			 
	 
endmodule 



