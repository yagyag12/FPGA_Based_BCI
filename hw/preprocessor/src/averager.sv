/************************************************************/
//              A V E R A G E R   M O D U L E               //
//                                                          //
//  Desc: Averager of the moving average filter             //
/************************************************************/
`timescale 1ns / 1ps

module averager #(
  	parameter WINDOW_LENGTH = 16, // NOTE: Must be 2s order for circuit simplicity
  	parameter DATA_WIDTH    = 32
)(
    input                                   clk, 
    input                                   rst,
    input  logic signed [DATA_WIDTH - 1:0]  data_in,
    input  logic signed [DATA_WIDTH - 1:0]  data_out,
    output logic signed [DATA_WIDTH - 1:0]  averaged_value
);
  
  integer i;
  logic signed [DATA_WIDTH + $clog2(WINDOW_LENGTH):0] sum;
  
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        averaged_value <= {DATA_WIDTH{1'b0}};
        sum <= {DATA_WIDTH + $clog2(WINDOW_LENGTH){1'b0}};
    end else begin
        sum <= sum + data_in - data_out;
        averaged_value <= sum / WINDOW_LENGTH;
    end
  end
  
endmodule