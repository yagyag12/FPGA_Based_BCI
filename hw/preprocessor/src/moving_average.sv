/************************************************************/
//        M O V I N G   A V E R A G E   F I L T E R         //
//                                                          //
//  Desc: Moving average filter                             //
/************************************************************/
`timescale 1ns / 1ps

module moving_average #(
    parameter WINDOW_LENGTH = 16, // NOTE: Must be 2s order for circuit simplicity
  	parameter DATA_WIDTH    = 32 
    )(
    input                                   clk,
    input                                   rst,
    input  logic signed [DATA_WIDTH - 1:0]  data_in,
    output logic signed [DATA_WIDTH - 1:0]  filter_out
    
    );
    
    logic [DATA_WIDTH - 1:0] data_out;
    
    shiftreg #(
        .DATA_WIDTH     (DATA_WIDTH),
        .WINDOW_LENGTH  (WINDOW_LENGTH)
        ) averaging_window (
        .clk            (clk),
        .rst            (rst),
        .data_in        (data_in),
        .data_out       (data_out)
        );
    
    averager #(
        .DATA_WIDTH     (DATA_WIDTH),
        .WINDOW_LENGTH  (WINDOW_LENGTH)
        ) averager(
        .clk            (clk),
        .rst            (rst),
        .data_in        (data_in),
        .data_out       (data_out),
        .averaged_value (filter_out)
        );
        
        
endmodule
