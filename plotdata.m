
clear all
close all


for idata = 1:1
   OutputBase        = ['Processed/',sprintf('%04d',idata),'/']
   OutputCorrelation = [OutputBase , 'correlation']
   globalid = readtable( [OutputBase,'globalid.csv'])
   solution = readtable( [OutputBase,'solution.csv'])
   meanglobalid = readtable( [OutputBase,'meanglobalid.csv'])
   meansolution = readtable( [OutputBase,'meansolution.csv'])

   % negative values are 0
   filterIdx = find(meanglobalid.Mean ~= 19 );

   set(gca,'FontSize',16)
   handle = figure(1);
   [myrho,mypval] = corr(solution.Mean(filterIdx ),meansolution.Mean(filterIdx ),'Type','Spearman')
   plot(solution.Mean(filterIdx ), meansolution.Mean(filterIdx ),'x') 
   hold
   plot(solution.Mean(filterIdx ), myrho* solution.Mean(filterIdx ) ) 
   xlabel('pixelwise avg speed [mm/s]')
   ylabel('super pixel speed [mm/s]')
   text(8,5,['r = ',sprintf('%3.2f',myrho)])
   xlim([0 inf])
   ylim([0 inf])
   saveas(handle,OutputCorrelation ,'png')
   figure(2); plot(globalid.Mean(filterIdx ), meanglobalid.Mean(filterIdx ),'x') 


end
