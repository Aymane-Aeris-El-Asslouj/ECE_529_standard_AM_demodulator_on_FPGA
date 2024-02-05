`timescale 1ns / 1ps
 import pack_me::*;
`default_nettype none

module AM #(real fac = 1)(
    input wire sig carrier_in,
    input wire sig signal_in,
    output msig signal_out
);
    msig mul;
    wire [40:0] inter;
    wire [32:0] full_range;
    msig buf_carrier_in;
    assign buf_carrier_in = carrier_in <<< 16;
    
    assign mul = (carrier_in * signal_in) <<< 1;
    assign inter = (mul * $rtoi(fac * 256)) >>> 8;
    assign full_range = ($signed(inter[31:0]) + buf_carrier_in) >>> 1;
    assign signal_out = full_range[31:0];
endmodule
