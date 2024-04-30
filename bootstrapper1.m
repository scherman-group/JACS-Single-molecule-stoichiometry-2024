%%%Bootstrap Code
clear
%%

cd 'G:\AlanData\2022\03-25-2022\300pM_2\analysis\CBonly\filtered_photon_budget';
Folder = 'G:\AlanData\2022\03-25-2022\300pM_2\analysis\CBonly\filtered_photon_budget';

Tphotons=readtable('Tphotons_filtered_sum_cutoff.csv');
Tphotons=table2array(Tphotons);
for j=1:1000
for i=1:length(Tphotons)
    randomizer(i)=Tphotons(randi(length(Tphotons),1));
end
med(j)=median(randomizer);
end

med_final=median(med);
standarddev=std(med);
percenterror=standarddev/med_final;

writematrix(med,sprintf('bootstrap_medians.csv'),'Delimiter',',');
writematrix(med_final,sprintf('bootstrap_medianofmedian.csv'),'Delimiter',',');
writematrix(standarddev,sprintf('bootstrap_standarddeviation.csv'),'Delimiter',',');
writematrix(percenterror,sprintf('bootstrap_percenterror.csv'),'Delimiter',',');