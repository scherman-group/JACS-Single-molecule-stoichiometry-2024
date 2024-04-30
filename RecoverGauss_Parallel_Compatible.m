clear;
% This script allows one to recover analysis output if you want the
% Gaussian fitting parameters but want to use them differently. It will pull results from exportedCSVs/tables

% Specify the file path
root_path = 'C:\Users\k-Space\Desktop\analysis_Steve\15_count\sample1';
NumberTrials=[1];
TrialLength = length(NumberTrials);

cd(root_path);
areaDir = '01_areas';
areasumDir = '02_areasums';
mkdir(areaDir);
mkdir(areasumDir);

for m = 1:TrialLength

file_path = append(root_path,'\03_tables\','analysis_results_table_sample',mat2str(NumberTrials(m)),'.csv');

% Specify the number of header lines to skip
num_header_lines = 1;

% Read the CSV file using csvread, skipping the header line
data = csvread(file_path, num_header_lines);

% Find rows with all NaN values
all_nan_rows = all(isnan(data), 2);

% Replace NaN values with a custom value
custom_nan = -999;  % Choose any value that is not present in your data
data(isnan(data)) = custom_nan;

% Include rows with all NaN values in the imported data
data_with_all_nan = data;
data_with_all_nan(all_nan_rows, :) = custom_nan;

% Get the number of rows and columns in the data
num_rows = size(data, 1);
num_cols = size(data, 2);

% Calculate the number of sets of 14 across columns
num_sets = floor(num_cols / 14);

% Initialize the output cell array
output = cell(num_sets, 1);

% Iterate through each set of 14 columns
for i = 1:num_sets
    % Get the indices of columns for the current set of 14
    col_indices = (i - 1) * 14 + 1 : i * 14;
    
    % Extract the data for the current set of 14 columns
    set_data = data(:, col_indices);
    
    % Append the set data to the output cell array
    output{i} = set_data;
end

for i = 1:num_sets
    for j = 1:num_rows
        if output{i,1}(j,7)>0.60 && output{i,1}(j,14)>0.60

analysis_areas{i,1}(j,1)=(output{i,1}(j,3)+output{i,1}(j,10))*pi*abs(output{i,1}(j,4)/(2*sqrt(2*log(2))))*abs(output{i,1}(j,11)/(2*sqrt(2*log(2))));

        else
analysis_areas{i,1}(j,1)=0;

        end
    
    end
end

analysis_matrix = cat(2, analysis_areas{:});

% Create a logical index for values less than 500,000
index = analysis_matrix < 500000;

% Set all values not meeting the index to 0
analysis_matrix(~index) = 0;
analysis_areas_sums=sum(analysis_matrix,2);

File_areas=append(areaDir,'\analysis_areas_sample',mat2str(NumberTrials(m)),'.csv');
File_sums=append(areasumDir,'\analysis_areas_sum_sample',mat2str(NumberTrials(m)),'.csv');

writematrix(analysis_matrix,File_areas);
writematrix(analysis_areas_sums,File_sums); 

clearvars data output analysis_areas analysis_matrix analysis_areas_sums 

end