% -------------------------------------------------------------
% Name: Rythm Gagneja
% Roll No: 102218039
% -------------------------------------------------------------
clc; 
clear; 
close all;

disp('Tumor Detection Pipeline Started.');

%% Step 1: Load Input Image and Ground Truth Mask
inputImageName = 'xray1.png';       % Original X-ray
gtMaskName     = 'ground_truth_img.png';  % simulated tumor mask

I = imread(inputImageName);
if size(I,3)==3
    I = rgb2gray(I); % Convert to grayscale if needed
end
I = im2double(I);

% Resize to speed up processing
I = imresize(I, 0.4);
disp('Image loaded and resized.');

% Load Ground Truth Mask
GT = imread(gtMaskName);
GT = im2bw(GT);
GT = imresize(GT, size(I)); 

%% Step 2: Filtering (Noise Removal)
I_med  = medfilt2(I, [3 3]);
I_filt = imgaussfilt(I_med, 1);
disp('Noise removed using Median + Gaussian filter.');

%% Step 3: Contrast Enhancement (Histogram Equalization)
I_enh = adapthisteq(I_filt);
disp('Contrast enhanced using Adaptive Histogram Equalization.');

%% Step 4: Edge Detection (Canny)
edges = edge(I_enh, 'Canny');
disp('Edges detected using Canny operator.');

%% Step 5: Segmentation using K-means
disp('Running K-means segmentation.');
numClusters = 3;
[H, W] = size(I_enh);
X = I_enh(:);

% Optimized K-means 
[idx, ~] = kmeans(X, numClusters, 'MaxIter', 100, 'Replicates', 1);
seg = reshape(idx, [H, W]);

% Select cluster with highest mean intensity (brightest region)
means = accumarray(idx, X) ./ accumarray(idx, 1);
[~, tumorCluster] = max(means);
mask = seg == tumorCluster;
disp('Segmentation complete.');

%% Step 6: Post-processing 
mask = imfill(mask, 'holes');
mask = bwareaopen(mask, 200);
mask = imclose(mask, strel('disk',3));
disp('Post-processing done.');

%% Step 7: Performance Metrics
TP = sum((mask == 1)&(GT == 1),'all');
FP = sum((mask == 1)&(GT == 0),'all');
FN = sum((mask == 0)&(GT == 1),'all');
TN = sum((mask == 0)&(GT == 0),'all');

accuracy = (TP + TN)/(TP + TN + FP + FN);
sensitivity = TP/(TP + FN + eps);
dice = (2 * TP)/(2 * TP + FP + FN + eps);

fprintf('\n Performance Metrics\n');
fprintf('   Accuracy: %.3f\n', accuracy);
fprintf('   Sensitivity: %.3f\n', sensitivity);
fprintf('   Dice Coefficient: %.3f\n', dice);

%% Step 8: Visualization 
figure;
tiledlayout(2,3,'Padding','compact','TileSpacing','compact');

nexttile; imshow(I, []); title('Original X-ray');
nexttile; imshow(I_enh, []); title('Enhanced Image');
nexttile; imshow(edges); title('Edges (Canny)');
nexttile; imshow(seg, []); title('K-means Clusters');
nexttile; imshow(mask, []); title('Detected Tumor Mask');
nexttile; imshow(labeloverlay(I, mask, 'Colormap', [1 0 0]));
title('Detected Tumor Overlay');

% Make all titles readable and bold
set(findall(gcf,'Type','axes'),'FontSize',10,'TitleFontWeight','bold');

%% Step 9: Enlarge Figure Before Export (prevents overlapping titles)
set(gcf, 'Position', [65, 65, 850, 550]);  
drawnow;  

%% Step 10: Save Result Figures 
outputFolder = pwd;
exportgraphics(gcf, fullfile(outputFolder,'result_combined.pdf'), 'Resolution', 300);
exportgraphics(gcf, fullfile(outputFolder,'result_combined.png'), 'Resolution', 300);

disp('result_combined.pdf');
disp('result_combined.png');

disp('Tumor Detection Pipeline Finished!');
