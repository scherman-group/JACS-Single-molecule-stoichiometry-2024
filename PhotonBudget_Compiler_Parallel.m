%% Clear Previous Variables
clear
%%
%%START OF CODE: THIS SECTION REQUIRES MODIFICATION FROM THE USER

rootDir='C:\Users\k-Space\Desktop\new_analysis_3\agarose\CB7\';
cd(rootDir);
NumberTrials=["09-01-2022" "09-20-2022" "10-06-2022"];
TrialLength = length(NumberTrials);
budgetDir = 'budgets';
medianDir = 'medians';
mkdir(budgetDir);
mkdir(medianDir);

%%
for m = 1:TrialLength

Folder = append(rootDir,NumberTrials(m),'\exportedCSVs\02_areasums'); %%%% Change to the Directory You Want (same as above)
cd(Folder);   %%%% Change to the Directory You Want

addpath(Folder);
fileNames = dir(Folder);
fileNames = {fileNames.name};
fileNames = fileNames(cellfun(...
    @(f)~isempty(strfind(f,'.csv')),fileNames));
for f = 1:numel(fileNames),
    fTable = readtable(fileNames{f});
    writetable(fTable,'analysis_areas_total.csv', 'WriteVariableNames', false,'Writemode','Append');
end

%%Import Data
Tphotons=readtable('analysis_areas_total.csv');
Tphotons=table2array(Tphotons);
med_ORI=median(Tphotons);
writematrix(med_ORI,sprintf('Tphotons_filtered_sum_median_ori.csv'),'Delimiter',',');

%%Optional: Cutoff (Max Photons In Histogram)

cutoff=5*10^5;

Tphotons=Tphotons(Tphotons<cutoff);
Tphotons=Tphotons(Tphotons>0); %%remove all 0 values
writematrix(Tphotons, sprintf('Tphotons_filtered_sum_cutoff.csv'),'Delimiter',',');

med=median(Tphotons);
writematrix(med,sprintf('Tphotons_filtered_sum_median.csv'),'Delimiter',',');

cd(rootDir);

SampleWrite=append(budgetDir,'\Tphotons_filtered_sum_cutoff_',NumberTrials(m),'.csv');
MedianWrite=append(medianDir,'\Tphotons_filtered_sum_median_',NumberTrials(m),'.csv');
writematrix(Tphotons, SampleWrite);
writematrix(med, MedianWrite);

clearvars Tphotons med_ORI med

end
%% ******************************************************

%%n = find(~Tphotons);
%%if n > 0
%%Tphotons(n) = int_on{n}; %replace any zeros with singular value from histogram
%%end

%plot new thresholded histogram
binNumber=30;
figure()
h = histfit(Tphotons, binNumber,'wbl');
yt = get(gca, 'YTick'); %use variable for normalizing y axis
ytf = yt/numel(Tphotons);
ytf=round(ytf,2);
set(gca, 'YTick', yt, 'YTickLabel', ytf); %use for normalizing y axis
pbaspect([1 1 1]);
xlabel('Total Photons');
ylabel('Frequency');
h(1).FaceColor = [28/255, 41/255, 135/255]; %controls the colour in the bars
h(1).EdgeColor = [29/255, 37/255, 125/255]; %controls the edge colour
h(1).FaceAlpha = 0.4;
h(1).LineWidth = 2;
xlim([0, cutoff]);
xline(med, ':', 'Color', [0.5 0 0], 'LineWidth', 2);
ax = gca;
set(gca,'XMinorTick','on','YMinorTick','off');
ax.Box = 'on';
ax.LineWidth = 3;
set(gca,'FontSize',18);
%set(findall(gcf,'type','text'),'FontSize',50);
set(gca,'color','white');
set(gcf,'color','white');

pngFileName = sprintf('TotalPhotonsHist_Sum.png');
fullFileName = fullfile(pngFileName);
export_fig(fullFileName);
