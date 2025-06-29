/************************************************************/
//          A D C   S A M P L E R   M O D U L E             //
//                                                          //
//  Desc: Creates a sampling clock and samples the input    //
/************************************************************/
`timescale 1ns / 1ps

module adc_sampler #(
    parameter CLK_FREQ      =   100000000,          // Input Clock Frequency (Hz)
    parameter TARGET_FREQ   =   256                 // Output Sampling Frequency (Hz)
    )(
    input                   clk,
    input                   rst,
    input           [31:0]  adc_in,
    output   logic  [31:0]  sample_out,
    output                  sample_clk
    );

/***********************  SIGNALS  **************************/

localparam COUNTER_VAL  =   CLK_FREQ / TARGET_FREQ;
logic   [$clog2(COUNTER_VAL)-1:0]   counter;
logic                               sample_clk_reg;

/***********************  SAMPLER  **************************/
    
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        sample_out  <=  0;
        counter     <=  0;
        sample_clk_reg <= 0;
    end
    else begin
        counter     <=  counter + 1; 
        if (counter < COUNTER_VAL / 2) begin
            sample_clk_reg <= 1;
        end else begin
            sample_clk_reg <= 0;
        end
        if (counter == COUNTER_VAL - 1) begin
            counter     <=  0;
            sample_out  <=  adc_in; 
        end
    end
end

assign sample_clk = sample_clk_reg;
    
endmodule
