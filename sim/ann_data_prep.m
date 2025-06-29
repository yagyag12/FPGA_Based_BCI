% DATA PREPARATION FOR ANN NETWORK
%% Data Loading
Fs = 256; % Sampling frequency
filename = 'eeg_eye_state.arff';
fid = fopen(filename, 'r');
data = [];

% Loop through each line in the file
while ~feof(fid)
    line = fgetl(fid);
    
    if startsWith(line, '@')
        continue;
    end
    
    if ~isempty(line)
        row = strsplit(line, ',');
        row = cellfun(@(x) str2double(x), row, 'UniformOutput', false);
        data = [data; row];
    end
end

fclose(fid);

% Convert to a table and save
dataTable = cell2table(data);
save('eye_state_data.mat', 'dataTable');

%% Select EEG Channels to Use
channels = {'data1', 'data2', 'data3', 'data4'}; % available channels
selected_channel = channels{1}; 
signals = struct();
signals.(selected_channel) = dataTable{:, 4};  % use first column (data1)
labels = dataTable{:, end}; % Extract labels (the last column)

%% Preprocessing
load('H_notch.mat');    % Notch filter object
load('H_lowpass.mat');

movingavg_window_size = 16;
spike_threshold = 5000;

% Process the selected channel
signal = signals.(selected_channel);
signal(signal > spike_threshold) = 0; %mean(signal);       % Spike filtering
%notch_filtered_signal = filter(H_notch, signal);      % Notch filter
lowpass = movmean(signal, 128);
movdiff_filtered_signal = signal - lowpass;
lpf = H_lowpass.Numerator;
processed_signal = filter(lpf,1, movdiff_filtered_signal);
processed_signal = movmean(processed_signal, movingavg_window_size);

% Save the processed signal and labels in a struct 
processed_signals = struct();
processed_signals.(selected_channel) = processed_signal;
processed_signals.labels = labels;

save("preprocessed_datamem.mat", "processed_signals");

%Plot the Data
figure;
plot(processed_signals.data1(1:10000), 'b');
title('Raw EEG Signal');
xlabel('Sample Index');
ylabel('Amplitude');
grid on;

%% Windowing
window_size = 256;
overlap = 255;
step_size = window_size - overlap;

% Compute number of windows based on the length of the signal
signal_length = length(processed_signals.(selected_channel));
num_windows = floor((signal_length - window_size) / step_size) + 1;

% Window the selected channel’s data
windowed_signals = struct();
windows = struct();
for w = 1:num_windows
    start_idx = (w - 1) * step_size + 1;
    end_idx = start_idx + window_size - 1;
    windows.(['window' num2str(w)]) = processed_signals.(selected_channel)(start_idx:end_idx);
end
windowed_signals.(selected_channel) = windows;

% For each window, use the mode of the labels within the window
label_windows = struct();
for w = 1:num_windows
    start_idx = (w - 1) * step_size + 1;
    end_idx = start_idx + window_size - 1;
    window_labels = processed_signals.labels(start_idx:end_idx);
    label_windows.(['window' num2str(w)]) = mode(window_labels);
end
windowed_signals.labels = label_windows;
save("windowed_labels.mat", "windowed_signals");

%% DWT Feature Extraction
waveletFunction = 'haar';   % Selected wavelet function
decompositionLevel = 5;     % No of decomposition
dwt_results = struct();

windows = windowed_signals.(selected_channel);
windowNames = fieldnames(windows);
signal_dwt = struct();

for j = 1:numel(windowNames)
    window_data = windows.(windowNames{j});
    [C, L] = wavedec(window_data, decompositionLevel, waveletFunction);
    
    % Detail coefficients
    gamma_det = detcoef(C, L, 2);
    beta_det  = detcoef(C, L, 3);
    alpha_det = detcoef(C, L, 4);
    theta_det = detcoef(C, L, 5);

    % Approximation coefficients
    delta_app = appcoef(C, L, waveletFunction, 5);
    
    signal_dwt.(windowNames{j}) = struct(...
        'Gamma_Max',   max(gamma_det),   'Gamma_Min',   min(gamma_det),   'Gamma_Mean',   mean(gamma_det),   'Gamma_AbsSum',   sum(abs(gamma_det)), ...
        'Beta_Max',    max(beta_det),    'Beta_Min',    min(beta_det),    'Beta_Mean',    mean(beta_det),    'Beta_AbsSum',    sum(abs(beta_det)), ...
        'Alpha_Max',   max(alpha_det),   'Alpha_Min',   min(alpha_det),   'Alpha_Mean',   mean(alpha_det),   'Alpha_AbsSum',   sum(abs(alpha_det)), ...
        'Theta_Max',   max(theta_det),   'Theta_Min',   min(theta_det),   'Theta_Mean',   mean(theta_det),   'Theta_AbsSum',   sum(abs(theta_det)), ...
        'Delta_Max',   max(delta_app),   'Delta_Min',   min(delta_app),   'Delta_Mean',   mean(delta_app),   'Delta_AbsSum',   sum(abs(delta_app))  );
