/************************************************************/
//         B I Q U A D   N O T C H   F I L T E R            //
//                                                          //
//  Desc: 50 Hz IIR Butterworth notch filter design         //
/************************************************************/
`timescale 1ns / 1ps

module biquad_notch_filter(
    input   logic               clk,               
    input   logic               rst,
    input   logic               enable,            
    input   logic signed [31:0] filter_in,
    output  logic               valid,
    output  logic signed [31:0] filter_out
    );
    
    logic signed [15:0] coeff_a1 = -16'sd10778; //Q1.14
    logic signed [15:0] coeff_a2 = 16'sd15599;
    logic signed [15:0] coeff_b1 = -16'sd11043;
    logic signed [31:0] x_reg [2:0];
    logic signed [31:0] y_reg [1:0];
    logic signed [49:0] accumulator;
    logic signed [47:0] shift_b0, mult_b1, shift_b2, mult_a1, mult_a2;
    logic [2:0] counter_for_valid;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst | ~enable) begin  
        x_reg[0]            <= 0;        
        x_reg[1]            <= 0;        
        x_reg[2]            <= 0;        
        y_reg[0]            <= 0;        
        y_reg[1]            <= 0;
        
        counter_for_valid   <= 0;
        valid               <= 0;        
        end else begin          
        counter_for_valid   <= counter_for_valid + 1;   
        x_reg[0] <= filter_in;     
        x_reg[1] <= x_reg[0]; 
        x_reg[2] <= x_reg[1]; 
        y_reg[0] <= filter_out;    
        y_reg[1] <= y_reg[0]; 
        
        if (counter_for_valid == 7) begin
            valid <= 1;
            counter_for_valid   <= 7;
        end
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
            shift_b0 <= x_reg[0] <<< 14;
            mult_b1 <= x_reg[1] * coeff_b1;  // Q2.29 * Q1.14 -> Q3.43 
            shift_b2 <= x_reg[2] <<< 14;
            
            // Feedback multiplications
            mult_a1 <= y_reg[0] * coeff_a1;  // Q2.29 * Q1.14 -> Q3.43
            mult_a2 <= y_reg[1] * coeff_a2;  // Q2.29 * Q1.14 -> Q3.43

            // Accumulation: Sum the feedforward and feedback products
            accumulator = shift_b0 + mult_b1 + shift_b2 - mult_a1 - mult_a2;
        end
    end     
    
    assign filter_out = {accumulator[49], (accumulator[45:15] + accumulator[14] + accumulator[15])};

endmodule

