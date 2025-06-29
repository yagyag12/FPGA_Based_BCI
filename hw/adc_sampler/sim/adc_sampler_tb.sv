/************************************************************/
//        A D C   S A M P L E R   T E S T B E N C H         //
//                                                          //
//  Desc: Creates a sampling clock and samples the input    //
/************************************************************/
`timescale 1ns / 1ps

module adc_sampler_tb;

/***********************  SIGNALS  **************************/

localparam CLK_FREQ     = 100000000;
localparam TARGET_FREQ  = 256;
localparam CLK_PERIOD   = 10;
localparam COUNTER_VAL  = CLK_FREQ / TARGET_FREQ;

logic                               clk;
logic                               rst;
logic   [31:0]                      adc_in;
logic   [31:0]                      sample_out;
logic                               sample_clk;
logic   [$clog2(COUNTER_VAL)-1:0]   counter;

integer i; 

/**************************  UUT  ***************************/

adc_sampler #(
    .CLK_FREQ       (CLK_FREQ),
    .TARGET_FREQ    (TARGET_FREQ)
) uut (
    .clk        (clk),
    .rst        (rst),
    .adc_in     (adc_in),
    .sample_out (sample_out),
    .sample_clk (sample_clk)
);

/**********************  TESTBENCH  *************************/

initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    rst = 1;
    adc_in = 0;
    #CLK_PERIOD;
    rst = 0;
    for (i = 0; i <= COUNTER_VAL*3; i = i + 1) begin
        adc_in = $random;
        #CLK_PERIOD;
    end
    $finish;
end

endmodule