module img_handle(
      //module clock
     input            clk            ,  // 时钟信号
     input            rst_n          ,  // 复位信号（低有效）
	  
     //图像处理前的数据接口
     input           pre_frame_vsync,
     input           pre_frame_hsync,
	  input           pre_frame_de   ,
	  //图像处理后的数据接口
     output          post_frame_vsync,  // 场同步信号
     output          post_frame_hsync,  // 行同步信号
	  
	  input   [15:0]   ram_data,     //像素点数据
	
	  input   [10:0]   pixel_xpos,   //像素点横坐标
     input   [10:0]   pixel_ypos ,  //像素点纵坐标    
	 
	  output  [23:0]   vga_data,   //vga数据输出
	  //user interface
    output  [19:0]  digit ,             // 识别到的数字
    output  led
);
//parameter define
parameter NUM_ROW = 1  ;               // 需识别的图像的行数
parameter NUM_COL = 7  ;               // 需识别的图像的列数
parameter H_PIXEL = 1024;              // 图像的水平像素
parameter V_PIXEL = 768;               // 图像的垂直像素
parameter DEPBIT  = 10 ;               // 数据位宽
/*目标区域参数*/
parameter target_max_x0 = 'd275;
parameter target_max_x1 = 'd825;
parameter target_max_y0 = 'd275;
parameter target_max_y1 = 'd575;

wire   [10:0]target_x0;
wire   [10:0]target_x1;
wire   [10:0]target_y0;
wire   [10:0]target_y1;

/*******二值化相关信号*******/
wire                  monoc;
wire                  monoc_fall;
wire                  monoc_raise;
/***********投影信号****************/
wire                  post_frame_de;  //图像处理完成信号
wire   [DEPBIT-1:0]   row_border_addr;
wire   [DEPBIT-1:0]   row_border_data;
wire   [DEPBIT-1:0]   col_border_addr;
wire   [DEPBIT-1:0]   col_border_data;
wire   [3:0]          num_col;
wire   [3:0]          num_row;
wire   [ 1:0]         frame_cnt;
wire                  project_done_flag;
wire                  project_done_flag_0;
wire                  project_done_flag_1;
assign                project_done_flag = project_done_flag_0&&project_done_flag_1;
/**************灰度处理和二值化**************/
wire                  hs_t0;
wire                  vs_t0;
wire                  de_t0;

wire  [7:0]           rgb888_r;
wire  [7:0]           rgb888_g;
wire  [7:0]           rgb888_b;
wire  [7:0]           img_y;
wire  [7:0]           img_cb;
wire  [7:0]           img_cr;
//PPT区域确定信号
wire  X_Y_P;
wire  XY_P;
wire  X_P;
wire  Y_P;
assign X_P= ((pixel_xpos>=target_max_x0 && pixel_xpos <=target_max_x1)&&(pixel_ypos==target_max_y0||pixel_ypos==target_max_y1)) ?1:0;
assign Y_P= ((pixel_ypos>=target_max_y0 && pixel_ypos <=target_max_y1)&&(pixel_xpos==target_max_x0||pixel_xpos==target_max_x1)) ?1:0;
assign X_Y_P =((pixel_xpos>target_max_x0 && pixel_xpos <target_max_x1)&&(pixel_ypos>target_max_y0 && pixel_ypos <target_max_y1))?1:0; //X_Y为1表示在目标区域
assign XY_P =  X_P||Y_P;
//车牌区域确定信号
wire  X_Y;
wire  XY;
wire  X;
wire  Y;
wire  target_flag;

assign X= ((pixel_xpos>=target_x0 && pixel_xpos <=target_x1)&&(pixel_ypos==target_y0||pixel_ypos==target_y1)) ?1:0;
assign Y= ((pixel_ypos>=target_y0 && pixel_ypos <=target_y1)&&(pixel_xpos==target_x0||pixel_xpos==target_x1)) ?1:0;
assign X_Y =((pixel_xpos>target_x0 && pixel_xpos <target_x1)&&(pixel_ypos>target_y0 && pixel_ypos <target_y1))?1:0; //X_Y为1表示在目标区域
assign XY =  X||Y;

assign  rgb888_b={ram_data[4:0],ram_data[4:2]};
assign  rgb888_g={ram_data[10:5],ram_data[10:9]};
assign  rgb888_r={ram_data[15:11],ram_data[15:13]};
//灰度图像输出
//assign  vga_data={img_y[7:0],img_y[7:0],img_y[7:0]};

