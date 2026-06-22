 clc; clear;

%% ============================================================
%% AFTER VIVADO SIMULATION
%% NO IMAGE PROCESSING TOOLBOX REQUIRED
%% Run this AFTER Vivado simulation is complete
%% ============================================================

%% ---- CONFIGURE YOUR PATHS HERE ----
img_path = 'C:\Users\rithi\OneDrive\Desktop\mulimage.jpeg';
sim_path = 'C:\Users\rithi\mul4\mul4.sim\sim_1\behav\xsim\';

%% ============================================================
%% STEP 1 : READ ORIGINAL IMAGE
%% ============================================================
img      = imread(img_path);
[height, width, ~] = size(img);
IMG_SIZE = height * width;

fprintf("Image loaded : %d x %d = %d pixels\n", height, width, IMG_SIZE);

%% ============================================================
%% STEP 2 : REBUILD EDGE MASK (for overlay display)
%%          No toolbox - same Sobel method as STEP1 script
%% ============================================================
R_ch     = double(img(:,:,1));
G_ch     = double(img(:,:,2));
B_ch     = double(img(:,:,3));
img_gray = 0.2989 * R_ch + 0.5870 * G_ch + 0.1140 * B_ch;

Kx = [-1 0 1; -2 0 2; -1 0 1];
Ky = [-1 -2 -1; 0 0 0; 1 2 1];
Gx = conv2(img_gray, Kx, 'same');
Gy = conv2(img_gray, Ky, 'same');
G  = sqrt(Gx.^2 + Gy.^2);
threshold = 0.15 * max(G(:));
edge_map  = G > threshold;

% Manual dilation
se_size  = 2;
[rows, cols] = size(edge_map);
edge_map_dilated = false(rows, cols);
for r = 1:rows
    for c = 1:cols
        r1 = max(1, r - se_size);  r2 = min(rows, r + se_size);
        c1 = max(1, c - se_size);  c2 = min(cols, c + se_size);
        if any(any(edge_map(r1:r2, c1:c2)))
            edge_map_dilated(r, c) = true;
        end
    end
end
edge_map = edge_map_dilated;

edge_pct = sum(edge_map(:)) / IMG_SIZE * 100;
fprintf("Edge pixels   : %.2f%%\n", edge_pct);
fprintf("Background px : %.2f%%\n", 100 - edge_pct);

%% ============================================================
%% STEP 3 : READ ALL 3 OUTPUT IMAGES FROM VIVADO
%% ============================================================
fprintf("\nReading Vivado output files...\n");

function img_out = read_img_mem(sim_path, Rf, Gf, Bf, width, height, IMG_SIZE)
    R = hex2dec(readlines([sim_path Rf])); R = R(1:IMG_SIZE);
    G = hex2dec(readlines([sim_path Gf])); G = G(1:IMG_SIZE);
    B = hex2dec(readlines([sim_path Bf])); B = B(1:IMG_SIZE);
    R = reshape(R, width, height)';
    G = reshape(G, width, height)';
    B = reshape(B, width, height)';
    img_out = uint8(cat(3, R, G, B));
end

exact_img    = read_img_mem(sim_path, 'exact_R.mem',    'exact_G.mem',    'exact_B.mem',    width, height, IMG_SIZE);
approx_img   = read_img_mem(sim_path, 'approx_R.mem',   'approx_G.mem',   'approx_B.mem',   width, height, IMG_SIZE);
adaptive_img = read_img_mem(sim_path, 'adaptive_R.mem', 'adaptive_G.mem', 'adaptive_B.mem', width, height, IMG_SIZE);

fprintf("All output images loaded\n");

%% ============================================================
%% FIGURE 1 : 4-PANEL IMAGE COMPARISON
%% ============================================================
figure('Name','3-Way Image Comparison','Position',[50 50 1500 420]);

subplot(1,4,1);
imshow(img);
title('Original Image','FontSize',13,'FontWeight','bold');

subplot(1,4,2);
imshow(exact_img);
title('Exact Enhancement','FontSize',13,'FontWeight','bold','Color',[0 0.5 0]);