end
dwt_results.(selected_channel) = signal_dwt;

%% PSD Feature Extraction
% Frequency bands
bands = struct('Gamma', [32, 64], 'Beta', [12, 30], 'Alpha', [8, 12], 'Theta', [4, 8], 'Delta', [1, 4]);
band_powers = struct();

signal_band_powers = struct();
for j = 1:numel(windowNames)
    window_data = windows.(windowNames{j});
    fft_result = fft(window_data);
    fft_magnitude = abs(fft_result).^2;
    freq = (0:length(fft_magnitude)-1) * (Fs / length(fft_magnitude));
    
    psd_features = struct();
    bandNames = fieldnames(bands);
    for k = 1:numel(bandNames)
        band_range = bands.(bandNames{k});
        band_indices = (freq >= band_range(1)) & (freq <= band_range(2));
        psd_features.(bandNames{k}) = sum(fft_magnitude(band_indices));
    end
    signal_band_powers.(windowNames{j}) = psd_features;
end
band_powers.(selected_channel) = signal_band_powers;

%% Other Features
window_features = struct();
signal_features = struct();
for j = 1:numel(windowNames)
    window_data = windows.(windowNames{j});
    % Zero Crossing Rate (ZCR)
    zcr = sum(abs(diff(window_data > 0))) / length(window_data);
    % Peak Amplitude
    peak_amplitude = max(abs(window_data));
    
    signal_features.(windowNames{j}) = struct('ZCR', zcr, 'PeakAmplitude', peak_amplitude);
end
window_features.(selected_channel) = signal_features;

%% Create Feature Vectors for ANN
% For each window, 27 features are concatenated
feature_matrix = [];
label_vector = [];

for j = 1:numel(windowNames)
    dwt_feat   = struct2array(dwt_results.(selected_channel).(windowNames{j}));
    psd_feat   = struct2array(band_powers.(selected_channel).(windowNames{j}));
    other_feat = struct2array(window_features.(selected_channel).(windowNames{j}));
    features = [dwt_feat, psd_feat, other_feat];
    feature_matrix = [feature_matrix; features];
    
    % Get the label for this window
    label_vector = [label_vector; windowed_signals.labels.(windowNames{j})];
end

save('ann_features.mat', 'feature_matrix', 'label_vector');

%% Load Extracted Features and Create Datastores for ANN

% Convert labels to categorical and ensure column vector format
Y_labels = categorical(label_vector(:));

% Verify that the number of feature rows equals the number of labels
assert(size(feature_matrix, 1) == numel(Y_labels), 'Feature-label mismatch before split!');

% Shuffle the data
numSamples = size(feature_matrix, 1);
idx = randperm(numSamples);

% Split data into Train (80%) and Validation (20%)
numTrain = round(0.8 * numSamples);
train_idx = idx(1:numTrain);
val_idx   = idx(numTrain+1:end);

X_train = feature_matrix(train_idx, :);
Y_train = Y_labels(train_idx);
X_val   = feature_matrix(val_idx, :);
Y_val   = Y_labels(val_idx);
Y_train = reshape(Y_train, [], 1);
Y_val   = reshape(Y_val, [], 1);

% Convert input features to single precision for the ANN
X_train = single(X_train)'; 
X_val = single(X_val)';    

%% Create Datastores for Deep Network Designer
dsX_train = arrayDatastore(X_train, 'IterationDimension', 2);
dsX_val = arrayDatastore(X_val, 'IterationDimension', 2);

dsY_train = arrayDatastore(Y_train, 'IterationDimension', 1);
dsY_val = arrayDatastore(Y_val, 'IterationDimension', 1);

% Combine feature and label datastores
dsTrain = combine(dsX_train, dsY_train);
dsVal = combine(dsX_val, dsY_val);

% Save the datastores for use in Deep Network Designer
save('ann_datastore.mat', 'dsTrain', 'dsVal');
disp('ANN Datastore created successfully.');

%% Test the Designed Network
% The ANN is designed using the Deep Network Designer
load("ann_network.mat");
load("ann_features.mat");
prediction_vector = classify(network, feature_matrix);
label_vector_categorical = categorical(label_vector); 
accuracy = sum(prediction_vector == label_vector_categorical) / numel(label_vector) * 100;
fprintf('Classification Accuracy: %.2f%%\n', accuracy);
