/************************************************************/
//          M O V I N G   D I F F   F I L T E R             //
//  Ver: v0.0.1                                             //
//  Desc: Moving difference highpass filter                 //
/************************************************************/
`timescale 1ns / 1ps

module moving_difference #(
    parameter WINDOW_LENGTH = 128
)(
    input                         clk,
    input                         rst,
    input                         en,
    input                         validIn,
    input         signed [31:0]   filter_in,
    output  logic                 valid,
    output  logic signed [31:0]   filter_out
);

// Signals
logic [31:0] window [0:WINDOW_LENGTH - 1];
logic [31:0] window_out;
logic [39:0] sum;
logic [39:0] average; 
logic [7:0] counter_for_valid;
integer i,j;

// Shift Register
always_ff @ (posedge clk or posedge rst) begin
    if (rst | ~en) begin
        for (i = 0; i < WINDOW_LENGTH; i = i + 1) begin
            window[i] <= 0;
        end
        window_out <= 0;
        
        valid <= 0;
        counter_for_valid <= 0;
    end
    else if (validIn) begin
        counter_for_valid <= counter_for_valid + 1;
        window[0] <= filter_in;
        window_out <= window[WINDOW_LENGTH - 1];
        window[1:WINDOW_LENGTH-1] <= window[0:WINDOW_LENGTH-2];
        
        if (counter_for_valid == 127) begin
            valid <= 1;
            counter_for_valid <= 127;
        end
    end
end

// Difference
always_ff @ (posedge clk or posedge rst) begin
    if (rst | ~en) begin
        filter_out  <= 0;
        average     <= 0;
        sum         <= 0;
    end
    else if (validIn) begin
        sum     <= $signed(sum) + $signed(filter_in) - $signed(window_out);
        average <= $signed(sum) / WINDOW_LENGTH;
        filter_out <= $signed(window[WINDOW_LENGTH - 1]) - $signed(average);
    end
end

endmodule

