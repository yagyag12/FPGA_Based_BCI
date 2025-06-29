/************************************************************/
//                A D C   T E S T   M O D U L E             //
//                                                          //
//  Desc: Tests the ADC input by reading from memory        //
/************************************************************/
`timescale 1ns / 1ps

module adc_test #(
    parameter ADDR_VAL = 31000
    )(
    input clk,
    input rst,
    output logic [$clog2(ADDR_VAL) - 1:0] addr
    );
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            addr <= 0;
        end else begin
                addr <= (addr == ADDR_VAL - 1) ? 0 : (addr + 1);
        end
    end
endmodule
