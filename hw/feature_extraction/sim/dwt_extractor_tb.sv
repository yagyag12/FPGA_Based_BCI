/************************************************************/
//       D W T   E X T R A C T O R   T E S T B E N C H      //
//                                                          //
//  Desc: Extracts features from the DWT coefficients       //
/************************************************************/
`timescale 1ns / 1ps

module dwt_extractor_tb;

/***********************  SIGNALS  **************************/

localparam LENGTH       = 8;    // Coefficient Length
localparam CLK_PERIOD   = 10;

logic                                   clk;
logic                                   rst;
logic                                   en;
logic   signed  [31:0]                  coeff_in;
logic                                   valid;
logic   signed  [31:0]                  max;
logic   signed  [31:0]                  min;
logic   signed  [31 + $clog2(LENGTH):0] mean;
logic   signed  [31 + $clog2(LENGTH):0] sum;
logic           [$clog2(LENGTH)- 1: 0]  counter;
logic   signed  [31:0]                  abs_data;
logic   signed  [31 + $clog2(LENGTH):0] abs_acc;        
logic   signed  [31 + $clog2(LENGTH):0] mean_acc;       
logic   signed  [31:0]                  current_max;
logic   signed  [31:0]                  current_min;

integer i; 

/**************************  UUT  ***************************/

dwt_extractor #(
    .LENGTH     (LENGTH)
) uut (
    .clk        (clk),
    .rst        (rst),
    .en         (en),
    .coeff_in   (coeff_in),
    .valid      (valid),
    .max        (max),
    .min        (min),
    .mean       (mean),
    .sum        (sum)
);

/**********************  TESTBENCH  *************************/

initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    rst = 1;
    en  = 0;
    coeff_in = 0;
    #CLK_PERIOD;
    rst = 0;
    en  = 1;
    for (i = 0; i < 6; i = i + 1) begin
        coeff_in = $random;
        #CLK_PERIOD;
    end
    coeff_in = 32'b0111_1111_1111_1111_1111_1111_1111_1111;
    #(15*CLK_PERIOD);
    $finish;  
end

endmodule
