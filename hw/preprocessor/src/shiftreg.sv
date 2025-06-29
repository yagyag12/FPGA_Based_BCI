/************************************************************/
//         S H I F T   R E G I S T E R   M O D U L E        //
//                                                          //
//  Desc: Window of the moving average filter               //
/************************************************************/
`timescale 1ns / 1ps

module shiftreg #(
  	parameter WINDOW_LENGTH = 16, // NOTE: Must be 2s order for circuit simplicity
  	parameter DATA_WIDTH    = 32 
)(
  	input                                   clk, 
    input                                   rst,
    input  logic signed [DATA_WIDTH - 1:0]  data_in,
    output logic signed [DATA_WIDTH - 1:0]  data_out
  );
  
    logic signed [DATA_WIDTH - 1:0] cells [0:WINDOW_LENGTH - 1];
  	integer i;
    
  // Sequential Procedural Block for Shifting
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset
      for (i = 0; i < WINDOW_LENGTH; i = i + 1) begin
        cells[i] <= {DATA_WIDTH{1'b0}};
      end
      data_out <= {DATA_WIDTH{1'b0}};
    end else begin
      // Shifting Cells
      data_out <= cells[WINDOW_LENGTH - 1];
      for (i = 0; i < WINDOW_LENGTH; i = i + 1) begin
        cells[i] <= cells[i-1];
      end
      cells[0] <= data_in;
    end
  end
endmodule