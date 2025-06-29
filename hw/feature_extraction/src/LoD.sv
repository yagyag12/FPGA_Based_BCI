/************************************************************/
//       L O W P A S S   D E C O M P   F I L T E R          //
//                                                          //
//  Desc: Lowpass Decomposition Filter for DWT              //
/************************************************************/
`timescale 1ns / 1ps

module LoD(
    input                   clk,
    input                   rst,
    input                   en,
    input   signed [31:0]   in_signal,
    output  signed [31:0]   out_signal
    );

/***********************  SIGNALS   *************************/
// Haar Coefficients
logic signed [0:15] coeffHaar [1:0] = {     // Q2.13
    16'sd5793,
    16'sd5793
};

logic signed [31:0] input_reg [0:1];        // Q2.29
logic signed [47:0] product1, product2;     // Q4.42
logic signed [51:0] accumulator;

integer i, j, k, l, m;

/***********************  FILTER   **************************/

// Input Shift Register
always_ff @(posedge clk or posedge rst) begin
    if (rst | ~en) begin
        for (i = 0; i <= 1; i = i + 1) begin
            input_reg[i] <= 0;
        end
    end else begin
        input_reg[0] <= in_signal;
        input_reg[1] <= input_reg[0];
    end
end

// Wire Assignments
assign product1     = input_reg[0] * coeffHaar[0];
assign product2     = input_reg[1] * coeffHaar[1];
assign accumulator  = product1 + product2;
assign out_signal   = {accumulator[51], accumulator[43:13]};

endmodule