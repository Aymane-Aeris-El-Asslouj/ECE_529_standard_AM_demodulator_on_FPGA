module converter (
    input wire clk_pin,
    input wire reset_pin,
    input wire [15:0] binary_input,
    output wire [7:0] dispC,
    output wire [7:0] dispAN
);

wire [7:0] seg_out_1; // 7-segment outputs for the least significant digit
wire [7:0] seg_out_2;
wire [7:0] seg_out_3;
wire [7:0] seg_out_4;
wire [7:0] seg_out_5;

assign dispC = {CA, CB, CC, CD, CE, CF, CG, DP};
assign dispAN = {AN0, AN1, AN2, AN3, AN4, AN5, AN6, AN7};

reg CA, CB, CC, CD, CE, CF, CG, DP;
reg AN0, AN1, AN2, AN3, AN4, AN5, AN6, AN7;

// 1. Binary to BCD conversion logic (e.g., using Double dabble)

    integer i = 0;

    reg [35:0] shift_register; // 16 bits for binary input + 20 bits for BCD digits
    reg [19:0] bcd_output;

    always @(binary_input) begin
        shift_register = 20'b0 << 16 | binary_input; // Initialize with BCD part as 0 and binary part as input
    
        for (i = 0; i < 16; i = i+1) begin
            // Check each BCD digit, if it's 5 or above, add 3
            if (shift_register[19:16] >= 5) shift_register[19:16] = shift_register[19:16] + 3;
            if (shift_register[23:20] >= 5) shift_register[23:20] = shift_register[23:20] + 3;
            if (shift_register[27:24] >= 5) shift_register[27:24] = shift_register[27:24] + 3;
            if (shift_register[31:28] >= 5) shift_register[31:28] = shift_register[31:28] + 3;
            if (shift_register[35:32] >= 5) shift_register[35:32] = shift_register[35:32] + 3;
            // Shift left
            shift_register = shift_register << 1;
        end
    
        bcd_output = shift_register[35:16]; // Extract the BCD part after all shifts
    end

// 2. BCD to 7-segment decoding logic for each digit

assign seg_out_1 = decode_7segment(bcd_output[3:0]);
assign seg_out_2 = decode_7segment(bcd_output[7:4]);
assign seg_out_3 = decode_7segment(bcd_output[11:8]);
assign seg_out_4 = decode_7segment(bcd_output[15:12]);

function [7:0] decode_7segment;
    input [3:0] bcd_digit;
    begin
        case (bcd_digit)
            4'b0000: decode_7segment = 8'b00000011; // 0
            4'b0001: decode_7segment = 8'b10011111; // 1
            4'b0010: decode_7segment = 8'b00100101; // 2
            4'b0011: decode_7segment = 8'b00001101; // 3
            4'b0100: decode_7segment = 8'b10011001; // 4
            4'b0101: decode_7segment = 8'b01001001; // 5 
            4'b0110: decode_7segment = 8'b01000001; // 6
            4'b0111: decode_7segment = 8'b00011111; // 7
            4'b1000: decode_7segment = 8'b00000001; // 8
            4'b1001: decode_7segment = 8'b00001001; // 9
            default: decode_7segment = 8'b00000001; // Blank or error
        endcase
    end
endfunction
    
    
reg [31:0] digit_counter;
    always @(posedge clk_pin) begin
    if (reset_pin) begin
        {CA, CB, CC, CD, CE, CF, CG, DP} <= 8'b0;
        {AN0, AN1, AN2, AN3, AN4, AN5, AN6, AN7} <= 8'b11111111;
        digit_counter <= 32'b0;
    end
    else begin
        digit_counter <= digit_counter + 1;
        case(digit_counter)
            32'd10000: begin {CA, CB, CC, CD, CE, CF, CG, DP} <= seg_out_1; AN0 <= 1'b0; AN4 <= 1'b1; end
            32'd20000: begin {CA, CB, CC, CD, CE, CF, CG, DP} <= seg_out_2; AN1 <= 1'b0; AN0 <= 1'b1; end
            32'd30000: begin {CA, CB, CC, CD, CE, CF, CG, DP} <= seg_out_3; AN2 <= 1'b0; AN1 <= 1'b1; end
            32'd40000: begin {CA, CB, CC, CD, CE, CF, CG, DP} <= seg_out_4; AN3 <= 1'b0; AN2 <= 1'b1; end
            32'd50000: begin {CA, CB, CC, CD, CE, CF, CG, DP} <= 8'b00000010; AN4 <= 1'b0; AN3 <= 1'b1; end
            32'd60000: digit_counter <= 32'b0;
        endcase
    end
end

    
endmodule