subplot(1,4,3);
imshow(approx_img);
title('Approx Enhancement','FontSize',13,'FontWeight','bold','Color',[0.8 0.3 0]);

subplot(1,4,4);
imshow(adaptive_img);
title('Adaptive Enhancement','FontSize',13,'FontWeight','bold','Color',[0 0.3 0.8]);

%% ============================================================
%% FIGURE 2 : EDGE MASK OVERLAY
%% ============================================================
R_ov = double(img(:,:,1)) .* ~edge_map + 255 * double(edge_map);
G_ov = double(img(:,:,2)) .* ~edge_map;
B_ov = double(img(:,:,3)) .* ~edge_map;
overlay        = img;
overlay(:,:,1) = uint8(R_ov);
overlay(:,:,2) = uint8(G_ov);
overlay(:,:,3) = uint8(B_ov);

figure('Name','Edge Mask Overlay','Position',[50 50 900 420]);

subplot(1,2,1);
imshow(edge_map);
title('Edge Mask  (white = exact region)','FontSize',12);

subplot(1,2,2);
imshow(overlay);
title('Red = Exact region  |  Normal = Approx region','FontSize',12);

%% ============================================================
%% STEP 4 : COMPUTE METRICS (no toolbox)
%% ============================================================
exact_d    = double(exact_img);
approx_d   = double(approx_img);
adaptive_d = double(adaptive_img);

function [mse_v, psnr_v, er_v, ssim_v] = compute_metrics(ref, test)
    diff   = ref(:) - test(:);
    mse_v  = mean(diff .^ 2);
    if mse_v == 0
        psnr_v = Inf;
    else
        psnr_v = 10 * log10((255^2) / mse_v);
    end
    er_v   = sum(ref(:) ~= test(:)) / numel(ref);
    mu_x   = mean(ref(:));    mu_y  = mean(test(:));
    sx     = var(ref(:));     sy    = var(test(:));
    n      = numel(ref);
    sxy    = sum((ref(:) - mu_x) .* (test(:) - mu_y)) / (n - 1);
    C1     = (0.01 * 255)^2;  C2 = (0.03 * 255)^2;
    ssim_v = ((2*mu_x*mu_y + C1) * (2*sxy + C2)) / ...
             ((mu_x^2 + mu_y^2 + C1) * (sx + sy + C2));
end

[mse_ap, psnr_ap, er_ap, ssim_ap] = compute_metrics(exact_d, approx_d);
[mse_ad, psnr_ad, er_ad, ssim_ad] = compute_metrics(exact_d, adaptive_d);

%% ---- Print metrics table ----
fprintf("\n=====================================================\n");
fprintf("        3-WAY METRIC COMPARISON TABLE\n");
fprintf("=====================================================\n");
fprintf("%-12s  %10s  %10s  %10s  %8s\n","Method","MSE","PSNR(dB)","ER","SSIM");
fprintf("%-12s  %10.4f  %10s  %10.6f  %8.6f\n","Exact",    0,    "Inf", 0,      1.0);
fprintf("%-12s  %10.4f  %10.4f  %10.6f  %8.6f\n","Approx",   mse_ap, psnr_ap, er_ap,  ssim_ap);
fprintf("%-12s  %10.4f  %10.4f  %10.6f  %8.6f\n","Adaptive", mse_ad, psnr_ad, er_ad,  ssim_ad);
fprintf("=====================================================\n");
fprintf("Adaptive vs Approx improvement:\n");
fprintf("  MSE reduced by  : %.2f%%\n", (mse_ap - mse_ad)/mse_ap * 100);
fprintf("  PSNR improved by: %.4f dB\n", psnr_ad - psnr_ap);
fprintf("  ER  reduced by  : %.2f%%\n", (er_ap  - er_ad) /er_ap  * 100);
fprintf("  SSIM improved by: %.6f\n",   ssim_ad - ssim_ap);
fprintf("=====================================================\n");

