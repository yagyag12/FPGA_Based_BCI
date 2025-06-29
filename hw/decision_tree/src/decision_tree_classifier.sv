/************************************************************/
//      D E C I S I O N   T R E E   C L A S S I F I E R     //
//                                                          //
//  Desc: Pre-trained binary decision tree algorithm for    //
//  eye state classification                                //
/************************************************************/
`timescale 1ns / 1ps

module decision_tree_classifier (
    input   wire    clk,
    input   wire    rst,
    input   wire    start,
    input   signed  [31:0]  psd_gamma,
    input   signed  [31:0]  psd_beta,
    input   signed  [31:0]  psd_alpha,
    input   signed  [31:0]  psd_theta,
    input   signed  [31:0]  psd_delta,
    input   signed  [31:0]  peak_amplitude,
    input           [ 7:0]  zero_counter,
    input   signed  [31:0]  dwt_gamma_max,
    input   signed  [31:0]  dwt_gamma_min,
    input   signed  [31:0]  dwt_gamma_mean,
    input   signed  [31:0]  dwt_gamma_sum,
    input   signed  [31:0]  dwt_beta_max,
    input   signed  [31:0]  dwt_beta_min,
    input   signed  [31:0]  dwt_beta_mean,
    input   signed  [31:0]  dwt_beta_sum,
    input   signed  [31:0]  dwt_alpha_max,
    input   signed  [31:0]  dwt_alpha_min,
    input   signed  [31:0]  dwt_alpha_mean,
    input   signed  [31:0]  dwt_alpha_sum,
    input   signed  [31:0]  dwt_theta_max,
    input   signed  [31:0]  dwt_theta_min,
    input   signed  [31:0]  dwt_theta_mean,
    input   signed  [31:0]  dwt_theta_sum,
    input   signed  [31:0]  dwt_delta_max,
    input   signed  [31:0]  dwt_delta_min,
    input   signed  [31:0]  dwt_delta_mean,
    input   signed  [31:0]  dwt_delta_sum,
    output  reg             done,
    output  reg     [3:0]   class_label,
    output  reg     [63:0]  timer
);

/***********************  SIGNALS  **************************/

wire signed [31:0] zero_counter_extended;
wire signed [31:0] feature_vector_w         [0:26];
reg  signed [31:0] feature_vector_reg       [0:26];
logic              S_IDLE                   = 1'b0;
logic              S_COMPARE                = 1'b1;
reg                state;
logic       [7:0]  node_addr;
integer i;

// Tree Node
typedef struct packed {
    logic                   is_leaf;
    logic           [4:0]   feature_idx;
    logic   signed  [31:0]  threshold;
    logic           [7:0]   left_node_addr;
    logic           [7:0]   right_node_addr;
    logic           [3:0]   node_label;
} node_data;

node_data tree_node;

/********************  FEATURE VECTOR  **********************/

assign zero_counter_extended = {24'd0, zero_counter};
assign feature_vector_w[0]  = psd_gamma;
assign feature_vector_w[1]  = psd_beta;
assign feature_vector_w[2]  = psd_alpha;
assign feature_vector_w[3]  = psd_theta;
assign feature_vector_w[4]  = psd_delta;
assign feature_vector_w[5]  = peak_amplitude;
assign feature_vector_w[6]  = zero_counter_extended;
assign feature_vector_w[7]  = dwt_gamma_max;
assign feature_vector_w[8]  = dwt_gamma_min;
assign feature_vector_w[9]  = dwt_gamma_mean;
assign feature_vector_w[10] = dwt_gamma_sum;
assign feature_vector_w[11] = dwt_beta_max;
assign feature_vector_w[12] = dwt_beta_min;
assign feature_vector_w[13] = dwt_beta_mean;
assign feature_vector_w[14] = dwt_beta_sum;
assign feature_vector_w[15] = dwt_alpha_max;
assign feature_vector_w[16] = dwt_alpha_min;
assign feature_vector_w[17] = dwt_alpha_mean;
assign feature_vector_w[18] = dwt_alpha_sum;
assign feature_vector_w[19] = dwt_theta_max;
assign feature_vector_w[20] = dwt_theta_min;
assign feature_vector_w[21] = dwt_theta_mean;
assign feature_vector_w[22] = dwt_theta_sum;
assign feature_vector_w[23] = dwt_delta_max;
assign feature_vector_w[24] = dwt_delta_min;
assign feature_vector_w[25] = dwt_delta_mean;
assign feature_vector_w[26] = dwt_delta_sum;

/***********************  TREE ROM  *************************/

always_comb begin
    unique case (node_addr) 
        8'd0:   begin tree_node = '{1'b0, 5'd5, 32'sd145984465, 8'd1, 8'd2, 4'd0};       end
        8'd1:   begin tree_node = '{1'b0, 5'd6, 32'sd40, 8'd3, 8'd4, 4'd0};               end
        8'd2:   begin tree_node = '{1'b0, 5'd3, 32'sd754201, 8'd5, 8'd6, 4'd0}; end
        8'd3:   begin tree_node = '{1'b0, 5'd2, 32'sd703357, 8'd7, 8'd8, 4'd0}; end
        8'd4:   begin tree_node = '{1'b0, 5'd0, 32'sd1370908, 8'd9, 8'd10, 4'd0}; end
        8'd5:   begin tree_node = '{1'b0, 5'd15, 32'sd165487211, 8'd11, 8'd12, 4'd0}; end
        8'd6:   begin tree_node = '{1'b0, 5'd0, 32'sd1919423, 8'd13, 8'd14, 4'd0}; end
        8'd7:   begin tree_node = '{1'b0, 5'd11, 32'sd82033567, 8'd15, 8'd16, 4'd0}; end
        8'd8:   begin tree_node = '{1'b0, 5'd6, 32'sd28, 8'd17, 8'd18, 4'd0}; end
        8'd9:   begin tree_node = '{1'b0, 5'd5, 32'sd112447901, 8'd19, 8'd20, 4'd0}; end
        8'd10:  begin tree_node = '{1'b0, 5'd10, 32'sd26152231, 8'd21, 8'd22, 4'd0}; end
        8'd11:  begin tree_node = '{1'b0, 5'd8, -32'sd102109119, 8'd23, 8'd24, 4'd0}; end
        8'd12:  begin tree_node = '{1'b0, 5'd11, 32'sd167871929, 8'd25, 8'd26, 4'd0}; end
        8'd13:  begin tree_node = '{1'b0, 5'd1, 32'sd6920256, 8'd27, 8'd28, 4'd0}; end
        8'd14:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd15:  begin tree_node = '{1'b0, 5'd7, 32'sd65438014, 8'd29, 8'd30, 4'd0}; end
        8'd16:  begin tree_node = '{1'b0, 5'd0, 32'sd2994797, 8'd31, 8'd32, 4'd0}; end
        8'd17:  begin tree_node = '{1'b0, 5'd6, 32'sd17, 8'd33, 8'd34, 4'd0}; end
        8'd18:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd19:  begin tree_node = '{1'b0, 5'd6, 32'sd49, 8'd35, 8'd36, 4'd0}; end
        8'd20:  begin tree_node = '{1'b0, 5'd16, -32'sd59088209, 8'd37, 8'd38, 4'd0}; end
        8'd21:  begin tree_node = '{1'b0, 5'd5, 32'sd105453043, 8'd39, 8'd40, 4'd0}; end
        8'd22:  begin tree_node = '{1'b0, 5'd5, 32'sd110049603, 8'd41, 8'd42, 4'd0}; end
        8'd23:  begin tree_node = '{1'b0, 5'd5, 32'sd192959015, 8'd43, 8'd44, 4'd0}; end
        8'd24:  begin tree_node = '{1'b0, 5'd1, 32'sd4991638, 8'd45, 8'd46, 4'd0}; end
        8'd25:  begin tree_node = '{1'b0, 5'd5, 32'sd149485014, 8'd47, 8'd48, 4'd0}; end
        8'd26:  begin tree_node = '{1'b0, 5'd19, 32'sd89924686, 8'd49, 8'd50, 4'd0}; end
        8'd27:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd28:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd29:  begin tree_node = '{1'b0, 5'd1, 32'sd3025512, 8'd51, 8'd52, 4'd0}; end
        8'd30:  begin tree_node = '{1'b0, 5'd2, 32'sd128415, 8'd53, 8'd54, 4'd0}; end
        8'd31:  begin tree_node = '{1'b0, 5'd16, -32'sd263668372, 8'd55, 8'd56, 4'd0}; end
        8'd32:  begin tree_node = '{1'b0, 5'd16, -32'sd92713851, 8'd57, 8'd58, 4'd0}; end
        8'd33:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd34:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd35:  begin tree_node = '{1'b0, 5'd4, 32'sd633939, 8'd59, 8'd60, 4'd0}; end
        8'd36:  begin tree_node = '{1'b0, 5'd2, 32'sd215002, 8'd61, 8'd62, 4'd0}; end
        8'd37:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd38:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd39:  begin tree_node = '{1'b0, 5'd7, 32'sd114394300, 8'd63, 8'd64, 4'd0}; end
        8'd40:  begin tree_node = '{1'b0, 5'd12, -32'sd96510523, 8'd65, 8'd66, 4'd0}; end
        8'd41:  begin tree_node = '{1'b0, 5'd6, 32'sd50, 8'd67, 8'd68, 4'd0}; end
        8'd42:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd43:  begin tree_node = '{1'b0, 5'd6, 32'sd33, 8'd69, 8'd70, 4'd0}; end
        8'd44:  begin tree_node = '{1'b0, 5'd11, 32'sd127562425, 8'd71, 8'd72, 4'd0}; end
        8'd45:  begin tree_node = '{1'b0, 5'd1, 32'sd4378543, 8'd73, 8'd74, 4'd0}; end
        8'd46:  begin tree_node = '{1'b0, 5'd6, 32'sd38, 8'd75, 8'd76, 4'd0}; end
        8'd47:  begin tree_node = '{1'b0, 5'd0, 32'sd1217277, 8'd77, 8'd78, 4'd0}; end
        8'd48:  begin tree_node = '{1'b0, 5'd3, 32'sd32866, 8'd79, 8'd80, 4'd0}; end
        8'd49:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd50:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd51:  begin tree_node = '{1'b0, 5'd0, 32'sd2688027, 8'd81, 8'd82, 4'd0}; end
        8'd52:  begin tree_node = '{1'b0, 5'd18, 32'sd44097402, 8'd83, 8'd84, 4'd0}; end
        8'd53:  begin tree_node = '{1'b0, 5'd26, 32'sd76125584, 8'd85, 8'd86, 4'd0}; end
        8'd54:  begin tree_node = '{1'b0, 5'd4, 32'sd1343231, 8'd87, 8'd88, 4'd0}; end
        8'd55:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd56:  begin tree_node = '{1'b0, 5'd5, 32'sd75604453, 8'd89, 8'd90, 4'd0}; end
        8'd57:  begin tree_node = '{1'b0, 5'd2, 32'sd463859, 8'd91, 8'd92, 4'd0}; end
        8'd58:  begin tree_node = '{1'b0, 5'd5, 32'sd94098117, 8'd93, 8'd94, 4'd0}; end
        8'd59:  begin tree_node = '{1'b0, 5'd6, 32'sd47, 8'd95, 8'd96, 4'd0}; end
        8'd60:  begin tree_node = '{1'b0, 5'd1, 32'sd3143694, 8'd97, 8'd98, 4'd0}; end
        8'd61:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd62:  begin tree_node = '{1'b0, 5'd0, 32'sd1366078, 8'd99, 8'd100, 4'd0}; end
        8'd63:  begin tree_node = '{1'b0, 5'd23, 32'sd144744219, 8'd101, 8'd102, 4'd0}; end
        8'd64:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd65:  begin tree_node = '{1'b0, 5'd1, 32'sd6257570, 8'd103, 8'd104, 4'd0}; end
        8'd66:  begin tree_node = '{1'b0, 5'd0, 32'sd1604313, 8'd105, 8'd106, 4'd0}; end
        8'd67:  begin tree_node = '{1'b0, 5'd7, 32'sd61825683, 8'd107, 8'd108, 4'd0}; end
        8'd68:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd69:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd70:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd71:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd72:  begin tree_node = '{1'b0, 5'd0, 32'sd1800747, 8'd109, 8'd110, 4'd0}; end
        8'd73:  begin tree_node = '{1'b0, 5'd2, 32'sd669194, 8'd111, 8'd112, 4'd0}; end
        8'd74:  begin tree_node = '{1'b0, 5'd3, 32'sd80213, 8'd113, 8'd114, 4'd0}; end
        8'd75:  begin tree_node = '{1'b0, 5'd3, 32'sd559135, 8'd115, 8'd116, 4'd0}; end
        8'd76:  begin tree_node = '{1'b0, 5'd0, 32'sd3140963, 8'd117, 8'd118, 4'd0}; end
        8'd77:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd78:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd79:  begin tree_node = '{1'b0, 5'd2, 32'sd239630, 8'd119, 8'd120, 4'd0}; end
        8'd80:  begin tree_node = '{1'b0, 5'd7, 32'sd131577013, 8'd121, 8'd122, 4'd0}; end
        8'd81:  begin tree_node = '{1'b0, 5'd4, 32'sd1686486, 8'd123, 8'd124, 4'd0}; end
        8'd82:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd83:  begin tree_node = '{1'b0, 5'd2, 32'sd541499, 8'd125, 8'd126, 4'd0}; end
        8'd84:  begin tree_node = '{1'b0, 5'd5, 32'sd105453043, 8'd127, 8'd128, 4'd0}; end
        8'd85:  begin tree_node = '{1'b0, 5'd16, -32'sd76544730, 8'd129, 8'd130, 4'd0}; end
        8'd86:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd87:  begin tree_node = '{1'b0, 5'd9, 32'sd1560615, 8'd131, 8'd132, 4'd0}; end
        8'd88:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd89:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd90:  begin tree_node = '{1'b0, 5'd4, 32'sd2312553, 8'd133, 8'd134, 4'd0}; end
        8'd91:  begin tree_node = '{1'b0, 5'd2, 32'sd126855, 8'd135, 8'd136, 4'd0}; end
        8'd92:  begin tree_node = '{1'b0, 5'd10, 32'sd28159081, 8'd137, 8'd138, 4'd0}; end
        8'd93:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd94:  begin tree_node = '{1'b0, 5'd10, 32'sd27449297, 8'd139, 8'd140, 4'd0}; end
        8'd95:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd96:  begin tree_node = '{1'b0, 5'd0, 32'sd815035, 8'd141, 8'd142, 4'd0}; end
        8'd97:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd98:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd99:  begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd100: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd101: begin tree_node = '{1'b0, 5'd0, 32'sd1501151, 8'd143, 8'd144, 4'd0}; end
        8'd102: begin tree_node = '{1'b0, 5'd2, 32'sd615941, 8'd145, 8'd146, 4'd0}; end
        8'd103: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd104: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd105: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd106: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd107: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd108: begin tree_node = '{1'b0, 5'd2, 32'sd652852, 8'd147, 8'd148, 4'd0}; end
        8'd109: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd110: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd111: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd112: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd113: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd114: begin tree_node = '{1'b0, 5'd4, 32'sd252198, 8'd149, 8'd150, 4'd0}; end
        8'd115: begin tree_node = '{1'b0, 5'd21, -32'sd21042471, 8'd151, 8'd152, 4'd0}; end
        8'd116: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd117: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd118: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd119: begin tree_node = '{1'b0, 5'd0, 32'sd1182274, 8'd153, 8'd154, 4'd0}; end
        8'd120: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd121: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd122: begin tree_node = '{1'b0, 5'd7, 32'sd134226977, 8'd155, 8'd156, 4'd0}; end
        8'd123: begin tree_node = '{1'b0, 5'd14, 32'sd21858356, 8'd157, 8'd158, 4'd0}; end
        8'd124: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd125: begin tree_node = '{1'b0, 5'd0, 32'sd875487, 8'd159, 8'd160, 4'd0}; end
        8'd126: begin tree_node = '{1'b0, 5'd3, 32'sd95329, 8'd161, 8'd162, 4'd0}; end
        8'd127: begin tree_node = '{1'b0, 5'd14, 32'sd25273349, 8'd163, 8'd164, 4'd0}; end
        8'd128: begin tree_node = '{1'b0, 5'd2, 32'sd244508, 8'd165, 8'd166, 4'd0}; end
        8'd129: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd130: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd131: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd132: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd133: begin tree_node = '{1'b0, 5'd12, -32'sd147598970, 8'd167, 8'd168, 4'd0}; end
        8'd134: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd135: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd136: begin tree_node = '{1'b0, 5'd1, 32'sd3504967, 8'd169, 8'd170, 4'd0}; end
        8'd137: begin tree_node = '{1'b0, 5'd0, 32'sd3041874, 8'd171, 8'd172, 4'd0}; end
        8'd138: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd139: begin tree_node = '{1'b0, 5'd12, -32'sd59379567, 8'd173, 8'd174, 4'd0}; end
        8'd140: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd141: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd142: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd143: begin tree_node = '{1'b0, 5'd17, -32'sd1310241, 8'd175, 8'd176, 4'd0}; end
        8'd144: begin tree_node = '{1'b0, 5'd4, 32'sd1322965, 8'd177, 8'd178, 4'd0}; end
        8'd145: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd146: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd147: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd148: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd149: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd150: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd151: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd152: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd153: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd154: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd155: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd156: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd157: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd158: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd159: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd160: begin tree_node = '{1'b0, 5'd3, 32'sd402215, 8'd179, 8'd180, 4'd0}; end
        8'd161: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd162: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd163: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd164: begin tree_node = '{1'b0, 5'd5, 32'sd84867325, 8'd181, 8'd182, 4'd0}; end
        8'd165: begin tree_node = '{1'b0, 5'd5, 32'sd129352280, 8'd183, 8'd184, 4'd0}; end
        8'd166: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd167: begin tree_node = '{1'b0, 5'd6, 32'sd34, 8'd185, 8'd186, 4'd0}; end
        8'd168: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd169: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd170: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd171: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd172: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd173: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd174: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd175: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd176: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd177: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd178: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd179: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd180: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd181: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd182: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd183: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd184: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd185: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd1}; end
        8'd186: begin tree_node = '{1'b1, 5'd0, 32'sd0, 8'd0, 8'd0, 4'd0}; end
        8'd187: begin tree_node = '{default: '0}; end 
    endcase
end
  
/**********************  CLASSIFIER  ************************/

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        state       <= S_IDLE;
        node_addr   <= 0;
        done        <= 0;
        class_label <= 0;
        timer       <= 0;
        for (i = 0; i < 27; i = i + 1) begin
            feature_vector_reg[i] <= 0;    
        end
    end else begin
        timer <= timer + 1;
        case (state)
            S_IDLE: begin
                done <= 0;
                if (start) begin
                    node_addr   <= 0;
                    state       <= S_COMPARE;
                    for (i = 0; i < 27; i = i + 1) begin
                        feature_vector_reg[i] <= feature_vector_w[i];    
                    end
                end
            end

            S_COMPARE: begin
                if (tree_node.is_leaf) begin
                    class_label <= tree_node.node_label;
                    done        <= 1;
                    state       <= S_IDLE;
                    timer       <= 0;
                end 
                else begin
                    if ($signed(feature_vector_reg[tree_node.feature_idx]) <= $signed(tree_node.threshold)) begin
                        node_addr <= tree_node.left_node_addr;
                    end    
                    else begin
                        node_addr <= tree_node.right_node_addr;
                    end
                end
            end
        endcase
    end
end

endmodule

