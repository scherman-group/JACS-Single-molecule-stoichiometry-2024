% Specify the file paths for the two CSV files
file1_path = 'D:\Dropbox\Dropbox\SMM_McLean\Data\02_SMM_Analyzed_Data\01_Ant910Me\freedye\budgets/Tphotons_filtered_sum_cutoff-fordisjoint.csv';
file2_path = 'D:\Dropbox\Dropbox\SMM_McLean\Data\02_SMM_Analyzed_Data\01_Ant910Me\CB8\budgets/Tphotons_filtered_sum_cutoff.csv';

% Import data from the first CSV file
data1 = csvread(file1_path);
column1 = data1(:, 1);  % Extract the first column
column1 = sort(column1); % Sort column1
column1 = column1/0.90;

% Import data from the second CSV file
data2 = csvread(file2_path);
column2 = data2(:, 1);  % Extract the first column
column2 = sort(column2); % Sort column2
column2 = column2/0.90;

%%
% Specify the percent range (75-100%)
percentRange = 30:1:100;

% Initialize the result table
resultTable = zeros(length(percentRange), 2);

% Loop through each percent value
for i = 1:length(percentRange)
    % Calculate the index corresponding to the given percent for each column
    indexColumn1 = round(percentRange(i) / 100 * length(column1));

    % Find the index of the closest value in column2 to column1(indexColumn1)
    [~, closestIndex] = min(abs(column2 - column1(indexColumn1)));

    % Subtract the found index from indexColumn1
    difference = (1-closestIndex/length(column2)) + indexColumn1/length(column1);
    hist1_contribution = indexColumn1/length(column1);
    hist2_contribution = (1-closestIndex/length(column2));

    % Store the results in the table
    resultTable(i, 1) = percentRange(i);
    resultTable(i, 2) = difference;
    resultTable(i, 3) = hist1_contribution;
    resultTable(i, 4) = hist2_contribution;
end

% Display the result table
disp('Result Table:');

% Fit the resultTable with a polynomial model of degree 5 using polyfit
coefficients = polyfit(resultTable(:, 1), resultTable(:, 2), 5);

% Evaluate the fit
poly5FitValues = polyval(coefficients, resultTable(:, 1));

% Plot the resultTable and the polynomial fit of degree 5
figure;

plot(resultTable(:, 1), resultTable(:, 2), '-o', 'DisplayName', 'Data');
hold on;
plot(resultTable(:, 1), poly5FitValues, 'r-', 'DisplayName', 'Fit');
title('Histogram Disjoint vs Threshold');
xlabel('Threshold (%)');
ylabel('Histogram Disjoint (%)');
legend('show');
grid on;

%yyaxis right;
%plot(resultTable(:, 1), resultTable(:, 3), '-s', 'DisplayName', 'Hist1 Contribution');
%ylabel('Hist1 Contribution');
%hold on;
%plot(resultTable(:, 1), resultTable(:, 4), '-s', 'DisplayName', 'Hist2 Contribution');
%ylabel('Hist2 Contribution');
hold off;

% Save the figure as a high-resolution PNG to the desktop
desktopPath = fullfile(pwd, 'Users/ammclean/Desktop/');  % Replace 'pwd' with the path to your desktop if needed
fileName = 'high_res_plot.png';

% Adjust the resolution (DPI) for high resolution
print(fullfile(desktopPath, fileName), '-dpng', '-r300');