%% ============================================================
%% FIGURE 3 : ERROR HEATMAPS
%% ============================================================
err_approx   = abs(exact_d - approx_d);
err_adaptive = abs(exact_d - adaptive_d);

figure('Name','Error Heatmaps','Position',[50 50 1000 420]);

subplot(1,2,1);
imagesc(mean(err_approx, 3));
colormap hot; colorbar; axis image;
title('Approx Error Heatmap','FontSize',12);
xlabel('Width (pixels)'); ylabel('Height (pixels)');

subplot(1,2,2);
imagesc(mean(err_adaptive, 3));
colormap hot; colorbar; axis image;
title('Adaptive Error Heatmap','FontSize',12);
xlabel('Width (pixels)'); ylabel('Height (pixels)');

%% ============================================================
%% FIGURE 4 : ERROR HISTOGRAMS
%% ============================================================
err_ap_px = exact_d(:) - approx_d(:);
err_ad_px = exact_d(:) - adaptive_d(:);

figure('Name','Error Histograms','Position',[50 50 900 420]);

subplot(1,2,1);
histogram(err_ap_px, 50, 'FaceColor',[0.8 0.3 0]);
title('Approx Error Histogram','FontSize',12);
xlabel('Pixel Error'); ylabel('Frequency'); grid on;

subplot(1,2,2);
histogram(err_ad_px, 50, 'FaceColor',[0 0.3 0.8]);
title('Adaptive Error Histogram','FontSize',12);
xlabel('Pixel Error'); ylabel('Frequency'); grid on;

%% ============================================================
%% FIGURE 5 : BAR CHART - PAPER READY
%% ============================================================
methods = categorical({'Exact','Approx','Adaptive'}, ...
                      {'Exact','Approx','Adaptive'});
colors  = [0 0.6 0; 0.8 0.3 0; 0 0.3 0.8];

figure('Name','Metric Bar Charts - Paper Ready','Position',[50 50 1100 400]);

subplot(1,4,1);
b = bar(methods, [0, mse_ap, mse_ad]);
b.FaceColor = 'flat'; b.CData = colors;
title('MSE','FontSize',12); ylabel('Value'); grid on;

subplot(1,4,2);
b = bar(methods, [0, psnr_ap, psnr_ad]);
b.FaceColor = 'flat'; b.CData = colors;
title('PSNR (dB)','FontSize',12); ylabel('dB'); grid on;

subplot(1,4,3);
b = bar(methods, [0, er_ap, er_ad]);
b.FaceColor = 'flat'; b.CData = colors;
title('Error Rate','FontSize',12); ylabel('Value'); grid on;

subplot(1,4,4);
b = bar(methods, [1, ssim_ap, ssim_ad]);
b.FaceColor = 'flat'; b.CData = colors;
title('SSIM','FontSize',12); ylabel('Value'); ylim([0 1.1]); grid on;

fprintf("\nAll figures generated. Ready for paper!\n");

%% -------- METRICS --------

exact_d = double(exact_img);
approx_d = double(approx_img);
adaptive_d = double(adaptive_img);

%% -------- APPROX METRICS --------

mse_approx = mean((exact_d(:)-approx_d(:)).^2);
psnr_approx = 10*log10((255^2)/mse_approx);

%% -------- ADAPTIVE METRICS --------

mse_adaptive = mean((exact_d(:)-adaptive_d(:)).^2);
psnr_adaptive = 10*log10((255^2)/mse_adaptive);

fprintf("\nApprox PSNR = %f dB\n",psnr_approx)
fprintf("Adaptive PSNR = %f dB\n",psnr_adaptive)

%% -------- ERROR HEATMAP --------

error_map_approx = abs(exact_d - approx_d);
error_map_adaptive = abs(exact_d - adaptive_d);

figure

subplot(1,2,1)
imagesc(mean(error_map_approx,3))
colormap hot
colorbar
title("Approx Error")

subplot(1,2,2)
imagesc(mean(error_map_adaptive,3))
colormap hot
colorbar
title("Adaptive Error")