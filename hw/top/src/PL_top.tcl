
################################################################
# This is a generated script based on design: PL_top
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source PL_top_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
   set_property BOARD_PART digilentinc.com:zybo-z7-20:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name PL_top

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
itu:EEGLib:adc_sampler:v0.0.3\
itu:EEGLib:adc_test:v0.0.3\
xilinx.com:ip:ila:6.2\
xilinx.com:ip:blk_mem_gen:8.4\
itu:EEGLib:preprocesser_top_v2:v2.0.3\
itu:EEGLib:feature_extraction_top:v0.1.0\
tbt:EEG_Lib:decision_tree_classifier:v0.0.2\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set i_enable [ create_bd_port -dir I i_enable ]
  set i_rst [ create_bd_port -dir I -type rst i_rst ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $i_rst
  set i_clk [ create_bd_port -dir I -type clk -freq_hz 100000000 i_clk ]
  set class_label [ create_bd_port -dir O -from 3 -to 0 -type data class_label ]
  set done [ create_bd_port -dir O -type data done ]

  # Create instance: adc_sampler_0, and set properties
  set adc_sampler_0 [ create_bd_cell -type ip -vlnv itu:EEGLib:adc_sampler:v0.0.3 adc_sampler_0 ]
  set_property CONFIG.TARGET_FREQ {100000} $adc_sampler_0


  # Create instance: adc_test_0, and set properties
  set adc_test_0 [ create_bd_cell -type ip -vlnv itu:EEGLib:adc_test:v0.0.3 adc_test_0 ]
  set_property CONFIG.ADDR_VAL {10000} $adc_test_0


  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0 ]
  set_property -dict [list \
    CONFIG.C_DATA_DEPTH {4096} \
    CONFIG.C_MONITOR_TYPE {Native} \
    CONFIG.C_NUM_OF_PROBES {13} \
    CONFIG.C_PROBE0_WIDTH {32} \
    CONFIG.C_PROBE12_WIDTH {32} \
    CONFIG.C_PROBE13_WIDTH {1} \
    CONFIG.C_PROBE14_WIDTH {1} \
    CONFIG.C_PROBE15_WIDTH {1} \
    CONFIG.C_PROBE16_WIDTH {1} \
    CONFIG.C_PROBE17_WIDTH {1} \
    CONFIG.C_PROBE18_WIDTH {1} \
    CONFIG.C_PROBE19_WIDTH {1} \
    CONFIG.C_PROBE1_WIDTH {8} \
    CONFIG.C_PROBE2_WIDTH {32} \
    CONFIG.C_PROBE3_WIDTH {32} \
    CONFIG.C_PROBE4_WIDTH {32} \
    CONFIG.C_PROBE5_WIDTH {32} \
    CONFIG.C_PROBE6_WIDTH {32} \
    CONFIG.C_PROBE8_WIDTH {32} \
    CONFIG.C_PROBE9_WIDTH {4} \
    CONFIG.C_SLOT_0_AXI_PROTOCOL {AXI4LITE} \
  ] $ila_0


  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_1 ]
  set_property -dict [list \
    CONFIG.Coe_File {c:/Users/yagiz/OneDrive/Belgeler/GitHub/BrainComputerInterface/MatlabSim/EEG_Matlab/data.coe} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Memory_Type {Single_Port_ROM} \
    CONFIG.Write_Depth_A {10000} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $blk_mem_gen_1


  # Create instance: preprocesser_top_v2_0, and set properties
  set preprocesser_top_v2_0 [ create_bd_cell -type ip -vlnv itu:EEGLib:preprocesser_top_v2:v2.0.3 preprocesser_top_v2_0 ]

  # Create instance: feature_extraction_t_1, and set properties
  set feature_extraction_t_1 [ create_bd_cell -type ip -vlnv itu:EEGLib:feature_extraction_top:v0.1.0 feature_extraction_t_1 ]

  # Create instance: decision_tree_classi_0, and set properties
  set decision_tree_classi_0 [ create_bd_cell -type ip -vlnv tbt:EEG_Lib:decision_tree_classifier:v0.0.2 decision_tree_classi_0 ]

  # Create port connections
  connect_bd_net -net Net [get_bd_ports i_rst] [get_bd_pins adc_test_0/rst] [get_bd_pins adc_sampler_0/rst] [get_bd_pins decision_tree_classi_0/rst] [get_bd_pins preprocesser_top_v2_0/rst] [get_bd_pins feature_extraction_t_1/rst]
  connect_bd_net -net Net1 [get_bd_ports i_clk] [get_bd_pins ila_0/clk] [get_bd_pins adc_sampler_0/clk] [get_bd_pins decision_tree_classi_0/clk] [get_bd_pins preprocesser_top_v2_0/clk] [get_bd_pins feature_extraction_t_1/clk]
  connect_bd_net -net adc_sampler_0_sample_out [get_bd_pins adc_sampler_0/sample_out] [get_bd_pins ila_0/probe8] [get_bd_pins preprocesser_top_v2_0/in_signal]
  connect_bd_net -net adc_test_0_addr [get_bd_pins adc_test_0/addr] [get_bd_pins blk_mem_gen_1/addra]
  connect_bd_net -net blk_mem_gen_1_douta [get_bd_pins blk_mem_gen_1/douta] [get_bd_pins adc_sampler_0/adc_in]
  connect_bd_net -net decision_tree_classi_0_class_label [get_bd_pins decision_tree_classi_0/class_label] [get_bd_pins ila_0/probe9] [get_bd_ports class_label]
  connect_bd_net -net decision_tree_classi_0_done [get_bd_pins decision_tree_classi_0/done] [get_bd_pins ila_0/probe11] [get_bd_ports done]
  connect_bd_net -net feature_extraction_t_1_dwt_alpha_max [get_bd_pins feature_extraction_t_1/dwt_alpha_max] [get_bd_pins decision_tree_classi_0/dwt_alpha_max]
  connect_bd_net -net feature_extraction_t_1_dwt_alpha_mean [get_bd_pins feature_extraction_t_1/dwt_alpha_mean] [get_bd_pins decision_tree_classi_0/dwt_alpha_mean]
  connect_bd_net -net feature_extraction_t_1_dwt_alpha_min [get_bd_pins feature_extraction_t_1/dwt_alpha_min] [get_bd_pins decision_tree_classi_0/dwt_alpha_min]
  connect_bd_net -net feature_extraction_t_1_dwt_alpha_sum [get_bd_pins feature_extraction_t_1/dwt_alpha_sum] [get_bd_pins decision_tree_classi_0/dwt_alpha_sum]
  connect_bd_net -net feature_extraction_t_1_dwt_beta_max [get_bd_pins feature_extraction_t_1/dwt_beta_max] [get_bd_pins ila_0/probe3] [get_bd_pins decision_tree_classi_0/dwt_beta_max]
  connect_bd_net -net feature_extraction_t_1_dwt_beta_mean [get_bd_pins feature_extraction_t_1/dwt_beta_mean] [get_bd_pins ila_0/probe5] [get_bd_pins decision_tree_classi_0/dwt_beta_mean]
  connect_bd_net -net feature_extraction_t_1_dwt_beta_min [get_bd_pins feature_extraction_t_1/dwt_beta_min] [get_bd_pins ila_0/probe6] [get_bd_pins decision_tree_classi_0/dwt_beta_min]
  connect_bd_net -net feature_extraction_t_1_dwt_beta_sum [get_bd_pins feature_extraction_t_1/dwt_beta_sum] [get_bd_pins ila_0/probe4] [get_bd_pins decision_tree_classi_0/dwt_beta_sum]
  connect_bd_net -net feature_extraction_t_1_dwt_delta_max [get_bd_pins feature_extraction_t_1/dwt_delta_max] [get_bd_pins decision_tree_classi_0/dwt_delta_max]
  connect_bd_net -net feature_extraction_t_1_dwt_delta_mean [get_bd_pins feature_extraction_t_1/dwt_delta_mean] [get_bd_pins decision_tree_classi_0/dwt_delta_mean]
  connect_bd_net -net feature_extraction_t_1_dwt_delta_min [get_bd_pins feature_extraction_t_1/dwt_delta_min] [get_bd_pins decision_tree_classi_0/dwt_delta_min]
  connect_bd_net -net feature_extraction_t_1_dwt_delta_sum [get_bd_pins feature_extraction_t_1/dwt_delta_sum] [get_bd_pins decision_tree_classi_0/dwt_delta_sum]
  connect_bd_net -net feature_extraction_t_1_dwt_gamma_max [get_bd_pins feature_extraction_t_1/dwt_gamma_max] [get_bd_pins decision_tree_classi_0/dwt_gamma_max]
  connect_bd_net -net feature_extraction_t_1_dwt_gamma_mean [get_bd_pins feature_extraction_t_1/dwt_gamma_mean] [get_bd_pins decision_tree_classi_0/dwt_gamma_mean]
  connect_bd_net -net feature_extraction_t_1_dwt_gamma_min [get_bd_pins feature_extraction_t_1/dwt_gamma_min] [get_bd_pins decision_tree_classi_0/dwt_gamma_min]
  connect_bd_net -net feature_extraction_t_1_dwt_gamma_sum [get_bd_pins feature_extraction_t_1/dwt_gamma_sum] [get_bd_pins decision_tree_classi_0/dwt_gamma_sum]
  connect_bd_net -net feature_extraction_t_1_dwt_theta_max [get_bd_pins feature_extraction_t_1/dwt_theta_max] [get_bd_pins decision_tree_classi_0/dwt_theta_max]
  connect_bd_net -net feature_extraction_t_1_dwt_theta_mean [get_bd_pins feature_extraction_t_1/dwt_theta_mean] [get_bd_pins decision_tree_classi_0/dwt_theta_mean]
  connect_bd_net -net feature_extraction_t_1_dwt_theta_min [get_bd_pins feature_extraction_t_1/dwt_theta_min] [get_bd_pins decision_tree_classi_0/dwt_theta_min]
  connect_bd_net -net feature_extraction_t_1_dwt_theta_sum [get_bd_pins feature_extraction_t_1/dwt_theta_sum] [get_bd_pins decision_tree_classi_0/dwt_theta_sum]
  connect_bd_net -net feature_extraction_t_1_peak_amplitude [get_bd_pins feature_extraction_t_1/peak_amplitude] [get_bd_pins ila_0/probe0] [get_bd_pins decision_tree_classi_0/peak_amplitude]
  connect_bd_net -net feature_extraction_t_1_psd_alpha [get_bd_pins feature_extraction_t_1/psd_alpha] [get_bd_pins decision_tree_classi_0/psd_alpha]
  connect_bd_net -net feature_extraction_t_1_psd_beta [get_bd_pins feature_extraction_t_1/psd_beta] [get_bd_pins ila_0/probe2] [get_bd_pins decision_tree_classi_0/psd_beta]
  connect_bd_net -net feature_extraction_t_1_psd_delta [get_bd_pins feature_extraction_t_1/psd_delta] [get_bd_pins decision_tree_classi_0/psd_delta]
  connect_bd_net -net feature_extraction_t_1_psd_gamma [get_bd_pins feature_extraction_t_1/psd_gamma] [get_bd_pins decision_tree_classi_0/psd_gamma]
  connect_bd_net -net feature_extraction_t_1_psd_theta [get_bd_pins feature_extraction_t_1/psd_theta] [get_bd_pins decision_tree_classi_0/psd_theta]
  connect_bd_net -net feature_extraction_t_1_valid [get_bd_pins feature_extraction_t_1/valid] [get_bd_pins ila_0/probe7] [get_bd_pins decision_tree_classi_0/start]
  connect_bd_net -net feature_extraction_t_1_zero_counter [get_bd_pins feature_extraction_t_1/zero_counter] [get_bd_pins ila_0/probe1] [get_bd_pins decision_tree_classi_0/zero_counter]
  connect_bd_net -net preprocesser_top_v2_0_new_sample_flag [get_bd_pins preprocesser_top_v2_0/new_sample_flag] [get_bd_pins feature_extraction_t_1/new_sample_flag]
  connect_bd_net -net preprocesser_top_v2_0_out_signal [get_bd_pins preprocesser_top_v2_0/out_signal] [get_bd_pins feature_extraction_t_1/data_in]
  connect_bd_net -net preprocesser_top_v2_0_valid [get_bd_ports i_enable] [get_bd_pins ila_0/probe10] [get_bd_pins preprocesser_top_v2_0/enable] [get_bd_pins feature_extraction_t_1/en]
  connect_bd_net -net preprocesser_top_v2_0_valid1 [get_bd_pins preprocesser_top_v2_0/valid] [get_bd_pins feature_extraction_t_1/in_valid]
  connect_bd_net -net util_ds_buf_0_BUFGCE_O [get_bd_pins adc_sampler_0/sample_clk] [get_bd_pins blk_mem_gen_1/clka] [get_bd_pins adc_test_0/clk] [get_bd_pins preprocesser_top_v2_0/sampling_clk]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


