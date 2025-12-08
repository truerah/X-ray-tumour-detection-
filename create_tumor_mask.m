% -------------------------------------------------------------
% Name: Rythm Gagneja
% Roll No: 102218039
% -------------------------------------------------------------
%% Create Tumor Mask for X-ray Image (Polygon Version)
% Allows marking multiple tumor regions using polygons.

clc; clear; close all;

% Step 1: Load the X-ray image
img = imread('xray1.png');
figure, imshow(img), title('Draw tumor regions (use polygon). Double-click to close each region.');

% Convert to grayscale if necessary
if size(img,3) == 3
    img_gray = rgb2gray(img);
else
    img_gray = img;
end

% Step 2: Initialize empty mask
mask = false(size(img_gray));

% Step 3: Loop to allow multiple polygon markings
keepDrawing = true;
while keepDrawing
    % Draw polygon region
    h = drawpolygon('Color','y'); 
    region = createMask(h);
    
    % Add this region to the main mask
    mask = mask | region;
    
    % Ask user whether to add more regions
    choice = questdlg('Add another tumor region?', ...
                      'Continue Drawing?', ...
                      'Yes','No','No');
    if strcmp(choice, 'No')
        keepDrawing = false;
    end
end

% Step 4: Show the final tumor mask
figure;
imshow(mask);
title('Final Combined Tumor Mask');

% Step 5: Overlay the mask on the X-ray for verification
overlay = imoverlay(img_gray, mask, [1 0 0]); % red overlay
figure, imshow(overlay);
title('Tumor Mask Overlay on X-ray');

% Step 6: Save mask
imwrite(mask, 'ground_truth_img.png');
disp('Ground truth mask saved as ground_truth_img.png');
