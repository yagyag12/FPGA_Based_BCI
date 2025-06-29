/************************************************************/
//       P E A K   F I N D E R   T E S T B E N C H          //
//                                                          //
//  Desc: Finds the absolute peak value of the epoch        //
/************************************************************/
`timescale 1ns / 1ps

module peak_tb;

/***********************  SIGNALS   *************************/

localparam WINDOW_LENGTH = 256;
localparam CLK_PERIOD    = 10;

logic                   clk;
logic                   rst;
logic                   en;
logic   signed  [31:0]  data_in;
logic   signed  [31:0]  peak_value;
logic                   peak_valid;
logic   signed  [31:0]  current_peak;
logic           [ 7:0]  counter;
logic   signed  [31:0]  abs_data;

integer i; 

/**************************  UUT  ***************************/

peak #(
    .WINDOW_LENGTH  (WINDOW_LENGTH)
) uut (
    .clk            (clk),
    .rst            (rst),
    .en             (en),
    .data_in        (data_in),
    .peak_value     (peak_value),
    .peak_valid     (peak_valid)
);

/**********************  TESTBENCH  *************************/

initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    rst = 1;
    en  = 0;
    data_in = 0;
    #CLK_PERIOD;
    rst = 0;
    en  = 1;
    for (i = 0; i < 250; i = i + 1) begin
        data_in = $random;
        #CLK_PERIOD;
    end
    data_in = 32'b0111_1111_1111_1111_1111_1111_1111_1111;
    #(15*CLK_PERIOD);
    $finish;
end

endmodule
