`timescale 1ns / 1ps
 import pack_me::*;
`default_nettype none

module sin_gen
#(div = 1)(
    input wire clk,
    input wire rst,
    output sig out
    );
    reg [div-1:0] cnt;
    
    always @(edge clk) cnt <= rst ? {div{1'b0}}: cnt + 1;
    
dds_compiler_0 dds_gen(
    .aclk(clk),
    .s_axis_phase_tvalid(1'b1),
    .s_axis_phase_tdata({cnt, {(16-div){1'b0}}}),
    .m_axis_data_tdata(out)
);
endmodule
