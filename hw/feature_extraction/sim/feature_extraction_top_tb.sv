/************************************************************/
//  F E A T U R E   E X T R A C T I O N   T E S T B E N C H //
//                                                          //
//  Desc: Finds 27 unique features from a streaming signal  //
/************************************************************/
`timescale 1ns / 1ns

module feature_extraction_top_tb;

/***********************  SIGNALS  **************************/

localparam EPOCH_LENGTH = 256;
logic                   clk;
logic                   new_sample_flag;
logic                   rst;
logic                   en;
logic   signed  [31:0]  data_in;
logic                   in_valid;
logic   signed  [31:0]  psd_gamma, psd_beta, psd_alpha, psd_theta, psd_delta;
logic   signed  [31:0]  peak_amplitude;
logic           [ 7:0]  zero_counter;
logic   signed  [31:0]  dwt_gamma_max, dwt_gamma_min, dwt_gamma_mean, dwt_gamma_sum;
logic   signed  [31:0]  dwt_beta_max, dwt_beta_min, dwt_beta_mean, dwt_beta_sum;
logic   signed  [31:0]  dwt_alpha_max, dwt_alpha_min, dwt_alpha_mean, dwt_alpha_sum;
logic   signed  [31:0]  dwt_theta_max, dwt_theta_min, dwt_theta_mean, dwt_theta_sum;
logic   signed  [31:0]  dwt_delta_max, dwt_delta_min, dwt_delta_mean, dwt_delta_sum;
logic                   valid;

integer                 file, i;
integer                 scan_result;
integer                 file_out;
integer                 sample_index = 0;

/**************************  UUT  ***************************/

feature_extraction_top uut (
    .clk                (clk),
    .new_sample_flag    (new_sample_flag),
    .rst                (rst),
    .en                 (en),
    .data_in            (data_in),
    .in_valid           (in_valid),
    .psd_gamma          (psd_gamma),
    .psd_beta           (psd_beta),
    .psd_alpha          (psd_alpha),
    .psd_theta          (psd_theta),
    .psd_delta          (psd_delta),
    .peak_amplitude     (peak_amplitude),
    .zero_counter       (zero_counter),
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
    .valid              (valid)
);

/**********************  TESTBENCH  *************************/

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    file = $fopen("C:\\Users\\yagiz\\OneDrive\\Belgeler\\GitHub\\BrainComputerInterface\\MatlabSim\\EEG_Matlab\\preprocessed_signal.txt", "r"); // Open file in read mode
    
    if (file == 0) begin
        $display("ERROR: Cannot open the file!");
        $finish;
    end

    file_out = $fopen("out_features.txt", "w");

    if (file_out == 0) begin
        $display("ERROR: Cannot open the file!");
        $finish;
    end

    // Reset
    rst = 1;
    en = 0;
    #20;
    rst = 0;
    en = 1;

end

always @(posedge clk) begin
    if (sample_index < 10000) begin
        scan_result = $fscanf(file, "%d\n", data_in);
        if (scan_result != 1) begin
            $display("ERROR: File read error at line %0d", sample_index);
            $finish;
        end
        sample_index = sample_index + 1;
    end else begin
        $fclose(file);
        $fclose(file_out);
        $finish;
    end
end

// Write the output features for model training
always @(posedge clk) begin
    if (valid) begin
        $fwrite(file_out, "psd_gamma=%0d, psd_beta=%0d, psd_alpha=%0d, psd_theta=%0d, psd_delta=%0d\n", 
            psd_gamma, psd_beta, psd_alpha, psd_theta, psd_delta);
        $fwrite(file_out, "peak_amplitude=%0d, zero_counter=%0d\n", peak_amplitude, zero_counter);
        $fwrite(file_out, "dwt_gamma: max=%0d, min=%0d, mean=%0d, sum=%0d\n",
            dwt_gamma_max, dwt_gamma_min, dwt_gamma_mean, dwt_gamma_sum);
        $fwrite(file_out, "dwt_beta:  max=%0d, min=%0d, mean=%0d, sum=%0d\n",
            dwt_beta_max, dwt_beta_min, dwt_beta_mean, dwt_beta_sum);
        $fwrite(file_out, "dwt_alpha: max=%0d, min=%0d, mean=%0d, sum=%0d\n",
            dwt_alpha_max, dwt_alpha_min, dwt_alpha_mean, dwt_alpha_sum);
        $fwrite(file_out, "dwt_theta: max=%0d, min=%0d, mean=%0d, sum=%0d\n",
            dwt_theta_max, dwt_theta_min, dwt_theta_mean, dwt_theta_sum);
        $fwrite(file_out, "dwt_delta: max=%0d, min=%0d, mean=%0d, sum=%0d\n",
            dwt_delta_max, dwt_delta_min, dwt_delta_mean, dwt_delta_sum);
        $fwrite(file_out, "-------------------------------\n");
    end
end

endmodule
