`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module AM #(
    carrier_in_W = 8,
    signal_in_W = 8,
    signal_out_W = 8)(
    input wire [carrier_in_W - 1:0] carrier_in,
    input wire [signal_in_W - 1:0] signal_in,
    output wire [min(carrier_in_W+signal_in_W ,signal_out_W) - 1: 0] signal_out
    );
    
    
    assign signal_out = carrier_in * signal_in;

endmodule
