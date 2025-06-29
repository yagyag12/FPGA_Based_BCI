/************************************************************/
//         T O P   M O D U L E   T E S T B E N C H          //
//                                                          //
//  Desc: Testbench for the PL block design                 //
/************************************************************/
`timescale 1ns / 1ns

module PL_top_tb;

/***********************  SIGNALS  **************************/

logic       i_clk;
logic       i_enable;
logic       i_rst;
logic       done;
logic [3:0] class_label;

integer file_out;
integer sample_counter = 0;

/**************************  UUT  ***************************/

PL_top_wrapper uut(
    .i_clk       (i_clk),
    .i_enable    (i_enable),
    .i_rst       (i_rst),
    .class_label (class_label),
    .done        (done)
);

/**********************  TESTBENCH  *************************/

initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk;
end

initial begin
        file_out = $fopen("out_class_labels.txt", "w");
        if (file_out == 0) begin
            $display("ERROR: Cannot open file!");
            $finish;
        end

    i_rst = 1;
    i_enable = 0;
    #50000;
    i_enable = 1;
    i_rst = 0;
    #105_000_000;
end

always @(posedge i_clk) begin
    if (done) begin
        $fwrite(file_out, "%0d\n",  class_label);
        sample_counter = sample_counter + 1;
    end
    if (sample_counter == 9745) begin
        $fclose(file_out);
        $finish;
    end
end

endmodule
