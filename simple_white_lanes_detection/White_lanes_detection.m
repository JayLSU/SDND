%% White lanes detection 
%                                         ---- Shengjie Guo, 01/20/2018
%-------------------------------------------------------------------------%
%% Read image
image = imread('test.jpg');
image_size = size(image);
fprintf('This image dimensions are: %d, %d, %d.\n', image_size(1), image_size(2), image_size(3));

%% Pull out the x and y sizes and make a copy of the image
ysize = image_size(1);
xsize = image_size(2);
region_select = image;
color_select = image;
color_region_select = image;
marked_line_image = image;
%% Define a trangle region of interest
left_bottom = [120 , 539];
right_bottom = [830, 539];
apex = [473, 325];
%% Define color selection criteria
red_threshold = 200;
green_threshold = 200;
blue_threshold = 200;
rgb_thresholds = [red_threshold, green_threshold, blue_threshold];
%% Identify pixels below the thresholods
color_thresholds = bitor(bitor((image(:,:,1) < rgb_thresholds(1)),image(:,:,2)<rgb_thresholds(2)),...
    (image(:,:,3) < rgb_thresholds(3)));
for i = 1 : image_size(3)
    temp_image_singlechannle = color_select(:,:,i);
    temp_image_singlechannle(color_thresholds) = 0;
    color_select(:,:,i) = temp_image_singlechannle;
end
figure(1)
imshow(color_select)
%% Fit lines to identify the 3 sided region of interest
fit_left = polyfit([left_bottom(1), apex(1)],[left_bottom(2), apex(2)],1);
fit_right = polyfit([right_bottom(1), apex(1)],[right_bottom(2), apex(2)],1);
fit_bottom = polyfit([left_bottom(1), right_bottom(1)],[left_bottom(2), right_bottom(2)],1);
%% Find the refion inside the lines
[XX, YY] = meshgrid((0:1:xsize-1), (0:1:ysize-1));
threhold_1 = YY > (XX*fit_left(1) + fit_left(2));
threhold_2 = YY > (XX*fit_right(1) + fit_right(2));
threhold_3 = YY > (XX*fit_bottom(1) + fit_bottom(2));

region_thresholds = (YY > (XX*fit_left(1) + fit_left(2))) & ...
                    (YY > (XX*fit_right(1) + fit_right(2))) & ...
                    (YY < (XX*fit_bottom(1) + fit_bottom(2)));
%% Color pixel red which are inside the region of interest
% region_select(region_thresholds) = [255, 0, 0];
color_pexel_inside = [255, 0, 0];
for i = 1 : image_size(3)
    temp_image_singlechannle = region_select(:,:,i);
    temp_image_singlechannle(region_thresholds) = color_pexel_inside(i);
    region_select(:,:,i) = temp_image_singlechannle;
end
figure(2)
imshow(region_select)
%% Consider both color and region select
for i = 1 : image_size(3)
    temp_image_singlechannle = color_region_select(:,:,i);
    temp_image_singlechannle(bitor(~region_thresholds,color_thresholds)) = 0;
    color_region_select(:,:,i) = temp_image_singlechannle;
end
figure(3)
imshow(color_region_select)

%% Display origin image with selected region highlighted
figure(4)
x = [left_bottom(1),left_bottom(2),apex(1),apex(2),right_bottom(1),right_bottom(2)];
insertImage = insertShape(image,'polygon',x,'Color','blue');
imshow(insertImage)

%% Marked lines
for i = 1 : image_size(3)
    temp_image_singlechannle = marked_line_image(:,:,i);
    temp_image_singlechannle(bitand(region_thresholds,~color_thresholds)) = color_pexel_inside(i);
    marked_line_image(:,:,i) = temp_image_singlechannle;
end
figure(5)
imshow(marked_line_image)