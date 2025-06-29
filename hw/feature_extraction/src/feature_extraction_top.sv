/************************************************************/
//          F E A T U R E   E X T R A C T I O N             //
//                                                          //
//  Desc: Finds 27 unique features from a streaming signal  //
/************************************************************/
`timescale 1ns / 1ps

module feature_extraction_top(
    input                   clk,               
    input logic             new_sample_flag,
    input                   rst,
    input                   en,
    input   signed  [31:0]  data_in,
    input                   in_valid,
    // PSD Features
    output  signed  [31:0]  psd_gamma,
    output  signed  [31:0]  psd_beta,
    output  signed  [31:0]  psd_alpha,
    output  signed  [31:0]  psd_theta,
    output  signed  [31:0]  psd_delta,
    // Supplementary Features
    output  signed  [31:0]  peak_amplitude,
    output          [ 7:0]  zero_counter,
    // DWT Features
    output  signed  [31:0]  dwt_gamma_max,
    output  signed  [31:0]  dwt_gamma_min,
    output  signed  [31:0]  dwt_gamma_mean,
    output  signed  [31:0]  dwt_gamma_sum,
    output  signed  [31:0]  dwt_beta_max,
    output  signed  [31:0]  dwt_beta_min,
    output  signed  [31:0]  dwt_beta_mean,
    output  signed  [31:0]  dwt_beta_sum,
    output  signed  [31:0]  dwt_alpha_max,
    output  signed  [31:0]  dwt_alpha_min,
    output  signed  [31:0]  dwt_alpha_mean,
    output  signed  [31:0]  dwt_alpha_sum,
    output  signed  [31:0]  dwt_theta_max,
    output  signed  [31:0]  dwt_theta_min,
    output  signed  [31:0]  dwt_theta_mean,
    output  signed  [31:0]  dwt_theta_sum,
    output  signed  [31:0]  dwt_delta_max,
    output  signed  [31:0]  dwt_delta_min,
    output  signed  [31:0]  dwt_delta_mean,
    output  signed  [31:0]  dwt_delta_sum,
    output  logic           valid
);

/***********************  SIGNALS  **************************/

localparam              EPOCH_LENGTH = 256;
logic                   en_submodules;
logic                   rst_submodules;
logic                   psd_valid;
logic                   zcr_valid;
logic                   peak_valid;
logic                   dwt_valid;
integer i;
    
/*********************  MAIN CONTROL  ***********************/

// Enable / Reset Control Logic
always_ff @(posedge clk or posedge rst) begin
    if (rst | ~en) begin
        en_submodules   <= 0;
        rst_submodules  <= 1;
    end
    else begin
        if (in_valid) begin
            en_submodules  <= 1;
            rst_submodules <= 0;             
        end
        else if (valid) begin
            en_submodules  <= 0;
            rst_submodules <= 1;             
        end
    end
end

// Valid Control
assign valid = peak_valid & zcr_valid & psd_valid;

/***********************  PSD MODULE  ***********************/

psd_top #(
    .EPOCH_LENGTH       (EPOCH_LENGTH)
) psd_module (
    .clk                (clk),
    .rst                (rst_submodules),
    .en                 (en_submodules),
    .signal_in          (data_in),
    .delta_band_power   (psd_delta),
    .theta_band_power   (psd_theta),
    .alpha_band_power   (psd_alpha),
    .beta_band_power    (psd_beta),
    .gamma_band_power   (psd_gamma),
    .o_power_valid      (psd_valid)
);

/***********************  DWT MODULE  ***********************/

    dwt_top dwt_module (
        .clk                (clk),    
        .rst                (rst_submodules),    
        .en                 (en_submodules),
        .preprocessed_input (data_in),                
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

/***********************  ZCR MODULE  ***********************/

    zcr #(
        .EPOCH_LENGTH       (EPOCH_LENGTH)
    ) zcr_module (
        .clk                (clk),
        .rst                (rst_submodules),
        .en                 (en_submodules),
        .signal_sign        (data_in[31]),
        .zero_counter       (zero_counter),
        .valid              (zcr_valid)
    );

/***********************  PEAK MODULE  ***********************/

    peak #(
        .EPOCH_LENGTH       (EPOCH_LENGTH)
    ) peak_amplitude_module (
        .clk                (clk),
        .rst                (rst_submodules),
        .en                 (en_submodules),
        .data_in            (data_in),
        .peak_value         (peak_amplitude),
        .peak_valid         (peak_valid)
    );
    
endmodule
