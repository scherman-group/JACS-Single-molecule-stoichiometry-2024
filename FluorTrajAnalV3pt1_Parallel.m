%%Packages needed, ReadImageJROI, Sub-Sample Peak Fitting 2D, Peak Fit,
%%custom fitting function (FitFunctTest.m) for interpolation with Curve Fitting Tool
clear
%%Directory Information
RootDir = 'H:\Backblaze Restore\G\AlanData\2022\10-06-2022\agarose\5%\analysis-04-2024\'; %%%%Root Directory for ROIS
RootDir2 = append('H:\Backblaze Restore\G\AlanData\2022\10-06-2022\agarose\5%\CB8\','488_10percent_30ms_50uLdeposition_'); %%%%Root Directory for image files
ImageName = '488_10percent_30ms_50uLdeposition_';
cd(RootDir);
%Enter In Trials You Want to Analyze
NumberTrials=[3,4];
TrialLength = length(NumberTrials);

%Make Directory for Saving Exports
CSV_save='exportedCSVs';
mkdir(CSV_save);
areaDir = 'exportedCSVs/01_areas';
areasumDir = 'exportedCSVs/02_areasums';
tableDir = 'exportedCSVs/03_tables';
mkdir(areaDir);
mkdir(areasumDir);
mkdir(tableDir);

%Loop Set 1
for p = 1:TrialLength

ROIPath = append(RootDir,'sample',mat2str(NumberTrials(p)),'\7_ROIs\Threshold_SUM\02_ROIset_exp_SUM.zip');
ROI_List = ReadImageJROI(ROIPath);
Matlab_ROIs = ROIs2Regions(ROI_List,[1024 1024]);

% Specify file name
imagepath=append(RootDir2,mat2str(NumberTrials(p)));
cd(imagepath);
filename = append(ImageName,mat2str(NumberTrials(p)),'_MMStack_Pos0.ome.tif');

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
    
    % Loop over the frames and extract the data for the current ROI
    for j = 1:num_frames
        % Extract the data for the current frame and ROI
        crop_data{i,j} = video_data(col_start:col_end, row_start:row_end, j);
    end
end

%Loop Set 2
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
            if counter == 3
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
            if fit1GOF(1, 2) < 0.85 || fit2GOF(1, 2) < 0.85
                counter = counter + 1;
                if counter == 3
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

%Loop Set 3
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

analysis_areas=cell2mat(analysis_areas);
analysis_areas_sums=sum(analysis_areas,2);

%Save Data
cd(RootDir);
File_areas=append(areaDir,'\analysis_areas_sample',mat2str(NumberTrials(p)),'.csv');
File_sums=append(areasumDir,'\analysis_areas_sum_sample',mat2str(NumberTrials(p)),'.csv');
File_table=append(tableDir,'\analysis_results_table_sample',mat2str(NumberTrials(p)),'.csv');

writematrix(analysis_areas,File_areas);
writematrix(analysis_areas_sums,File_sums); 

analysis_results_table=cell2table(analysis_results);

writetable(analysis_results_table,File_table);
end
%%
% Plot the data and the interpolated Gaussian together
figure;
%surf(x, y, data, 'EdgeColor', 'none');
%hold on;
surf(X, Y, Z_interp, 'EdgeColor', 'none');
%plot(result);