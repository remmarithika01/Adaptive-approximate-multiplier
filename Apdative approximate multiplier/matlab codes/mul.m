clc
clear

img = imread("C:\Users\rithi\OneDrive\Desktop\mulimage.jpeg");   % use your original image

[height,width,~] = size(img);

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

% convert to 1D vector row-wise
R = reshape(R',[],1);
G = reshape(G',[],1);
B = reshape(B',[],1);

fid = fopen('R.mem','w');
fprintf(fid,'%02x\n',R);
fclose(fid);

fid = fopen('G.mem','w');
fprintf(fid,'%02x\n',G);
fclose(fid);

fid = fopen('B.mem','w');
fprintf(fid,'%02x\n',B);
fclose(fid);

disp("MEM files created")
disp([height width])