module Gray(
   //module clock
   input               clk             ,   // 模块驱动时钟
   input               rst_n           ,   // 复位信号
  
    //图像处理前的数据接口
   input               pre_frame_vsync ,   // vsync信号
   input               pre_frame_hsync ,   // hsync信号
   input               pre_frame_de    ,   // 灰度处理完成之前的数据使能
  
   input   [15:0]      ram_data,     //像素点数据
  
    //图像处理后的数据接口
   output              post_frame_vsync,   // vsync信号
   output              post_frame_hsync,   // hsync信号
	output              post_frame_de   ,   // 灰度处理完成后的数据使能 
   output      [7:0]   img_y           ,   // 输出图像Y数据
   output      [7:0]   img_cb          ,   // 输出图像Cb数据
   output      [7:0]   img_cr             // 输出图像Cr数据
   
);     
/*wire  [7:0]   oR;
wire  [7:0]   oG;
wire  [7:0]   oB;   
       


// RGB565->RGB888  
assign oB = {ram_data[4:0],ram_data[2:0]}; 
assign OG = {ram_data[10:5],ram_data[1:0]};
assign oR = {ram_data[15:11],ram_data[13:11]};

 //RGB888->Gary         
assign gary_data = (oR*313524+oG*615514+oB*119538)>>20;


//灰度图像输出
//assign vga_data = vga_en?{Gary,Gary,Gary}:24'd0;*/
wire  [7:0]           rgb888_r;
wire  [7:0]           rgb888_g;
wire  [7:0]           rgb888_b;
wire [4:0]    img_red;
wire [5:0]    img_green;
wire [4:0]    img_blue;

reg  [15:0]   rgb_r_m0, rgb_r_m1, rgb_r_m2;
reg  [15:0]   rgb_g_m0, rgb_g_m1, rgb_g_m2;
reg  [15:0]   rgb_b_m0, rgb_b_m1, rgb_b_m2;
reg  [15:0]   img_y0 ;
reg  [15:0]   img_cb0;
reg  [15:0]   img_cr0;
reg  [ 7:0]   img_y1 ;
reg  [ 7:0]   img_cb1;
reg  [ 7:0]   img_cr1;
reg  [ 2:0]   pre_frame_vsync_d;
reg  [ 2:0]   pre_frame_hsync_d;
reg  [ 2:0]   pre_frame_de_d   ;


assign img_red=ram_data[4:0];
assign img_green=ram_data[10:5];
assign img_blue = ram_data[15:11];
assign rgb888_r         = {img_red  , img_red[4:2]  };
assign rgb888_g         = {img_green, img_green[5:4]};
assign rgb888_b         = {img_blue , img_blue[4:2] };
//同步输出数据接口信号
assign post_frame_vsync = pre_frame_vsync_d[2]      ;
assign post_frame_hsync = pre_frame_hsync_d[2]      ;
assign post_frame_de    = pre_frame_de_d[2]         ;
 
assign img_y            = pre_frame_de ? img_y1 : 8'd0;
assign img_cb           = pre_frame_de ? img_cb1: 8'd0;
assign img_cr           = pre_frame_de ? img_cr1: 8'd0;

//assign img_y=(rgb888_b*313524+rgb888_g*615514+rgb888_r*119538)>>20;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rgb_r_m0 <= 16'd0;
        rgb_r_m1 <= 16'd0;
        rgb_r_m2 <= 16'd0;
        rgb_g_m0 <= 16'd0;
        rgb_g_m1 <= 16'd0;
        rgb_g_m2 <= 16'd0;
        rgb_b_m0 <= 16'd0;
        rgb_b_m1 <= 16'd0;
        rgb_b_m2 <= 16'd0;
    end
    else begin
        rgb_r_m0 <= rgb888_r * 8'd77 ;
        rgb_r_m1 <= rgb888_r * 8'd43 ;
        rgb_r_m2 <= rgb888_r << 3'd7 ;
        rgb_g_m0 <= rgb888_g * 8'd150;
        rgb_g_m1 <= rgb888_g * 8'd85 ;
        rgb_g_m2 <= rgb888_g * 8'd107;
        rgb_b_m0 <= rgb888_b * 8'd29 ;
        rgb_b_m1 <= rgb888_b << 3'd7 ;
        rgb_b_m2 <= rgb888_b * 8'd21 ;
    end
end

//step2 pipeline add
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_y0  <= 16'd0;
        img_cb0 <= 16'd0;
        img_cr0 <= 16'd0;
    end
    else begin
        img_y0  <= rgb_r_m0 + rgb_g_m0 + rgb_b_m0;
        img_cb0 <= rgb_b_m1 - rgb_r_m1 - rgb_g_m1 + 16'd32768;
        img_cr0 <= rgb_r_m2 - rgb_g_m2 - rgb_b_m2 + 16'd32768;
    end

end

//step3 pipeline div
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_y1  <= 8'd0;
        img_cb1 <= 8'd0;
        img_cr1 <= 8'd0;
    end
    else begin
        img_y1  <= img_y0 [15:8];
        img_cb1 <= img_cb0[15:8];
        img_cr1 <= img_cr0[15:8];
    end
end

//延时3拍以同步数据信号
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pre_frame_vsync_d <= 3'd0;
        pre_frame_hsync_d <= 3'd0;
        pre_frame_de_d    <= 3'd0;
    end
    else begin
        pre_frame_vsync_d <= {pre_frame_vsync_d[1:0], pre_frame_vsync};
        pre_frame_hsync_d <= {pre_frame_hsync_d[1:0], pre_frame_hsync};
        pre_frame_de_d    <= {pre_frame_de_d[1:0]   , pre_frame_de   };
    end
end

endmodule
