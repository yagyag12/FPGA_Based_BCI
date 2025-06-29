/************************************************************/
//    H I G H P A S S   F I L T E R   T E S T B E N C H     //
//                                                          //
//  Desc: 1 Hz IIR Butterworth highpass filter design       //
/************************************************************/
`timescale 1ns / 1ps

module highpass_tb;

/***********************  SIGNALS  **************************/

localparam FILTER_ORDER = 7;
logic               clk;
logic               rst;
logic               enable;
logic signed [31:0] filter_in;
logic signed [31:0] filter_out;
logic signed [31:0] x_in_values [FILTER_ORDER - 1:0]; 
logic               valid_prev  [FILTER_ORDER - 1:0];
logic signed [31:0] eeg_value;

integer file_handle;
integer file_id, file_in2;
integer i;
integer read_status;

/**************************  UUT  ***************************/

biquad_highpass_filter uut (
  .clk        (clk),
  .rst        (rst),
  .enable     (enable),
  .filter_in  (filter_in),
  .filter_out (filter_out)
  );

/**********************  TESTBENCH  *************************/
                              
initial begin                                         
  clk = 0;                                          
  forever #5 clk = ~clk;
end                                                     

initial begin
  rst = 1;
  filter_in = 0;
  enable = 0;

  // Open the EEG data file
  file_handle = $fopen("eegtest.txt", "r");
  if (file_handle == 0) begin
    $display("Error: Failed to open file eegtest.txt.");
    $stop;
  end

  // Reset the design
  #20 rst = 0; enable = 1; 

  while (!$feof(file_handle)) begin
    // Read each line of the file
    read_status = $fscanf(file_handle, "%d\n", eeg_value);
    if (read_status == 1) begin
      filter_in = eeg_value[31:0]; 
      $fdisplay(file_id, "%d", filter_out);
      $fdisplay(file_in2, "%032b", filter_in);
    end
    #10; 
  end

  $fclose(file_id);
  $fclose(file_handle);
  #200 
  $stop;
end

endmodule



