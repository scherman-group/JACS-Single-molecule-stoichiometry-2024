%%Packages needed, ReadImageJROI, Sub-Sample Peak Fitting 2D, Peak Fit,
%%custom fitting function (FitFunctTest.m) for interpolation with Curve Fitting Tool
clear
ROIPath = 'G:\Backblaze Restore\G\AlanData\2022\03-04-2022\300 pM\analysis4-03-2023\sample1\7_ROIs\Threshold_SUM\02_ROIset_exp_SUM.zip';
ROI_List = ReadImageJROI(ROIPath);
Matlab_ROIs = ROIs2Regions(ROI_List,[1024 1024]);

% Specify file name
cd('G:\Backblaze Restore\G\AlanData\2022\03-04-2022\300 pM\1to1CB\10percent_30ms_488_50uLdeposition_1\')
filename = '10percent_30ms_488_50uLdeposition_1_MMStack_Pos0.ome.tif';

% Read video file
info = imfinfo(filename);
num_frames = numel(info);
video_data = zeros(info(1).Height, info(1).Width, num_frames, 'uint16');

for i = 1:num_frames
    video_data(:,:,i) = imread(filename, i, 'Info', info);
end

video_data = (video_data - 100) / 4;

% Extract the pixel indices of each ROI
roi_pixel_idx = Matlab_ROIs.PixelIdxList;

% Loop over the ROIs and extract the data for each frame
num_crops = numel(roi_pixel_idx);
num_frames = size(video_data, 3);
crop_data = cell(num_crops, num_frames);

for i = 1:num_crops
    % Extract the row and column indices of the ROI pixels
    [row_idx, col_idx] = ind2sub([1024 1024], roi_pixel_idx{i});
    
    % Fit an ellipse to the ROI
    [ellipseoutput] = fit_ellipse(col_idx, row_idx);
    
    % Calculate the size of the smallest rectangle that can be used to
    % contain the ellipse
    a = ellipseoutput.a;
    b = ellipseoutput.b;
    rect_width = 2*a;
    rect_height = 2*b;

    % Calculate the coordinates of the top-left corner of the rectangle
    row_start = round(ellipseoutput.Y0_in - rect_height/2-1);
    row_end=row_start+rect_height+1;
    row_end=round(row_end);
    col_start = round(ellipseoutput.X0_in - rect_width/2-1);
    col_end=col_start+rect_width+1;
    col_end=round(col_end);
    
  %if row_start<1
 
  %  end
   % if col_start<1
   % %col_start=1;
   % end
   % if row_end>504
   % row_end=504;
   % end
   % if col_end>505
   % col_end=505;
   % end

    % Loop over the frames and extract the data for the current ROI
    for j = 1:num_frames
        % Extract the data for the current frame and ROI
        crop_data{i,j} = video_data(col_start:col_end, row_start:row_end, j);
    end
end

%%
% Display first frame of video
adjusted_img = imadjust(video_data(:,:,3));
imshow(adjusted_img);
%%
% Display first frame of first crop
adjusted_crop = imadjust(crop_data{132,1});
imshow(adjusted_crop);
%%
num_crops = size(crop_data, 1);
num_frames = size(crop_data, 2);
analysis_results = cell(num_crops, num_frames);
analysis_results_condensed = cell(num_crops, num_frames);
counter = 0;

% Preallocate memory for x, y, X, and Y
x = cell(num_crops, 1);
y = cell(num_crops, 1);
X = cell(num_crops, 1);
Y = cell(num_crops, 1);
for i = 1:num_crops
    data = crop_data{i, 1};
    [x{i}, y{i}] = meshgrid(1:size(data, 2), 1:size(data, 1));
    [X{i}, Y{i}] = meshgrid(1:0.3:size(data, 2), 1:0.3:size(data, 1));
end

for i = 1:num_crops
    for j = 1:num_frames
        data = crop_data{i, j};
        result = FitFunctTest(x{i}, y{i}, double(data));
        Z_interp = feval(result, X{i}, Y{i});
        X0Y0 = peakfit2d(Z_interp);
        X0Y0 = round(X0Y0);
        [sizeX, sizeY] = size(Z_interp);
        if X0Y0(1)<1 || X0Y0(2)<1 || X0Y0(1)>sizeX || X0Y0(2)>sizeY
            counter = counter + 1;
            if counter == 15
                counter = 0;
                break
            end
        else
            fitrowbasis = X{i}(X0Y0(1), :)';
            fitrow = Z_interp(X0Y0(1), :)';
            fitcolbasis = Y{i}(:, X0Y0(2));
            fitcol = Z_interp(:, X0Y0(2));
            [fit1, fit1GOF] = peakfit([fitrowbasis fitrow], 0, 0, 0, 0, 0, 0, 0, 3);
            [fit2, fit2GOF] = peakfit([fitcolbasis fitcol], 0, 0, 0, 0, 0, 0, 0, 3);
            if fit1GOF(1, 2) < 0.60 || fit2GOF(1, 2) < 0.60
                counter = counter + 1;
                if counter == 15
                    counter = 0;
                    break
                end
            else
                analysis_results{i, j} = struct('x0', X0Y0(2), 'y0', X0Y0(1), 'fit1', fit1, 'fit1GOF', fit1GOF, 'fit2', fit2, 'fit2GOF', fit2GOF);
                fit1_combined = horzcat(analysis_results{i,j}.fit1, analysis_results{i,j}.fit1GOF);
                fit2_combined = horzcat(analysis_results{i,j}.fit2, analysis_results{i,j}.fit2GOF);
                analysis_results_condensed{i,j} = horzcat(fit1_combined, fit2_combined);
            end
        end
    end
end
%%
analysis_areas = cell(num_crops, num_frames);
for i = 1:num_crops
    for j = 1:num_frames
        if isstruct(analysis_results{i,j})
            fit1 = analysis_results{i,j}.fit1;
            fit2 = analysis_results{i,j}.fit2;
            x0 = analysis_results{i,j}.x0;
            y0 = analysis_results{i,j}.y0;
            if ~isempty(fit1) && ~isempty(fit2)
                amp1 = fit1(3);
                sigma1 = abs(fit1(4))/(2*sqrt(2*log(2)));
                amp2 = fit2(3);
                sigma2 = abs(fit2(4))/(2*sqrt(2*log(2)));
                area = (amp1+amp2)*pi*sigma1*sigma2;
            else
                area = 0;
            end
        else
            area = 0;
        end
        analysis_areas{i,j} = area;
    end
end

analysis_areas = cell2mat(analysis_areas);
analysis_areas_sums = sum(analysis_areas, 2);
%%
writematrix(analysis_areas,'C:\Users\k-Space\Desktop\analysis_areas.csv') 
writematrix(analysis_areas_sums,'C:\Users\k-Space\Desktop\analysis_areas_sums.csv') 
%%
analysis_results_table=cell2table(analysis_results_condensed);
%%
writetable(analysis_results_table,'C:\Users\k-Space\Desktop\analysis_results_table.csv')
%%
% Plot the data and the interpolated Gaussian together
figure;
%surf(x{132,1}, y{132,1}, data, 'EdgeColor', 'none');
%hold on;
surf(X{132,1}, Y{132,1}, Z_interp-30, 'EdgeColor', 'none');
zlim([-10, max(max(Z_interp))]);
%plot(result);