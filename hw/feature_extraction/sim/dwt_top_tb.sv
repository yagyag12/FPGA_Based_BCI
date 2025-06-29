/************************************************************/
//          D W T   T O P   T E S T B E N C H               //
//                                                          //
//  Desc: DWT using Mallat's Algorithm for decomposing the  //
//        EEG frequency bands and extracting features from  //
//        each band                                         //
/************************************************************/
`timescale 1ns / 1ps

module dwt_top_tb;

/***********************  SIGNALS  **************************/

    logic                   clk;
    logic                   rst;
    logic                   en;
    logic   signed  [31:0]  preprocessed_input;
    logic   signed  [31:0]  dwt_gamma_max;
    logic   signed  [31:0]  dwt_gamma_min;
    logic   signed  [31:0]  dwt_gamma_mean;
    logic   signed  [31:0]  dwt_gamma_sum;
    logic   signed  [31:0]  dwt_beta_max;
    logic   signed  [31:0]  dwt_beta_min;
    logic   signed  [31:0]  dwt_beta_mean;
    logic   signed  [31:0]  dwt_beta_sum;
    logic   signed  [31:0]  dwt_alpha_max;
    logic   signed  [31:0]  dwt_alpha_min;
    logic   signed  [31:0]  dwt_alpha_mean;
    logic   signed  [31:0]  dwt_alpha_sum;
    logic   signed  [31:0]  dwt_theta_max;
    logic   signed  [31:0]  dwt_theta_min;
    logic   signed  [31:0]  dwt_theta_mean;
    logic   signed  [31:0]  dwt_theta_sum;
    logic   signed  [31:0]  dwt_delta_max;
    logic   signed  [31:0]  dwt_delta_min;
    logic   signed  [31:0]  dwt_delta_mean;
    logic   signed  [31:0]  dwt_delta_sum;
    logic                   dwt_valid;
    logic           [4:0]   validList;
    logic signed    [31:0]  det             [0:4];
    logic signed    [31:0]  app             [0:4];
    logic signed    [31:0]  det_downsampled [0:4];
    logic signed    [31:0]  app_downsampled [0:4];
    logic                   downsampler     [0:4];
    logic signed    [31:0]  gammaReg        [63:0];
    logic signed    [31:0]  betaReg         [31:0];
    logic signed    [31:0]  alphaReg        [15:0];
    logic signed    [31:0]  thetaReg        [7:0];
    logic signed    [31:0]  deltaReg        [7:0];
    logic           [8:0]   counterSample;
    logic           [6:0]   counterGamma;
    logic           [5:0]   counterBeta;
    logic           [4:0]   counterAlpha;
    logic           [3:0]   counterTheta;
    logic           [4:0]   output_valid;
    logic   signed  [31:0]  gamma_wire;
    logic   signed  [31:0]  beta_wire;
    logic   signed  [31:0]  alpha_wire;
    logic   signed  [31:0]  theta_wire;
    logic   signed  [31:0]  delta_wire;
    logic   signed  [31:0]  eeg_value;

    integer file_input;
    integer i,j;
    integer read_status;



/**************************  UUT  ***************************/

    dwt_top uut (
        .clk                (clk),
        .rst                (rst),
        .en                 (en),
        .preprocessed_input (preprocessed_input),
        .dwt_gamma_max      (dwt_gamma_max),
        .dwt_gamma_min      (dwt_gamma_min),
        .dwt_gamma_mean     (dwt_gamma_mean),
        .dwt_gamma_sum      (dwt_gamma_sum),
        .dwt_beta_max       (dwt_beta_max),
        .dwt_beta_min       (dwt_beta_min),
        .dwt_beta_mean      (dwt_beta_mean),
        .dwt_beta_sum       (dwt_beta_sum),
        .dwt_alpha_max      (dwt_alpha_max),
        .dwt_alpha_min      (dwt_alpha_min),
        .dwt_alpha_mean     (dwt_alpha_mean),
        .dwt_alpha_sum      (dwt_alpha_sum),
        .dwt_theta_max      (dwt_theta_max),
        .dwt_theta_min      (dwt_theta_min),
        .dwt_theta_mean     (dwt_theta_mean),
        .dwt_theta_sum      (dwt_theta_sum),
        .dwt_delta_max      (dwt_delta_max),
        .dwt_delta_min      (dwt_delta_min),
        .dwt_delta_mean     (dwt_delta_mean),
        .dwt_delta_sum      (dwt_delta_sum),
        .dwt_valid          (dwt_valid)
    );

/**********************  TESTBENCH  *************************/

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize signals
        rst = 1;
        en  = 0;
        preprocessed_input = 0;

        // Open input file
        file_input = $fopen("preprocessed_signal.txt", "r");
        if (file_input == 0) begin
            $display("Error: Failed to open input file");
            $stop;
        end
    
        // Reset sequence
        #10 rst = 0;
        #10 en  = 1;

        while (!$feof(file_input)) begin
            // Read each line of the input file
            read_status = $fscanf(file_input, "%d\n", eeg_value);
            if (read_status == 1) begin
                preprocessed_input = eeg_value[31:0]; 
            end    
            #10;
        end

        // Finish simulation
        #1000;
        $fclose(file_input);
        $finish;
    end
    
endmodule
