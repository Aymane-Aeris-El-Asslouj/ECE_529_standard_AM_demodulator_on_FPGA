`timescale 1ns / 1ps
 import pack_me::*;
`default_nettype none


module HP(
    input wire clk,
    input wire rst,
    input wire int_64 sig_in,
    output int_64 sig_out
    );
int_64 pre_sig_out, pre_sig_in;
always @(posedge clk) begin
    pre_sig_out = rst ? 64'b0 : sig_out;
    sig_out = (sig_in*1024 - pre_sig_in*1024 + pre_sig_out*1023) >>> 10;
    pre_sig_in = rst ? 64'b0 : sig_in;
end
endmodule
