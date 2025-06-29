%% Preprocessed COE File
% Load and Extract EEG data
load("preprocessed_datamem.mat");
data = processed_signals.data1;
signal = data(1:10000, 1);

signal_norm = signal / (max(signal) - min(signal));

signal_int = int32(round(signal_norm * 2^30));

% Open .COE file
fileID = fopen('data.coe', 'w');

% Write COE header
fprintf(fileID, 'memory_initialization_radix=16;\n');
fprintf(fileID, 'memory_initialization_vector=\n');

% Write data in hexadecimal format
for i = 1:length(signal_int)
    if i < length(signal_int)
        fprintf(fileID, '%08X,\n', typecast(signal_int(i), 'uint32')); % HEX with comma
    else
        fprintf(fileID, '%08X;\n', typecast(signal_int(i), 'uint32')); % Last value with semicolon
    end
end

fclose(fileID);
disp('✅ COE file `data.coe` generated successfully!');

%% Raw Data TXT File
% Load and Extract EEG data
load("eye_state_data.mat");
data = dataTable.data1;
signal = data(1:10000, 1);

% Normalize signal
signal_norm = signal / (max(signal) - min(signal));

% Convert to 32-bit signed integer (Q2.30 gibi temsil için)
signal_int = int32(round(signal_norm * 2^30));

% Open .txt file
fileID = fopen('datamem.txt', 'w');

% Write each sample in decimal format (one per line)
for i = 1:length(signal_int)
    fprintf(fileID, '%d\n', signal_int(i));  % Decimal format
end

fclose(fileID);
disp('✅ TXT file `data.txt` generated successfully!');

%% Preprocessed Data TXT File
% Load and Extract EEG data
load("preprocessed_datamem.mat");
data = processed_signals.data1;
signal = data(1:10000, 1);

% Normalize signal
signal_norm = signal / (max(signal) - min(signal));

% Convert to 32-bit signed integer (Q2.30 gibi temsil için)
signal_int = int32(round(signal_norm * 2^30));

% Open .txt file
fileID = fopen('preprocessed_datamem.txt', 'w');

% Write each sample in decimal format (one per line)
for i = 1:length(signal_int)
    fprintf(fileID, '%d\n', signal_int(i));  % Decimal format
end

fclose(fileID);
disp('✅ TXT file `data.txt` generated successfully!');
