
clear all
close all


for idata = 1:1
   OutputBase        = ['Processed/',sprintf('%04d',idata),'/']
   OutputCorrelation = [OutputBase , 'correlation']
   ktransdat = readtable( [OutputBase,'/ConstantBAT3param/ktrans.csv'])
   globalid = readtable( [OutputBase,'globalid.csv'])
   solution = readtable( [OutputBase,'solution.csv'])
   meanglobalid = readtable( [OutputBase,'meanglobalid.csv'])
   meansolution = readtable( [OutputBase,'meansolution.csv'])

   % get ktrans data
   ktransdata = table( str2double(ktransdat.LabelID( strcmp(ktransdat.SegmentationID,'ktrans' ))),str2double(ktransdat.Mean( strcmp(ktransdat.SegmentationID,'ktrans' ))), 'VariableNames',{'LabelID','ktrans'});


   % negative values are 0
   filterIdx = find(meanglobalid.Mean ~= 19 );

   % compare to ktrans
   joinaktrans = join(solution ,ktransdata,'Keys','LabelID')
   joinaktrans = joinaktrans( filterIdx ,:)

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
   figure(3); plot( joinaktrans.Mean , joinaktrans.ktrans ,'x') 

   bvmeasurement = lpdata.Mean(lpdata.LabelID==1)
end
