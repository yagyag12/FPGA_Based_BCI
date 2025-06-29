/************************************************************/
//                   F F T   M O D U L E                    //
//                                                          //
//  Desc: Controls the Vivado FFT IP Core                   //
/************************************************************/
`timescale 1ns / 1ps

module fft_module #(
    parameter EPOCH_LENGTH = 256
)(
    input                       clk,
    input                       rst,
    input                       en,
    input  logic signed [31:0]  data_in,
    output logic signed [31:0]  o_fft_imag,
    output logic signed [31:0]  o_fft_real,  
    output                      o_fft_valid,  
    output                      o_fft_done
    );

/***********************  SIGNALS  **************************/

logic signed [63:0] s_axis_data_tdata;
logic               s_axis_data_tlast;
logic               s_axis_data_tready;
logic               s_axis_data_tvalid;

logic        [15:0] s_axis_config_tdata;
logic               s_axis_config_tready;
logic               s_axis_config_tvalid;

logic signed [63:0] m_axis_data_tdata;
logic               m_axis_data_tlast;
logic               m_axis_data_tvalid;

logic signed [$clog2(EPOCH_LENGTH)-1:0] index;

/**********************  FFT INST  **************************/

xfft_0 fft_inst (
    .aclk                   (clk),
    .aresetn                (~rst),
    .s_axis_data_tdata      (s_axis_data_tdata),
    .s_axis_data_tlast      (s_axis_data_tlast),
    .s_axis_data_tready     (s_axis_data_tready),
    .s_axis_data_tvalid     (s_axis_data_tvalid),
    .s_axis_config_tdata    (s_axis_config_tdata),
    .s_axis_config_tready   (s_axis_config_tready),
    .s_axis_config_tvalid   (s_axis_config_tvalid),
    .m_axis_data_tdata      (m_axis_data_tdata),
    .m_axis_data_tlast      (m_axis_data_tlast),
    .m_axis_data_tvalid     (m_axis_data_tvalid)
);

/**********************  AXI CONTROL  ***********************/

// Configuration Logic
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        s_axis_config_tdata  <= 16'd0;       
        s_axis_config_tvalid <= 1'b0;       
    end else if (s_axis_config_tready) begin
        s_axis_config_tdata  <= 16'h0085;
        s_axis_config_tvalid <= 1'b1;       
    end else begin
        s_axis_config_tvalid <= 1'b0;      
    end
end

// Data Input Logic
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        s_axis_data_tdata  <= 64'd0;
        s_axis_data_tlast  <= 1'b0;
        s_axis_data_tvalid <= 1'b0;
        index              <= 0;
    end else if (en && s_axis_data_tready) begin
        s_axis_data_tdata  <= {32'd0, data_in}; 
        s_axis_data_tvalid <= 1'b1;
        s_axis_data_tlast  <= (index == EPOCH_LENGTH - 1); 
        index              <= (index == EPOCH_LENGTH - 1) ? 0 : index + 1;
    end else begin
        s_axis_data_tvalid <= 1'b0; 
    end
end

/*************************  OUTPUT **************************/

assign o_fft_real   = m_axis_data_tdata[31:0];
assign o_fft_imag   = m_axis_data_tdata[63:32];
assign o_fft_done   = m_axis_data_tlast;
assign o_fft_valid  = m_axis_data_tvalid;

endmodule
