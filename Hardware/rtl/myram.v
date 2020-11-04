module  myram #(
    parameter WIDTH = 1  ,               // 数据的位宽(位数)
    parameter DEPTH = 1500,               // 数据的深度(个数)
    parameter DEPBIT= 10                 // 地址的位宽
)(
    //module clock
    input                     clk  ,     // 时钟信号

    //ram interface
    input                     we   ,     //写使能
    input  [DEPBIT- 1'b1:0]   waddr,    //读地址
    input  [DEPBIT- 1'b1:0]   raddr,    //写地址
    input  [WIDTH - 1'b1:0]   dq_i ,   //数据输入
    output [WIDTH - 1'b1:0]   dq_o

    //user interface
);

//reg define
reg [WIDTH - 1'b1:0] mem [DEPTH - 1'b1:0];  //ram存放像素点的个数 2000

//*****************************************************
//**                    main code
//*****************************************************

assign dq_o = mem[raddr];    //读数据输出

always @ (posedge clk) begin
    if(we)
        mem[waddr-1] <= dq_i;  //写数据写入
end

endmodule