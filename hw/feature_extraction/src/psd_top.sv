/************************************************************/
//       P O W E R   S P E C T R A L   D E N S I T Y        //
//                                                          //
//  Desc: Calculates each bands PSD value by windowing,     //
//    FFT and power calculations                            //
/************************************************************/
`timescale 1ns / 1ps

module psd_top #(
    parameter EPOCH_LENGTH = 256
)(
    input                           clk,
    input                           rst,
    input                           en,
    input   logic   signed  [31:0]  signal_in,
    output  logic   signed  [31:0]  delta_band_power,
    output  logic   signed  [31:0]  theta_band_power,
    output  logic   signed  [31:0]  alpha_band_power,
    output  logic   signed  [31:0]  beta_band_power,
    output  logic   signed  [31:0]  gamma_band_power,
    output  logic                   o_power_valid
);

/***********************  SIGNALS  **************************/
//  Windowing
logic   signed  [31:0]  windowed_signal;
logic                   o_window_done;
logic                   o_window_valid;
//  FFT
logic   signed  [31:0]  data_in;
logic   signed  [31:0]  o_fft_imag;
logic   signed  [31:0]  o_fft_real;
logic                   o_fft_valid;
logic                   o_fft_done;
//  Power Calculator
logic                   i_signal_valid;
logic   signed  [31:0]  i_signal_real;
logic   signed  [31:0]  i_signal_imag;

/**********************  WINDOWING  *************************/

windowing_module #(
    .EPOCH_LENGTH(EPOCH_LENGTH)
) window0 (
    .clk                (clk),
    .rst                (rst),
    .en                 (en),
    .signal_in          (signal_in),
    .windowed_signal    (windowed_signal),
    .o_window_done      (o_window_done),
    .o_window_valid     (o_window_valid)
);

assign data_in = windowed_signal;

/**************************  FFT  ***************************/

fft_module  #(
    .EPOCH_LENGTH(EPOCH_LENGTH)
) fft0 (
    .clk                (clk),
    .rst                (rst),
    .en                 (en),
    .data_in            (data_in),
    .o_fft_imag         (o_fft_imag),
    .o_fft_real         (o_fft_real),
    .o_fft_valid        (o_fft_valid),
    .o_fft_done         (o_fft_done)
);

assign i_signal_real    = o_fft_real;
assign i_signal_imag    = o_fft_imag;
assign i_signal_valid   = o_fft_valid;

/*************************  POWER  **************************/

power_calculator #(
    .EPOCH_LENGTH(EPOCH_LENGTH)
) power0 (
    .clk                (clk),
    .rst                (rst),
    .en                 (en),
    .i_signal_valid     (i_signal_valid),
    .i_signal_real      (i_signal_real),
    .i_signal_imag      (i_signal_imag),
    .delta_band_power   (delta_band_power),
    .theta_band_power   (theta_band_power),
    .alpha_band_power   (alpha_band_power),
    .beta_band_power    (beta_band_power),
    .gamma_band_power   (gamma_band_power),
    .o_power_valid      (o_power_valid)
);

endmodule
