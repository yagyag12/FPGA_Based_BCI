/************************************************************/
//          Z E R O   C R O S S I N G   R A T E             //
//                                                          //
//  Desc: Calculates the zero crossing rate of a certain    //
//        epoch                                             //
/************************************************************/
`timescale 1ns / 1ps

module zcr #(
    parameter EPOCH_LENGTH = 256        // Epoch Length
    )(
        input                                   rst,
        input                                   clk,
        input                                   en,
        input                                   signal_sign,
        output logic [$clog2(EPOCH_LENGTH)-1:0] zero_counter,
        output logic valid
    );
    
/***********************  SIGNALS   *************************/
    logic signed                        prev_sign;
    logic [$clog2(EPOCH_LENGTH)-1:0]    epoch_counter;

/*********************  ZCR COUNTER   ***********************/
    
always_ff @(posedge clk, posedge rst) begin
    if (rst | ~en) begin
        prev_sign       <= 0;
        epoch_counter   <= 0;
        zero_counter    <= 0;
        valid           <= 0;
    end 
    else begin
        if ((epoch_counter >= 1) && (prev_sign != signal_sign)) begin
            zero_counter <= zero_counter + 1;
        end

        if (epoch_counter == EPOCH_LENGTH-1) begin
            epoch_counter   <= 0;
            valid           <= 1;
        end

        prev_sign       <= signal_sign;
        epoch_counter   <= epoch_counter + 1;
    end
end

endmodule