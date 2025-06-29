/************************************************************/
//       D W T   F E A T U R E   E X T R A C T O R          //
//                                                          //
//  Desc: Extracts features from the DWT coefficients       //
/************************************************************/
`timescale 1ns / 1ps

module dwt_extractor #(
    parameter LENGTH = 64       // Max coefficients size
)(
    input                   clk,
    input                   rst,
    input                   en,
    input           [31:0]  coeff_in,
    output  logic           valid,
    output  signed  [31:0]  max,
    output  signed  [31:0]  min,
    output  signed  [31:0]  mean,
    output  signed  [31:0]  sum
    );

/***********************  SIGNALS   *************************/

logic           [$clog2(LENGTH) - 1: 0] counter;
logic   signed  [31:0]                  abs_data;
logic   signed  [31 + $clog2(LENGTH):0] abs_acc;        // Absolute Accumulator
logic   signed  [31 + $clog2(LENGTH):0] mean_acc;       // Mean Accumulator
logic   signed  [31:0]                  current_max;
logic   signed  [31:0]                  current_min;
logic           [31:0]                  prev_in;

/*****************  FEATURE EXTRACTION  *********************/

// Absolute Value Calculation
always_comb begin
    if (coeff_in[31] == 0) begin        // Positive Input
        abs_data = coeff_in;
    end
    else begin                          // Negative Input
        abs_data = ~coeff_in + 1;
    end
end

// Feature Calculations
always_ff @(posedge clk or posedge rst) begin
    if (rst | ~en) begin
        abs_acc     <= 0;
        current_max <= 0;
        current_min <= 0;
        mean_acc    <= 0;
        counter     <= 0;
        valid       <= 0;
    end
    else begin
        if (prev_in != coeff_in) begin
            if (counter == LENGTH - 1) begin
                valid   <=  1;
                counter <= LENGTH - 1;
            end
            else begin
                counter     <=  counter + 1;                                        
                current_max <=  ($signed(coeff_in) > $signed(current_max)) ? coeff_in : current_max;
                current_min <=  ($signed(coeff_in) < $signed(current_min)) ? coeff_in : current_min;
                abs_acc     <=  abs_acc  + abs_data;
                mean_acc    <=  $signed(mean_acc) + $signed(coeff_in); 
            end
        end
        prev_in <= coeff_in;
    end
end

// Output Assignments
assign mean = valid ? mean_acc[31 + $clog2(LENGTH):$clog2(LENGTH)]  : 0;
assign sum  = valid ? abs_acc [31 + $clog2(LENGTH):$clog2(LENGTH)]  : 0; 
assign max  = valid ? current_max                                   : 0;
assign min  = valid ? current_min                                   : 0;
endmodule
