# ARM_Top
该项目依据全国大学生集成电路创新创业大赛“ARM杯”赛题要求，在FPGA上搭建Cortex-M3软核、图像协处理器，并通过OV5640摄像头采集车牌图像，实现对车牌的识别与结果显示。项目基于Altera DE1 FPGA搭载Cortex-M3软核，依据AHB-Lite总线协议，将LCD1602、RAM、图像协处理器等外设挂载至Cortex-M3。视频采集端，设计写FiFo模块、SDRAM存储与输出、读FiFo模块、灰度处理模块、二值化、VGA显示等模块。最终将400位宽的结果数据（对应20张车牌）存储在RAM中，输出至AHB总线，由Cortex-M3调用并显示识别结果。
