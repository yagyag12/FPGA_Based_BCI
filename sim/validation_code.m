% 1. .mat dosyasından etiketleri yükle
load('extracted_labels.mat'); 
labels = double(labels);
% 2. out_class_labels.txt dosyasından tahminleri yükle
predictions = load("out_class_labels.txt");
correct = 0;
check = 0;
% 3. Accuracy hesapla
for i = 1:9745
check = predictions(i) == labels(i);
correct = correct + check;
end
accuracy = correct / length(labels);
fprintf("Accuracy: %.2f%%\n", accuracy * 100);

% 4. Confusion Matrix göster
figure;
confusionchart(labels, predictions);
title('Confusion Matrix');
