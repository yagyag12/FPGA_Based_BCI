/************************************************************/
//          P R E P R O C E S S O R   M O D U L E           //
//                                                          //
//  Desc: Filters unnecessary components of the input EEG   //
//        signal and prepares it for feature extraction     //
/************************************************************/
`timescale 1ns / 1ps

module preprocesser_top(
    input                   clk,
    input                   sampling_clk,
    input                   rst,
    input                   enable,
    input   signed [31:0]   in_signal,
    output  signed [31:0]   out_signal,
    output                  valid,
    output  logic           new_sample_flag
    );

/***********************  SIGNALS  **************************/

localparam WINDOW_LENGTH    = 128;
localparam EPOCH_LENGTH     = 256;

logic signed [31:0] notch_out;
logic signed [31:0] movdiff_out;
logic signed [31:0] lpf_out;
logic               notch_valid;
logic               movdiff_valid;
logic signed [31:0] register_data [EPOCH_LENGTH - 1:0];
logic               epoch_valid;
logic        [ 7:0] sample_counter;
logic               window_loaded;
logic signed [31:0] epoch_out;
logic               sampling_clk_prev;
logic               en;
logic        [8:0]  out_counter;

/*******************  EPOCH REGISTER  ***********************/

// Module Inst.
epoch_reg #(
    .EPOCH_LENGTH   (EPOCH_LENGTH)
) epoch_reg_inst (
    .clk            (sampling_clk),
    .rst            (rst),
    .en             (enable),
    .data_in        (in_signal),
    .register_data  (register_data),
    .valid          (epoch_valid)
);

// Module Control
always_ff @(posedge clk or posedge rst) begin
    if (rst | ~enable) begin
        sample_counter      <= 0;
        window_loaded       <= 0;
        epoch_out           <= 0;
    end
    else begin
        if (new_sample_flag) begin
            sample_counter <= 0;
            window_loaded <= 0;
        end
        else if (epoch_valid) begin
            if (sample_counter == EPOCH_LENGTH - 1) begin
                sample_counter  <= EPOCH_LENGTH - 1;
                epoch_out       <= 0;
                window_loaded   <= 1;
            end
            else begin
                sample_counter  <= sample_counter + 1;
                epoch_out       <= register_data[sample_counter];
            end  
        end
    end
end

// Rising Edge Detector
always_ff @ (posedge clk or posedge rst) begin
    if (rst | ~enable) begin
        sampling_clk_prev   <= 0;
        new_sample_flag     <= 0;
    end
    else begin
        sampling_clk_prev   <= sampling_clk;
        new_sample_flag     <= sampling_clk & (~sampling_clk_prev);
    end
end

always_ff @ (posedge clk or posedge rst) begin
    if (rst | ~enable) begin
        out_counter <= 0;
        en <= 0;
    end
    else begin
        if (new_sample_flag) begin
            en <= 1;
            out_counter <= 0;
        end
        else if (valid) begin
            if (out_counter == EPOCH_LENGTH - 1) begin
                out_counter <= EPOCH_LENGTH - 1;
                en <= 0;
            end
            else begin
                out_counter <= out_counter + 1;
                en <= 1;
            end
        end
    end
end

/********************  NOTCH FILTER  ************************/

biquad_notch_filter first_stage_notch (
    .clk        (clk),
    .rst        (new_sample_flag),
    .enable     (en),
    .filter_in  (epoch_out),
    .filter_out (notch_out),
    .valid      (notch_valid)
);

/***********************  MOV DIFF  *************************/

moving_difference # (
    .WINDOW_LENGTH  (WINDOW_LENGTH)
) second_stage_difference(
    .clk        (clk),
    .rst        (new_sample_flag),
    .en         (en),
    .validIn    (notch_valid),
    .filter_in  (notch_out),
    .filter_out (movdiff_out),
    .valid      (movdiff_valid)
);

/************************  FIR LPF  *************************/

fir_lowpass third_stage_lowpass(
    .clk        (clk),
    .rst        (new_sample_flag),
    .en         (en),
    .validIn    (movdiff_valid),
    .in_signal  (movdiff_out),
    .out_signal (lpf_out),
    .valid      (valid)
);

assign out_signal = valid ? lpf_out : 32'd0;

endmodule
