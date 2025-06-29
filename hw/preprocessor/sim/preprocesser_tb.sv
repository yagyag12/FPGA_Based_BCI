/************************************************************/
//       P R E P R O C E S S O R   T E S T B E N C H        //
//                                                          //
//  Desc: Filters unnecessary components of the input EEG   //
//        signal and prepares it for feature extraction     //
/************************************************************/
`timescale 1ns / 1ns

module preprocesser_tb;

/***********************  SIGNALS  **************************/

localparam CLK_PERIOD       = 10;
localparam SAMPLING_PERIOD  = 10000;

logic               clk;
logic               rst; 
logic               enable;
logic               sampling_clk;
logic signed [31:0] in_signal;
logic signed [31:0] out_signal;
logic signed [31:0] eeg_value;

integer file_handle;
integer file_id;
integer i;
integer read_status;

/**************************  UUT  ***************************/

preprocesser_top uut (
    .clk            (clk),
    .sampling_clk   (sampling_clk),
    .rst            (rst),
    .enable         (enable),
    .in_signal      (in_signal),
    .out_signal     (out_signal)
);

/**********************  TESTBENCH  *************************/

initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end 

initial begin
    sampling_clk = 0;
    forever #(SAMPLING_PERIOD/2) sampling_clk = ~sampling_clk;
end 

initial begin
    rst = 1;
    enable = 0;
    in_signal = 0;
    
    file_handle = $fopen("eegtest.txt", "r");
    if (file_handle == 0) begin
        $display("Error: Failed to open file eegtest.txt.");
        $stop;
    end

    #CLK_PERIOD;
    rst = 0;
    enable = 1;
    
    while (!$feof(file_handle)) begin
    // Read each line of the file
        read_status = $fscanf(file_handle, "%d\n", eeg_value);
        if (read_status == 1) begin
            in_signal = eeg_value[31:0]; 
        end
        #SAMPLING_PERIOD;
    end
    #(2*SAMPLING_PERIOD);
    $stop;
end
    
endmodule
