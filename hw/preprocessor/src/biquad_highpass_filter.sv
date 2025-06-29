/************************************************************/
//              H I G H P A S S   F I L T E R               //
//                                                          //
//  Desc: 1 Hz IIR Butterworth highpass filter design       //
/************************************************************/
`timescale 1ns / 1ps

module biquad_highpass_filter(
    input   logic               clk,               
    input   logic               rst,
    input   logic               enable,            
    input   logic signed [31:0] filter_in,
    output  logic signed [31:0] filter_out
    );
    
logic signed [15:0] coeff_a1 = -16'sd16100; // Q2.13
logic signed [15:0] coeff_a2 = 16'sd7913;
logic signed [15:0] coeff_b1 = -16'sd16384;
logic signed [31:0] x_reg [2:0];
logic signed [31:0] y_reg [1:0];
logic signed [49:0] accumulator;
logic signed [47:0] shift_b0, mult_b1, shift_b2, mult_a1, mult_a2;

always_ff @(posedge clk or posedge rst) begin
    if (rst | ~enable) begin  
    x_reg[0] <= 0;        
    x_reg[1] <= 0;        
    x_reg[2] <= 0;        
    y_reg[0] <= 0;        
    y_reg[1] <= 0;        
    end else begin            
    x_reg[0] <= filter_in;     
    x_reg[1] <= x_reg[0]; 
    x_reg[2] <= x_reg[1]; 
    y_reg[0] <= filter_out;    
    y_reg[1] <= y_reg[0]; 
    end                         
end

// Multiplications and Accumulations
always_ff @(posedge clk or posedge rst) begin
    if (rst | ~enable) begin
        shift_b0 <= 0;
        mult_b1 <= 0;
        shift_b2 <= 0;
        mult_a1 <= 0;
        mult_a2 <= 0;
        accumulator <= 0;
    end else begin     
        // Feedforward multiplication 
        shift_b0 <= x_reg[0] <<< 13;
        mult_b1 <= x_reg[1] * coeff_b1;  // Q2.29 * Q2.13 -> Q4.42 
        shift_b2 <= x_reg[2] <<< 13;
        
        // Feedback multiplications
        mult_a1 <= y_reg[0] * coeff_a1;  
        mult_a2 <= y_reg[1] * coeff_a2;  

        // Accumulation: Sum the feedforward and feedback products
        accumulator = shift_b0 + mult_b1 + shift_b2 - mult_a1 - mult_a2;
    end
end     

assign filter_out = {accumulator[49], (accumulator[45:15] + accumulator[15] + accumulator[14])};
endmodule
