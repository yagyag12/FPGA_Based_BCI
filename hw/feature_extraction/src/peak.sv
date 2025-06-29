/************************************************************/
//          P E A K   F I N D E R   M O D U L E             //
//                                                          //
//  Desc: Finds the absolute peak value of the epoch        //
/************************************************************/
`timescale 1ns / 1ps

module peak #(
    parameter EPOCH_LENGTH = 256
)(
    input                           clk,
    input                           rst,
    input                           en,
    input           signed  [31:0]  data_in,
    output  logic   signed  [31:0]  peak_value,
    output  logic                   peak_valid
    );

/***********************  SIGNALS   *************************/
    
logic   signed  [31:0]  current_peak;
logic           [ 7:0]  counter;
logic   signed  [31:0]  abs_data;

/*********************  PEAK FINDER  ************************/

// Absolute Value Calculation
always_comb begin
    if (data_in[31] == 0) begin     // Positive Input
        abs_data = data_in;
    end
    else begin                      // Negative Input
        abs_data = ~data_in + 1;
    end
end

// Comparator Shift Register
always_ff @(posedge clk or posedge rst) begin
    if (rst | ~en) begin
        current_peak    <= 0;
        peak_value      <= 0;
        peak_valid      <= 0;
        counter         <= 0;
    end
    else begin
        counter         <= counter + 1;
        current_peak    <= (abs_data > current_peak) ? abs_data : current_peak;
        if (counter == EPOCH_LENGTH - 1) begin
            peak_valid  <= 1;
            counter     <= EPOCH_LENGTH - 1;
            peak_value  <= current_peak;
        end
    end 
end

endmodule
