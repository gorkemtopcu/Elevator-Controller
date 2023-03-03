`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2023 06:37:31 PM
// Design Name: 
// Module Name: top_module_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module_tb;
// Inputs
reg rst;
reg clk;
reg floor_0_p,floor_1_p,floor_2_p,floor_3_p,floor_4_p;
reg floor_0_d,floor_1_d,floor_2_d,floor_3_d,floor_4_d;
reg direction_1,direction_2,direction_3;

// Outputs
wire led_outside_0,led_outside_1,led_outside_2,led_outside_3,led_outside_4;
wire led_inside_0,led_inside_1,led_inside_2,led_inside_3,led_inside_4;
wire led_busy;
wire a,b,c,d,e,f,g,p;
wire [7:0] an;


//    input clk,
//    rst,
    
//    floor_0_p,
//    floor_1_p,
//    floor_2_p,
//    floor_3_p,
//    floor_4_p,
    
//    direction_1,
//    direction_2,
//    direction_3,
    
//    floor_0_d,
//    floor_1_d,
//    floor_2_d,
//    floor_3_d,
//    floor_4_d,
    
//    output led_inside_0,
//    led_inside_1,
//    led_inside_2,
//    led_inside_3,
//    led_inside_4,
    
//    led_outside_0,
//    led_outside_1,
//    led_outside_2,
//    led_outside_3,
//    led_outside_4,

//    led_busy,
    
//    a_out,b_out,c_out,d_out,e_out,f_out,g_out,p_out,
//    [7:0]an

top_module dut(
.rst(rst),
.clk(clk),
.floor_0_p(floor_0_p),
.floor_1_p(floor_1_p),
.floor_2_p(floor_2_p),
.floor_3_p(floor_3_p),
.floor_4_p(floor_4_p),
.floor_0_d(floor_0_d),
.floor_1_d(floor_1_d),
.floor_2_d(floor_2_d),
.floor_3_d(floor_3_d),
.floor_4_d(floor_4_d),
.direction_1(direction_1),
.direction_2(direction_2),
.direction_3(direction_3),
.led_outside_0(led_outside_0),
.led_outside_1(led_outside_1),
.led_outside_2(led_outside_2),
.led_outside_3(led_outside_3),
.led_outside_4(led_outside_4),
.led_inside_0(led_inside_0),
.led_inside_1(led_inside_1),
.led_inside_2(led_inside_2),
.led_inside_3(led_inside_3),
.led_inside_4(led_inside_4),
.led_busy(led_busy),
.a_out(a),
.b_out(b),
.c_out(c),
.d_out(d),
.e_out(e),
.f_out(f),
.g_out(g),
.p_out(p),
.an(an)
);

// Initialize input values
initial begin
    rst = 1'b1;
    clk = 1'b0;
    floor_0_p = 1'b0;
    floor_1_p = 1'b0;
    floor_2_p = 1'b0;
    floor_3_p = 1'b0;
    floor_4_p = 1'b0;
    floor_0_d = 1'b0;
    floor_1_d = 1'b0;
    floor_2_d = 1'b0;
    floor_3_d = 1'b0;
    floor_4_d = 1'b0;
    direction_1 = 1'b0;
    direction_2 = 1'b0;
    direction_3 = 1'b0;
end

// Clock generator
always #5 clk = ~clk;

// Test case 1 - reset
initial begin
    #10 rst = 1'b0;
    #10 rst = 1'b1;
    
    #5 
    floor_4_p = 1;
    #5
    floor_4_p = 0;
//    #15
//    direction_3 = 1;
//    #1
//    floor_3_p = 1;
//    #5
//    floor_3_p = 0;
//    direction_3 = 0;
//    #500
//    floor_1_d = 1;
//    #10
//    floor_1_d = 0;
end

endmodule
