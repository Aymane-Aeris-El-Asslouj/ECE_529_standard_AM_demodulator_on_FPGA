`timescale 1ns / 1ps
 import pack_me::*;
`default_nettype none


module LP #(real a = 0.1)(
    input wire clk,
    input wire rst,
    input wire int_64 sig_in,
    output int_64 sig_out
    );
always @(posedge clk) begin
    sig_out <= rst ? 64'b0 : $rtoi((1-a)*sig_out + a*sig_in);
end
endmodule
