`timescale 1ns / 1ps
 import pack_me::*;
`default_nettype none

module top(
    input wire clk_pin,
    input wire reset_pin,
    input wire user_pulse,
    input wire vp3_pin, vn3_pin,
    input wire vp_in, vn_in,
    output reg led_0_pin, led_1_pin, led_2_pin, led_3_pin,
    output wire [7:0] dispC,
    output wire [7:0] dispAN,
    
    output wire dds_valid,
    output wire [15:0] dds_out,
    output reg [7:0] modulating_signal,
    output msig AM_mod,
    output sig mod, mod_1, mod_2
);
    
    wire drdy;
    wire [15:0] do_it;
    
    reg [31:0] debounce_counter;
    
    reg convst;
    
always @(posedge clk_pin) begin
    if (reset_pin) begin
        {led_0_pin, led_1_pin, led_2_pin, led_3_pin} <= 4'b0;
        debounce_counter <= 32'b0;
    end
    else begin
        if (debounce_counter == 32'd0) begin
            if (user_pulse) begin
                convst <= 1'b1;
                debounce_counter <= 32'd1;
            end
        end
        else begin
           debounce_counter <= debounce_counter + 32'd1;
        end
        
        if (debounce_counter == 32'd5) begin
            convst <= 1'b0;
        end
        else if (debounce_counter == 32'd200000) begin
            debounce_counter <= 32'd0;
        end
    
    
        if (drdy) begin
            {led_0_pin, led_1_pin, led_2_pin, led_3_pin} <= 4'b0;
            case (do_it[15:14])
                2'b00: led_0_pin <= 1'b1;
                2'b01: led_1_pin <= 1'b1;
                2'b10: led_2_pin <= 1'b1;
                2'b11: led_3_pin <= 1'b1;
            endcase
        end
    end
    
    end
    
    
xadc_wiz_0_exdes dut (
     .dclk_in(~clk_pin),/**********/
     .do_out(do_it),
     .drdy_out(drdy),
     .reset_in(reset_pin),/**********/
     .convst_in(convst),/**********/
     .vauxp3(vp3_pin),/**********/
     .vauxn3(vn3_pin),/**********/
     .vp_in(vp_in),
     .vn_in(vn_in)
);

wire [16:0] do_scaled;
assign do_scaled = (do_it * 10000) >>> 16;

converter disp7(
    .clk_pin(clk_pin),
    .reset_pin(reset_pin),
    .binary_input(do_scaled),
    .dispC(dispC),
    .dispAN(dispAN)
);

reg [15:0] dds_input;
reg [4:0] buffer_in;

always @(posedge clk_pin) begin
    if (reset_pin) begin
        dds_input <= 16'b0;
        modulating_signal <= 8'b0;
        buffer_in <= 5'b0;
    end
    else begin
        dds_input <= dds_input + 16'b100000 + modulating_signal[7:1];
        buffer_in <= buffer_in + 5'b1;
        if (dds_input == 16'hFFFF) begin
            dds_input <= 16'b0;
        end
        if (modulating_signal == 8'hFF) begin
            modulating_signal <= 8'b0;
        end
        if (buffer_in == 5'h1F) begin
            modulating_signal <= modulating_signal + 8'b1;
            buffer_in <= 5'b0;
        end
    end
end

dds_compiler_0 dds_test(
    .aclk(clk_pin),
    .s_axis_phase_tvalid(1'b1),
    .s_axis_phase_tdata(dds_input),
    .m_axis_data_tvalid(dds_valid),
    .m_axis_data_tdata(dds_out)
);

sig sin_0, sin_3, sin_5;

sin_gen #(.div(5)) sin_gen_top_1(
    .clk(clk_pin),
    .rst(reset_pin),
    .out(sin_0)
);

sin_gen #(.div(7)) sin_gen_top_2(
    .clk(clk_pin),
    .rst(reset_pin),
    .out(sin_3)
);

sin_gen #(.div(11)) sin_gen_top_3 (
    .clk(clk_pin),
    .rst(reset_pin),
    .out(sin_5)
);

assign mod_2 = sin_5;

psig modulating_inside;
assign modulating_inside = (sin_5 + sin_3 )>> 1;
assign mod_1 = modulating_inside;

int_32 AM_mod_in;

assign AM_mod = AM_mod_in;

AM #(.fac(0.8)) AM_top(
    .carrier_in(sin_0),
    .signal_in(modulating_inside[15:0]),
    .signal_out(AM_mod_in)
);

int_16 AM_demod;
int_32 AM_mod_abs;
int_64 AM_ENV, AM_LP, AM_HP;
int_32 AM_ENV_red, AM_LP_red, AM_HP_red;
assign AM_ENV_red = AM_ENV[31:0];
assign AM_LP_red = AM_LP[31:0];
assign AM_HP_red = AM_HP[31:0];

int_16 coeff;

assign AM_mod_abs = (AM_mod_in < 0) ? - AM_mod_in : AM_mod_in;

LP LP1(clk_pin, reset_pin, AM_ENV, AM_LP);
HP HP1(clk_pin, reset_pin, AM_LP, AM_HP);

always @(posedge clk_pin) begin
    AM_ENV = (reset_pin) ? 64'b0 : ((AM_ENV < AM_mod_abs)? AM_mod_abs: $rtoi(AM_ENV*0.98));
    
    AM_demod = (AM_HP*10) >>> 18  ;
end




endmodule
