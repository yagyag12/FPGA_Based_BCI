# EEG_Eye_State_Classification
FPGA Based EEG Eye State Classification with Machine Learning for Brain-Computer Interface Implementation

## Overview
In the presented graduation project, binary classification of EEG (Electroencephalography) signals was performed using an FPGA (Field Programmable Gate Array)-based embedded system, utilizing various machine learning algorithms. The example application scenario considered in this study is determining whether an individual’s eyes are open or closed. However, the developed system is designed to be adaptable to many other EEG classification problems as well, including seizure detection and motor imagery. The prioritized metrics during the development were real-time performance, low latency and resource efficiency.

## System Architecture
**EEG Preprocessing**
- **biquad_notch_filter.sv:** 50 Hz Notch Filter for powerline noise removal.
- **moving_difference.sv:** 128-tap Moving Difference Filter for preventing baseline wandering.
- **fir_filter.sv:** 16-tap FIR Lowpass Filter for high frequency artifact removal.
- **biquad_highpass_filter.sv** and **moving_average.sv** filters are not used in the final project.

**Feature Extraction**
- **dwt_top.sv:** Extracts the 5-level Discrete Wavelet Transform Haar Wavelet coefficients and their Mean, Max, Min and Sum values.
- **psd_top.sv:** Extracts the powers of 5 EEG frequency bands (delta, theta, alpha, beta, gamma).
- **zcr.sv:** Zero crossing counter.
- **peak.sv:** Calculates the peak amplitude value.

**Classification with Decision Tree**
- **decision.tree.sv:** Pre-trained binary decision tree model, integrated to the hardware for eye state classification.

## Important Files
- **PL_top.tcl** is the top module block diagram script of the system, and the **PL_top_tb.sv** is the top module simulation.
- **adc_sampler.sv** module receives the input data at 256 Hz while creating a 256 Hz clock for the system.
- **adc_test.sv** module with a BRAM containing **data.coe** imitates an ADC input at 256 Hz frequency. 
- **EEGLive.mlx** file is a Matlab Live Script, simulating the preprocessing and feature extraction steps of the project.
- **dwtsim.slx** is a Simulink simulation for Discrete Wavelet Transform decomposition.
- **ann_network.mat** file contains a Matlab Deep Network Designer Artifical Neural Network for eye state classification. **ann_data_prep.m** is used for creating labeled inputs for the network. This approach is later discarded in the Project because of the difficulties in the hardware implementation.
- **/sw** folder contains embedded implementations of SVM and Decision Tree algorithms in C.

## Detailed Information
The thesis is included at **/reports/fpga_based_bci_report** written in Turkish. However, a comprehensive English summary is provided at the end of the document for international accessibility and reference purposes.

