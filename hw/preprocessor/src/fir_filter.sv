/************************************************************/
//          F I R   L O W P A S S   F I L T E R             //
//                                                          //
//  Desc: 16-order FIR lowpass for preprocessing            //
/************************************************************/
`timescale 1ns / 1ps

module fir_lowpass(
    input                   clk, rst, en, validIn,
    input  signed [31:0]    in_signal,
    output logic            valid,
    output signed [31:0]    out_signal
    );

    logic signed [15:0] coeff [0:15] = {        // Q0.15
        -16'sd48,
        -16'sd47,
        16'sd354,
        -16'sd923,
        16'sd1301,
        -16'sd472,
        -16'sd3268,
        16'sd19486,
        16'sd19486,
        -16'sd3268,
        -16'sd472,
        16'sd1301,
        -16'sd923,
        16'sd354,
        -16'sd47,
        -16'sd48
    };

    logic signed [31:0] input_reg [0:15];       // Q2.29
    logic signed [47:0] product [0:15];         // Q2.44
    logic signed [51:0] accumulator_s0 [7:0];
    logic signed [51:0] accumulator_s1 [3:0];
    logic signed [51:0] accumulator_s2 [1:0];
    logic signed [51:0] accumulator_s3;
    
    logic [4:0] counter_for_valid;

    integer i, j, k, l, m;

    // Input Shift Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst | ~en) begin
            for (i = 0; i <= 15; i = i + 1) begin
                input_reg[i] <= 0;
            end
            
            valid <= 0;
            counter_for_valid <= 0;
        end else if (validIn) begin
            counter_for_valid <= counter_for_valid + 1;
            input_reg[0] <= in_signal;
            for (i = 1; i <= 15; i = i + 1) begin
                input_reg[i] <= input_reg[i - 1];
            end  
            
            if (counter_for_valid == 21) begin
                valid <= 1;
                counter_for_valid <= 21;
            end 
        end
    end

    // Product
    always_ff @(posedge clk or posedge rst) begin
        if (rst | ~en) begin
            for (j = 0; j <= 15; j = j + 1) begin
                product[j] <= 0;
            end
        end else if (validIn) begin
            for (j = 0; j <= 15; j = j + 1) begin
                product[j] <= input_reg[j] * coeff[j];
            end           
        end
    end

    // Sum 1st Stage
    always_ff @(posedge clk or posedge rst) begin
        if (rst | ~en) begin
            for (k = 0; k <= 7; k = k + 1) begin
                accumulator_s0[k] <= 0;
            end
        end else if (validIn) begin
            for (k = 0; k <= 7; k = k + 1) begin
                accumulator_s0[k] <= product[2*k] + product[2*k+1];          
            end
        end
    end

    // Sum 2nd Stage
    always_ff @(posedge clk or posedge rst) begin
        if (rst | ~en) begin
            for (l = 0; l <= 3; l = l + 1) begin
                accumulator_s1[l] <= 0;
            end
        end else if (validIn) begin
            for (l = 0; l <= 3; l = l + 1) begin
                accumulator_s1[l] <= accumulator_s0[2*l] + accumulator_s0[2*l+1];          
            end
        end
    end

    // Sum 3rd Stage
    always_ff @(posedge clk or posedge rst) begin
        if (rst | ~en) begin
            for (m = 0; m <= 1; m = m + 1) begin
                accumulator_s2[m] <= 0;
            end
        end else if (validIn) begin
            for (m = 0; m <= 1; m = m + 1) begin
                accumulator_s2[m] <= accumulator_s1[2*m] + accumulator_s1[2*m+1];          
            end
        end
    end    

    // Sum Final Stage
    always_ff @(posedge clk or posedge rst) begin
        if (rst | ~en) begin
            accumulator_s3 <= 0;
        end else if (validIn) begin
            accumulator_s3 <= accumulator_s2[0] + accumulator_s2[1];          
        end
    end

    assign out_signal = {accumulator_s3[51], accumulator_s3[44:14]};

endmodule

