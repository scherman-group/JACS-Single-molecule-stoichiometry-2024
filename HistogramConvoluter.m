%% Clear Previous Variables
clear

%%
Folder = 'D:\Dropbox\Dropbox\SMM_McLean\Data\02_SMM_Analyzed_Data\02_Agarose\CB7\budgets/';
cd 'D:\Dropbox\Dropbox\SMM_McLean\Data\02_SMM_Analyzed_Data\02_Agarose\CB7\budgets/';   %%%% Change to Proper Directory
Tphotons=csvread('Tphotons_filtered_sum_cutoff_10-06-2022.csv');
Tphotons=Tphotons/0.95;
repeats=100;
%% Randomizer 1

for j=1:(length(Tphotons)*repeats)
    randomizer_1(j)=Tphotons(randi(length(Tphotons),1));
end

%% Randomized 2

for j=1:(length(Tphotons)*repeats)
    randomizer_2(j)=Tphotons(randi(length(Tphotons),1));
end
%% Add Randomizer 1 and Randomizer 2

randomizer_sum=randomizer_1+randomizer_2;
randomizer_sum=randomizer_sum';
randomizer_median = median(randomizer_sum);
writematrix(randomizer_sum,sprintf('randomizedsum.csv'),'Delimiter',',');
writematrix(randomizer_median,sprintf('randomizedsum_median.csv'),'Delimiter',',');
%% Run Quick Histogram

histogram(randomizer_sum,17)