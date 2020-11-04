module arm_TOP(
					input                 sys_clk     ,  //系统时钟
					input                 sys_rst_n   ,  //系统复位，低电平有效
					input                 en          ,
					//摄像头接口
					input                 cam_pclk    ,  //cmos 数据像素时钟
					input                 cam_vsync   ,  //cmos 场同步信号
					input                 cam_href    ,  //cmos 行同步信号
					input        [7:0]    cam_data    ,  //cmos 数据  
					output                cam_rst_n   ,  //cmos 复位信号，低电平有效
					output                cam_pwdn    ,  //cmos 电源休眠模式选择信号
					output                cam_scl     ,  //cmos SCCB_SCL线
					inout                 cam_sda     ,  //cmos SCCB_SDA线
					//SDRAM接口
					output                sdram_clk   ,  //SDRAM 时钟
					output                sdram_cke   ,  //SDRAM 时钟有效
					output                sdram_cs_n  ,  //SDRAM 片选
					output                sdram_ras_n ,  //SDRAM 行有效
					output                sdram_cas_n ,  //SDRAM 列有效
					output                sdram_we_n  ,  //SDRAM 写有效
					output       [1:0]    sdram_ba    ,  //SDRAM Bank地址
					output       [1:0]    sdram_dqm   ,  //SDRAM 数据掩码
					output       [12:0]   sdram_addr  ,  //SDRAM 地址
					inout        [15:0]   sdram_data  ,  //SDRAM 数据    
					//VGA接口  	 
					output                vga_hs      ,  //行同步信号
					output                vga_vs      ,  //场同步信号
					output        [23:0]  vga_rgb     ,  //红绿蓝三原色输出 
					output                vga_clk     ,   //输出给vga   
					
					//数码管接口
					output    [6:0]     DIG0   ,        
					output    [6:0]     DIG1   , 
					output    [6:0]     DIG2   , 
					output    [6:0]     DIG3   , 
					output    [6:0]     DIG4   , 
					//output    [6:0]     DIG5   ,
					output    			  led		,
					output              done   ,
					
					
					//LCD显示
					input 					key_in,//一副画面使能信号
					
					output 					LCD1602_RS,
					output 					LCD1602_RW,
					output 	 wire [7:0]	LCD1602_DB,
					output 					LCD1602_E,
					output 					LCD1602_VL,
					
					//JTAG
					input  wire          TDI		,                  // JTAG TDI
					input  wire          TCK		,                  // SWD Clk / JTAG TCK
					inout  wire          TMS		,                  // SWD I/O / JTAG TMS
					output wire          TDO		,                  // SWV     / JTAG TDO

					output wire [7:0]		LED		,
					input wire [7:0]		BUTTON	
					
						);
						
wire [399:0] result;

ARM_SOC ARM_SOC0 (
		.CLK		(sys_clk),                  // Oscillator
		.RESET	(sys_rst_n),                // Reset
		
		
		.TDI		(TDI),                  // JTAG TDI
		.TCK		(TCK),                  // SWD Clk / JTAG TCK
		.TMS		(TMS),                  // SWD I/O / JTAG TMS
		.TDO		(TDO),                  // SWV     / JTAG TDO
		
		.LED		(LED),
		.BUTTON	(BUTTON)
   );
	

lcd1602_test lcd1602_test0(
	.Clk				(sys_clk),
	.Rst_n			(sys_rst_n),
	.key_in			(key_in),
	.result			(result),
	.done				(done),
	
	.LCD1602_RS		(LCD1602_RS),
	.LCD1602_RW		(LCD1602_RW),
	.LCD1602_DB		(LCD1602_DB),
	.LCD1602_E		(LCD1602_E),
	.LCD1602_VL		(LCD1602_VL)
);	
						
						
ov5640_rgb565_1024x768_vga ov5640_rgb565_1024x768_vga0(    
	.sys_clk     (sys_clk),  //系统时钟
	.sys_rst_n   (sys_rst_n),  //系统复位，低电平有效
	//摄像头接口
	.cam_pclk    (cam_pclk),  //cmos 数据像素时钟
	.cam_vsync   (cam_vsync),  //cmos 场同步信号
	.cam_href    (cam_href),  //cmos 行同步信号
	.cam_data    (cam_data),  //cmos 数据  
	.cam_rst_n   (cam_rst_n),  //cmos 复位信号，低电平有效
	.cam_pwdn    (cam_pwdn),  //cmos 电源休眠模式选择信号
	.cam_scl     (cam_scl),  //cmos SCCB_SCL线
	.cam_sda     (cam_sda),  //cmos SCCB_SDA线
	//SDRAM接口
	.sdram_clk   (sdram_clk),  //SDRAM 时钟
	.sdram_cke   (sdram_cke),  //SDRAM 时钟有效
	.sdram_cs_n  (sdram_cs_n),  //SDRAM 片选
	.sdram_ras_n (sdram_ras_n),  //SDRAM 行有效
	.sdram_cas_n (sdram_cas_n),  //SDRAM 列有效
	.sdram_we_n  (sdram_we_n),  //SDRAM 写有效
	.sdram_ba    (sdram_ba),  //SDRAM Bank地址
	.sdram_dqm   (sdram_dqm),  //SDRAM 数据掩码
	.sdram_addr  (sdram_addr),  //SDRAM 地址
	.sdram_data  (sdram_data),  //SDRAM 数据    
	//VGA接口  	 
	.vga_hs      (vga_hs),  //行同步信号
	.vga_vs      (vga_vs),  //场同步信号
	.vga_rgb     (vga_rgb),  //红绿蓝三原色输出 
	.vga_clk     (vga_clk),   //输出给vga   
	//数码管接口
	.DIG0   		(DIG0),        
	.DIG1   		(DIG1), 
	.DIG2   		(DIG2), 
	.DIG3   		(DIG3), 
	.DIG4   		(DIG4), 
	//.DIG5   		(DIG5),
	.led			(led),
	//.en         (en),
	.done			(done),
	.result		(result)
    );
endmodule 