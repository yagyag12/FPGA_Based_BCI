/************************************************************/
//             P O W E R   C A L C U L A T O R              //
//                                                          //
//  Desc: Power calculation by summation of the squares of  //
//        real and imaginary components of the FFT output   //
/************************************************************/
`timescale 1ns / 1ps

module power_calculator #(
    parameter EPOCH_LENGTH = 256
)(
    input                           clk,
    input                           rst,
    input                           en,
    input                           i_signal_valid,
    input   logic   signed  [31:0]  i_signal_real,
    input   logic   signed  [31:0]  i_signal_imag,
    output  logic   signed  [31:0]  delta_band_power,
    output  logic   signed  [31:0]  theta_band_power,
    output  logic   signed  [31:0]  alpha_band_power,
    output  logic   signed  [31:0]  beta_band_power,
    output  logic   signed  [31:0]  gamma_band_power,
    output  logic                   o_power_valid
    );

/***********************  SIGNALS  **************************/

logic                                       i_signal_valid_reg;
logic   signed  [17:0]                      i_signal_real_reg;
logic   signed  [17:0]                      i_signal_imag_reg;
logic   signed  [36:0]                      i_signal_power_acc;
logic   signed  [35:0]                      real_power_acc;
logic   signed  [35:0]                      imag_power_acc;
logic           [$clog2(EPOCH_LENGTH)-1:0]  signal_counter;
logic           [31:0]                      signal_power;

/*********************  POWER CALC  *************************/

// Input Buffering
always_ff @ (posedge clk or posedge rst) begin
    if (rst | ~en) begin
        i_signal_valid_reg  <= 0;
        i_signal_real_reg   <= 0;
        i_signal_imag_reg   <= 0;
    end
    else begin
        i_signal_real_reg  <= {i_signal_real[31], i_signal_real[16:0]};
        i_signal_imag_reg  <= {i_signal_imag[31], i_signal_imag[16:0]};
        i_signal_valid_reg <= i_signal_valid;  
    end
end

// Signal Power and Band Power Calculations
always_ff @(posedge clk or posedge rst) begin
    if (rst | ~en) begin
        i_signal_power_acc  <=  0;
        signal_counter      <=  0;
        delta_band_power    <=  0;
        theta_band_power    <=  0;
        alpha_band_power    <=  0;
        beta_band_power     <=  0;
        gamma_band_power    <=  0;
        o_power_valid       <=  0;
        real_power_acc      <=  0;
        imag_power_acc      <=  0;
    end 
    else begin
        if(i_signal_valid_reg) begin
            if (signal_counter == (EPOCH_LENGTH/2)) begin
                o_power_valid    <= 1;
                signal_counter   <= EPOCH_LENGTH/2;
            end 
            else begin
                o_power_valid       <= 0;
                real_power_acc      <= i_signal_real_reg * i_signal_real_reg;
                imag_power_acc      <= i_signal_imag_reg * i_signal_imag_reg;
                i_signal_power_acc  <= real_power_acc + imag_power_acc;
                signal_counter      <= signal_counter + 1;

                if (signal_counter <= 'd5) begin
                    delta_band_power <= delta_band_power + signal_power; 
                end 
                else if (signal_counter >= 'd6 && signal_counter <= 'd9)    begin
                    theta_band_power <= theta_band_power + signal_power; 
                end 
                else if (signal_counter >= 'd10 && signal_counter <= 'd13)  begin
                    alpha_band_power <= alpha_band_power + signal_power; 
                end 
                else if (signal_counter >= 'd14 && signal_counter <= 'd41)  begin
                    beta_band_power  <= beta_band_power  + signal_power; 
                end 
                else if (signal_counter >= 'd42 && signal_counter <= 'd61)  begin
                    gamma_band_power <= gamma_band_power + signal_power; 
                end
            end
        end 
        else begin
            i_signal_power_acc  <= 0;
            real_power_acc      <= 0;
            imag_power_acc      <= 0;
        end
    end
end

assign signal_power = {i_signal_power_acc[36:5]};

endmodule
