/************************************************************/
//     M O V I N G   A V E R A G E   T E S T B E N C H      //
//                                                          //
//  Desc: Moving average filter                             //
/************************************************************/
`timescale 1ns / 1ps

module moving_average_tb;

/***********************  SIGNALS  **************************/

  parameter WINDOW_LENGTH = 16;
  parameter DATA_WIDTH    = 16;

  logic                   clk;
  logic                   rst;
  logic [DATA_WIDTH-1:0]  data_in;
  logic [DATA_WIDTH-1:0]  filter_out;
  logic [31:0]            eeg_value;
  integer file_handle;
  integer read_status;

/**************************  UUT  ***************************/

  moving_average #(
    .WINDOW_LENGTH  (WINDOW_LENGTH),
    .DATA_WIDTH     (DATA_WIDTH)
  ) dut (
    .clk            (clk),
    .rst            (rst),
    .data_in        (data_in),
    .filter_out     (filter_out)
  );

/**********************  TESTBENCH  *************************/

  initial begin                                         
      clk = 0;                                          
      forever #5 clk = ~clk;   
  end                                                     

  initial begin
    rstn = 0;
    data_in = 0;

    file_handle = $fopen("eegtest.txt", "r");
    if (file_handle == 0) begin
      $display("Error: Failed to open file eegtest.txt.");
      $stop;
    end
    #10 rst = 1;  

    while (!$feof(file_handle)) begin
      // Read each line of the file
      read_status = $fscanf(file_handle, "%d\n", eeg_value);
      if (read_status == 1) begin
        data_in = eeg_value[DATA_WIDTH-1:0];
      end
      #10;  
    end

    $fclose(file_handle);
    #200 $stop;
  end

endmodule
