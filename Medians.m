% Specify the folder where your CSV files are stored
folderPath = 'H:\Backblaze Restore\G\AlanData\2022\03-25-2022\300pM_2\analysis-04-01-2023\20to1\exportedCSVs\02_areasums\';

% Get a list of all CSV files in the folder
files = dir(fullfile(folderPath, '*.csv')); % Assuming your files end with '1.csv'

% Initialize an array to store medians
medians = zeros(1, numel(files));

% Loop through each file
for i = 1:numel(files)
    % Construct the full file path
    filePath = fullfile(folderPath, files(i).name);
    
    % Read the CSV file
    data = csvread(filePath);
    
    % Calculate the median excluding non-zero values and values above 2*10^6
    validValues = data(data > 0 & data < 2e6);
    medianValue = median(validValues);
    
    % Store the median in the array
    medians(i) = medianValue;
end

% Save the medians to a CSV file
csvwrite(fullfile(folderPath, 'all_medians.csv'), medians);