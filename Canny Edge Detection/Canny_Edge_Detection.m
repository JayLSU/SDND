%% This is for Canny Edge Detection practice
%                                         ---- Shengjie Guo, 01/20/2018
%-------------------------------------------------------------------------%
%% Read image and convert to grayscale
image = imread('exit-ramp.jpg');
image_size = size(image);
figure(1)
imshow(image);
gray = rgb2gray(image);
figure(2)
imshow(gray);
%% Process gray image with Gaussian Blur to suppress noise and spurious gradients
Gblur_gray = imgaussfilt(gray,'FilterSize',5); % kernal size is 3
%% Applying Canny edge detection
low_threshold = 0.1;
high_threshold = 3*low_threshold;
edges = edge(Gblur_gray,'Canny',[low_threshold,high_threshold]);
figure(3)
imshow(edges)

%% Hough transform of the binary image
[H,theta,rho] = hough(edges);
P = houghpeaks(H,100,'threshold',ceil(0.2*max(H(:))));
lines = houghlines(edges,theta,rho,P,'FillGap',3,'MinLength',20);

figure, imshow(edges), hold on
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
end


%% Select area and count lines inside
x = [20-0.1 0.46*image_size(2)-0.1 0.51*image_size(2)+0.1  image_size(2)-20+0.1];
y = [image_size(1)+0.1 0.55*image_size(1)-0.1  0.55*image_size(1)-0.1  image_size(1)+0.1];
masked_area = poly2mask(x,y,image_size(1), image_size(2));
selected_area_edges = edges;

temp_singlechannel_image = selected_area_edges;
temp_singlechannel_image = bitand(temp_singlechannel_image,masked_area);
selected_area_edges = temp_singlechannel_image;
%% Hough transform of the binary image
[H,theta,rho] = hough(selected_area_edges);
P = houghpeaks(H,100,'threshold',ceil(0.2*max(H(:))));
lines = houghlines(selected_area_edges,theta,rho,P,'FillGap',3,'MinLength',20);

figure, imshow(edges), hold on
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
end
