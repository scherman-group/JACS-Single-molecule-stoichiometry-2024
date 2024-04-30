%%%Bootstrap Code
clear
%%

cd 'C:\Users\am2970\Desktop\Combination\300 pM';
Folder = 'C:\Users\am2970\Desktop\Combination\300 pM';

Tphotons=readtable('Tphotons_filtered_sum.csv');
Tphotons=table2array(Tphotons);

%%
bootpercent=0.10;

for i=1:1000
randomizer(i,:)=Tphotons(randperm(length(Tphotons)));
crop(i,:)=randomizer(i,round(1:bootpercent*length(randomizer(i,:)),0));
med(i)=median(crop(i,:));
end

med_overall=median(med);
standarddev=std(med);

percenterror=standarddev/med_overall;