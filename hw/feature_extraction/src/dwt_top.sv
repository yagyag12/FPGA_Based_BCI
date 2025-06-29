/************************************************************/
//   D I S C R E T E   W A V E L E T   T R A N S F O R M    //
//                                                          //
//  Desc: DWT using Mallat's Algorithm for decomposing the  //
//        EEG frequency bands and extracting features from  //
//        each band                                         //
/************************************************************/
`timescale 1ns / 1ps

module dwt_top(
    input                   clk,
    input                   rst,
    input                   en,
    input   signed  [31:0]  preprocessed_input,
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
    output                  dwt_valid
    );

/***********************  SIGNALS   *************************/
// Wavelet Decomposition
logic        [4:0]  valid_list;
logic signed [31:0] det             [0:4]; // Detail Coefficients
logic signed [31:0] app             [0:4]; // Approximation Coefficients
logic signed [31:0] det_downsampled [0:4];
logic signed [31:0] app_downsampled [0:4];
logic               downsampler     [0:4];
logic signed [31:0] gamma_reg       [63:0];
logic signed [31:0] beta_reg        [31:0];
logic signed [31:0] alpha_reg       [15:0];
logic signed [31:0] theta_reg       [7:0];
logic signed [31:0] delta_reg       [7:0];
logic        [8:0]  sample_counter;
logic        [6:0]  gamma_counter;
logic        [5:0]  beta_counter;
logic        [4:0]  alpha_counter;
logic        [3:0]  theta_counter;

// Feature Extraction
logic           [4:0]   output_valid;
logic   signed  [31:0]  gamma_wire;
logic   signed  [31:0]  beta_wire;
logic   signed  [31:0]  alpha_wire;
logic   signed  [31:0]  theta_wire;
logic   signed  [31:0]  delta_wire;

/****************  WAVELET DECOMPOSITION  *******************/

// Downsampling
always_ff @(posedge clk or posedge rst) begin
    if (rst | ~en) begin
        downsampler[0] <= 0;
    end 
    else begin
        downsampler[0] <= ~downsampler[0];
    end
end

genvar j;
generate;
    for (j = 1; j < 5; j++) begin
        always_ff @(posedge downsampler[j-1] or posedge rst) begin
            if (rst | ~en) begin
                downsampler[j] <= 0;
            end 
            else begin
                downsampler[j] <= ~downsampler[j];
            end
        end
    end
endgenerate

// Highpass Decomposition (Detail) Filter
HiD hid0 (
    .clk        (clk),
    .rst        (rst),
    .en         (en),
    .in_signal  (preprocessed_input),
    .out_signal (det[0])
);

// Lowpass Decomposition (Approximation) Filter
LoD lod0 (
    .clk        (clk),
    .rst        (rst),
    .en         (en),
    .in_signal  (preprocessed_input),
    .out_signal (app[0])
);

always_ff @(posedge downsampler[0] or posedge rst) begin
    if (rst | ~en) begin
        det_downsampled[0] <= 0;
        app_downsampled[0] <= 0;
    end else begin
        det_downsampled[0] <= det[0];
        app_downsampled[0] <= app[0];
    end
end

genvar i;
generate;
    for (i = 1; i < 5; i = i + 1) begin
        HiD hid_x (
            .clk        (downsampler[i]),
            .rst        (rst),
            .en         (en),
            .in_signal  (app_downsampled[i-1]),
            .out_signal (det[i])
        );

        LoD lod_x (
            .clk        (downsampler[i]),
            .rst        (rst),
            .en         (en),
            .in_signal  (app_downsampled[i-1]),
            .out_signal (app[i])
        );  

        always_ff @(posedge downsampler[i] or posedge rst) begin
            if (rst | ~en) begin
                det_downsampled[i] <= 0;
                app_downsampled[i] <= 0;
                case (i)
                    1: begin
                        gamma_counter <= 0;
                    end
                    2: begin
                        beta_counter  <= 0;
                    end
                    3: begin
                        alpha_counter <= 0;
                    end
                    4: begin
                        theta_counter <= 0;
                    end
                endcase
            end 
            else begin
                det_downsampled[i] <= det[i];
                app_downsampled[i] <= app[i];
                if(valid_list[i - 1]) begin
                    case (i)
                        1: begin
                          gamma_reg[gamma_counter]  <= det_downsampled[i];
                          if(gamma_counter != 64) begin
                                gamma_counter <= gamma_counter + 1;
                            end
                        end
                        2: begin
                           beta_reg[beta_counter] <= det_downsampled[i];
                           if(beta_counter != 32) begin
                                beta_counter <= beta_counter + 1;
                            end
                        end
                        3: begin
                           alpha_reg[alpha_counter] <= det_downsampled[i];
                           if(alpha_counter != 16) begin
                                alpha_counter <= alpha_counter + 1;
                            end
                        end
                        4: begin
                            theta_reg[theta_counter] <= det_downsampled[i];
                            delta_reg[theta_counter] <= app_downsampled[i];
                            if(theta_counter != 8) begin
                                theta_counter <= theta_counter + 1;
                            end
                        end
                    endcase
                end
            end
        end
    end
endgenerate

// Coefficient Validation
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        sample_counter <= 0;
        valid_list     <= 'b00000;
    end
    else begin
        if (sample_counter != 256) begin
            sample_counter <= sample_counter + 1;
        end
        case (sample_counter)
            6: begin
                valid_list <= 'b00001;
            end
            18: begin
                valid_list <= 'b00011;
            end
            34: begin
                valid_list <= 'b00111;
            end
            66: begin
                valid_list <= 'b11111;
            end
        endcase
    end
end

// Extracting the Features
assign gamme_wire = gamma_reg[gamma_counter];
assign beta_wire  = beta_reg[beta_counter];
assign alpha_wire = alpha_reg[alpha_counter];
assign theta_wire = theta_reg[theta_counter];
assign delta_wire = delta_reg[theta_counter];
assign dwt_valid  = (output_valid == 5'b11111);

dwt_extractor #(.LENGTH(64)) extract_gamma (
    .clk        (clk),
    .rst        (rst),
    .en         (valid_list[0]),
    .coeff_in   (det_downsampled[1]),
    .valid      (output_valid[0]),
    .max        (dwt_gamma_max),
    .min        (dwt_gamma_min),
    .mean       (dwt_gamma_mean),
    .sum        (dwt_gamma_sum)
);
dwt_extractor #(.LENGTH(32)) extract_beta  (
    .clk        (clk),
    .rst        (rst),
    .en         (valid_list[1]),
    .coeff_in   (det_downsampled[2]),
    .valid      (output_valid[1]),
    .max        (dwt_beta_max),
    .min        (dwt_beta_min),
    .mean       (dwt_beta_mean),
    .sum        (dwt_beta_sum)
);
dwt_extractor #(.LENGTH(16)) extract_alpha (
    .clk        (clk),
    .rst        (rst),
    .en         (valid_list[2]),
    .coeff_in   (det_downsampled[3]),
    .valid      (output_valid[2]),
    .max        (dwt_alpha_max),
    .min        (dwt_alpha_min),
    .mean       (dwt_alpha_mean),
    .sum        (dwt_alpha_sum)
);
dwt_extractor #(.LENGTH(8))  extract_theta (
    .clk        (clk),
    .rst        (rst),
    .en         (valid_list[3]),
    .coeff_in   (det_downsampled[4]),
    .valid      (output_valid[3]),
    .max        (dwt_theta_max),
    .min        (dwt_theta_min),
    .mean       (dwt_theta_mean),
    .sum        (dwt_theta_sum)
);
dwt_extractor #(.LENGTH(8))  extract_delta (
    .clk        (clk),
    .rst        (rst),
    .en         (valid_list[4]),
    .coeff_in   (app_downsampled[4]),
    .valid      (output_valid[4]),
    .max        (dwt_delta_max),
    .min        (dwt_delta_min),
    .mean       (dwt_delta_mean),
    .sum        (dwt_delta_sum)
);

endmodule
