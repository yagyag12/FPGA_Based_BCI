% Load extracted features from ANN feature extraction
load('ann_features.mat'); % Loads feature_matrix and label_vector

% Initialize arrays to store features
gamma_max = [];
gamma_min = [];
gamma_mean = [];
gamma_abs = [];

beta_max = [];
beta_min = [];
beta_mean = [];
beta_abs = [];

alpha_max = [];
alpha_min = [];
alpha_mean = [];
alpha_abs = [];

theta_max = [];
theta_min = [];
theta_mean = [];
theta_abs = [];

delta_max = [];
delta_min = [];
delta_mean = [];
delta_abs = [];

psd_gamma = [];
psd_beta = [];
psd_alpha = [];
psd_theta = [];
psd_delta = [];

zeroCross = [];
peakAmp = [];

label = [];

% Process extracted features
num_samples = size(feature_matrix, 1);

for i = 1:num_samples
    % Extract DWT features (20 total)
    gamma_max = [gamma_max; feature_matrix(i, 1)];
    gamma_min = [gamma_min; feature_matrix(i, 2)];
    gamma_mean = [gamma_mean; feature_matrix(i, 3)];
    gamma_abs = [gamma_abs; feature_matrix(i, 4)];
    
    beta_max = [beta_max; feature_matrix(i, 5)];
    beta_min = [beta_min; feature_matrix(i, 6)];
    beta_mean = [beta_mean; feature_matrix(i, 7)];
    beta_abs = [beta_abs; feature_matrix(i, 8)];
    
    alpha_max = [alpha_max; feature_matrix(i, 9)];
    alpha_min = [alpha_min; feature_matrix(i, 10)];
    alpha_mean = [alpha_mean; feature_matrix(i, 11)];
    alpha_abs = [alpha_abs; feature_matrix(i, 12)];
    
    theta_max = [theta_max; feature_matrix(i, 13)];
    theta_min = [theta_min; feature_matrix(i, 14)];
    theta_mean = [theta_mean; feature_matrix(i, 15)];
    theta_abs = [theta_abs; feature_matrix(i, 16)];
    
    delta_max = [delta_max; feature_matrix(i, 17)];
    delta_min = [delta_min; feature_matrix(i, 18)];
    delta_mean = [delta_mean; feature_matrix(i, 19)];
    delta_abs = [delta_abs; feature_matrix(i, 20)];
    
    % Extract PSD features (5 total)
    psd_gamma = [psd_gamma; feature_matrix(i, 21)];
    psd_beta = [psd_beta; feature_matrix(i, 22)];
    psd_alpha = [psd_alpha; feature_matrix(i, 23)];
    psd_theta = [psd_theta; feature_matrix(i, 24)];
    psd_delta = [psd_delta; feature_matrix(i, 25)];
    
    % Extract Other Features (2 total)
    zeroCross = [zeroCross; feature_matrix(i, 26)];
    peakAmp = [peakAmp; feature_matrix(i, 27)];
    
    % Labels
    label = [label; label_vector(i)];
end

% Create final feature table for SVM processing
featureTable2 = table(gamma_max, gamma_min, gamma_mean, gamma_abs, ...
                      beta_max, beta_min, beta_mean, beta_abs, ...
                      alpha_max, alpha_min, alpha_mean, alpha_abs, ...
                      theta_max, theta_min, theta_mean, theta_abs, ...
                      delta_max, delta_min, delta_mean, delta_abs, ...
                      psd_gamma, psd_beta, psd_alpha, psd_theta, psd_delta, ...
                      zeroCross, peakAmp, label, ...
                      'VariableNames', {'Gamma_Max', 'Gamma_Min', 'Gamma_Mean', 'Gamma_Abs', ...
                                        'Beta_Max', 'Beta_Min', 'Beta_Mean', 'Beta_Abs', ...
                                        'Alpha_Max', 'Alpha_Min', 'Alpha_Mean', 'Alpha_Abs', ...
                                        'Theta_Max', 'Theta_Min', 'Theta_Mean', 'Theta_Abs', ...
                                        'Delta_Max', 'Delta_Min', 'Delta_Mean', 'Delta_Abs', ...
                                        'PSD_Gamma', 'PSD_Beta', 'PSD_Alpha', 'PSD_Theta', 'PSD_Delta', ...
                                        'ZeroCross', 'PeakAmp', 'Label'});

disp('Feature table created for SVM:');
disp(featureTable2(1:min(5, height(featureTable2)), :)); % Display first 5 rows

% Save processed feature data
save('svm_features.mat', 'featureTable2');