//二值化图像输出
//assign   vga_data=(post_frame_de &&(!monoc))?{8'd255,8'd255,8'd255}:24'd0;
//assign  vga_data=(XY)?{8'd0,8'd255,8'd0}:{color_out[7:0],color_out[7:0],color_out[7:0]};
/***********灰度处理*************/
/*
always@(*)
begin
   if(XY_P)
	 vga_data <={8'd0,8'd0,8'd255};
	else if(XY)
	  vga_data <={8'd0,8'd255,8'd0};
	else
     vga_data <={color_out[7:0],color_out[7:0],color_out[7:0]};
end
*/
Gray  u0(

   .clk(clk),
	.rst_n(rst_n),
   //图像处理前的数据接口
   .pre_frame_vsync (pre_frame_vsync),    // vsync信号
   .pre_frame_hsync (pre_frame_hsync),    // href信号
	.pre_frame_de(pre_frame_de),          //处理之前的数据使能
	//图像处理后的数据接口
   .post_frame_vsync(vs_t0),   // vsync信号
   .post_frame_hsync(hs_t0),  // href信号
	.post_frame_de(de_t0),     //处理之后的数据使能
	
	
	.ram_data(ram_data),   	//像素点数据
	
	.img_y(img_y),
	.img_cb(img_cb),
   .img_cr(img_cr)
);
wire [7:0]  color_out;
/**********二值化处理***************/
Image_Binarization u(
     .clk(clk),
	  .rst_n(rst_n),
	  //处理前的数据
	  .pre_frame_vsync    (vs_t0),            // vsync信号
     .pre_frame_hsync    (hs_t0),            // href信号
	  .pre_frame_de(de_t0),//二值化处理之前的使能信号
	  
	  //处理后的数据
	  .post_frame_vsync   (post_frame_vsync), // vsync信号
     .post_frame_hsync   (post_frame_hsync), // href信号
	  .post_frame_de      (post_frame_de),    //二值化完成数据输出使能
	  
	  .color(img_y),//灰度图像处理
	  .monoc(monoc),// 单色图像像素数据
     .monoc_fall(monoc_fall),
	  .monoc_raise(monoc_raise),
	  .color_out(color_out)

);
target u1(
     .clk(clk),
	  .rst_n(rst_n),
	  
	  .pre_frame_vsync(post_frame_vsync),
	  .pre_frame_hsync(post_frame_hsync),
	  .pre_frame_de(post_frame_de),
	  
	  .gray_b(color_out),
	  .xpos(pixel_xpos),
	  .ypos(pixel_ypos),
	  .X_Y_P(X_Y_P),
	  .save_x_st(target_x0),
	  .save_y_st(target_y0),
	  .save_x_end(target_x1),
	  .save_y_end(target_y1),
	  .project_done_flag(project_done_flag_0)
	  


);

//投影模块
projection #(
    .NUM_ROW(NUM_ROW),
    .NUM_COL(NUM_COL),
    .H_PIXEL(H_PIXEL),
    .V_PIXEL(V_PIXEL),
    .DEPBIT (DEPBIT)
) u_projection(
    //module clock
    .clk                (clk    ),          // 时钟信号
    .rst_n              (rst_n  ),          // 复位信号（低有效）
    //Image data interface
	 .X_Y                (X_Y),              //目标区域               
    .frame_vsync        (post_frame_vsync), // vsync信号
    .frame_hsync        (post_frame_hsync), // href信号
    .frame_de           (post_frame_de ),   // data enable信号
    .monoc              (monoc           ), // 单色图像像素数据
    .ypos               (pixel_ypos),
    .xpos               (pixel_xpos),
    //project border ram interface
    .row_border_addr_rd (row_border_addr),
    .row_border_data_rd (row_border_data),
    .col_border_addr_rd (col_border_addr),
    .col_border_data_rd (col_border_data),
    //user interface
    .num_col            (num_col),
    .num_row            (num_row),
    .frame_cnt          (frame_cnt),
    .project_done_flag  (project_done_flag_1)
);

//数值特征识别模块
digital_re #(
    .NUM_ROW(NUM_ROW),
    .NUM_COL(NUM_COL),
    .H_PIXEL(H_PIXEL),
    .V_PIXEL(V_PIXEL),
    .NUM_WIDTH((NUM_ROW*NUM_COL<<2)-1)
)u_digital_recognition(
    //module clock
    .clk                (clk       ),        // 时钟信号
    .rst_n              (rst_n     ),        // 复位信号（低有效）
    //image data interface
	 .frame_de           (post_frame_de ),   // data enable信号
    .monoc              (monoc     ),
    .monoc_fall         (monoc_fall),
	 .monoc_raise        (monoc_raise),
    .color_rgb          (vga_data  ),  
    	 
    .xpos               (pixel_ypos ),
    .ypos               (pixel_xpos ),
	 .ram_data_r         (rgb888_r),
	 .ram_data_g         (rgb888_g),
	 .ram_data_b         (rgb888_b),
	 .XY                 (XY),
	 .XY_P               (XY_P),
    //project border ram interface
    .row_border_addr    (row_border_addr),
    .row_border_data    (row_border_data),
    .col_border_addr    (col_border_addr),
    .col_border_data    (col_border_data),
    .num_col            (num_col),
    .num_row            (num_row),
    //user interface
    .frame_cnt          (frame_cnt),
    .project_done_flag  (project_done_flag),
    .digit              (digit),
	 .led                (led)
);




endmodule 