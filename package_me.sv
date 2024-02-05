package pack_me;

typedef logic signed [15:0] sig;
typedef logic signed [16:0] psig;
typedef logic signed [31:0] msig;
typedef logic signed [7:0] int_8;
typedef logic signed [15:0] int_16;
typedef logic signed [31:0] int_32;
typedef logic signed [63:0] int_64;

function sig p2(input sig a, input sig b);
    // The result can be 17 bits after addition, so we need an intermediate result
    psig intermediate_result;
    intermediate_result = a + b;
    // Return the 16 MSBs
    return intermediate_result[16:1];
  endfunction

endpackage
