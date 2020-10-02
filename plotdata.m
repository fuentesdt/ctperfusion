clear all
close all

alldata  = readtable( 'wideformat.csv')
%fpv           InstanceUID   LabelID       meanglobalid  Properties    solution      ve
%globalid      ktrans        maxslope      meansolution  Row           Variables     Vol_mm_3

plotcounter = 0;
for idata = 1:4
  OutputBase        = ['Processed/',sprintf('%04d',idata),'/']
  OutputCorrelation = [OutputBase , 'correlation']
  %studydata= alldata(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19,:);
  studydata= alldata(alldata.InstanceUID==idata & alldata.fpv>-.15 & alldata.fpv<.15 &alldata.LabelID~=0,:);
  set(gca,'FontSize',16)
  plotcounter = plotcounter +1; handle = figure(plotcounter );
  [myrho,mypval] = corr(studydata.solution, studydata.meansolution ,'Type','Spearman')
  plot( studydata.solution,        studydata.meansolution ,'x',studydata.solution, myrho* studydata.solution,'r' ) 
  xlabel('pixelwise avg speed [mm/s]')
  ylabel('super pixel speed [mm/s]')
  %text(8,5,['r = ',sprintf('%3.2f',myrho)])
  %xlim([0 inf])
  %ylim([0 inf])
  saveas(handle,OutputCorrelation ,'png')
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.globalid, studydata.meanglobalid,'x') 
  xlabel('globalid '); ylabel('meanglobalid '); title(OutputBase)
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.globalid, studydata.nccglobalid,'x') 
  xlabel('globalid '); ylabel('nccglobalid'); title(OutputBase)
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.nccglobalid, studydata.bat,'x') 
  xlabel('ncc globalid '); ylabel('bat'); title(OutputBase)
  %% plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.solution, studydata.ktrans ,'x') 
  %% xlabel('pixelwise avg speed [mm/s]'); ylabel('ktrans [1/s]'); title(OutputBase)
  %% plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.solution, studydata.fpv ,'x') 
  %% xlabel('pixelwise avg speed [mm/s]'); ylabel('fpv [?]'); title(OutputBase)
  %% plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.solution, studydata.ve ,'x') 
  %% xlabel('pixelwise avg speed [mm/s]'); ylabel('ve [?]'); title(OutputBase)
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.solution, studydata.nccsolution ,'x') 
  xlabel('pixelwise avg speed [mm/s]'); ylabel('ncc avg speed [mm/s]'); title(OutputBase)
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.batsolution, studydata.ktrans ,'x') 
  xlabel('bat pixelwise avg speed [mm/s]'); ylabel('ktrans [1/s]'); title(OutputBase)
  [myrho,mypval] = corr(studydata.batsolution, studydata.fpv ,'Type','Spearman')
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.batsolution, studydata.fpv ,'x') 
  xlabel('bat pixelwise avg speed [mm/s]'); ylabel('fpv [?]'); title(OutputBase)
  [myrho,mypval] = corr(studydata.batsolution, studydata.ve ,'Type','Spearman')
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.batsolution, studydata.ve ,'x') 
  xlabel('bat pixelwise avg speed [mm/s]'); ylabel('ve [?]'); title(OutputBase)
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.bat, studydata.ktrans ,'x') 
  xlabel('bat'); ylabel('ktrans [1/s]'); title(OutputBase)
  [myrho,mypval] = corr(studydata.bat, studydata.fpv ,'Type','Spearman')
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.bat, studydata.fpv ,'x') 
  xlabel('bat'); ylabel('fpv [?]'); title(OutputBase)
  [myrho,mypval] = corr(studydata.bat, studydata.ve ,'Type','Spearman')
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.bat, studydata.ve ,'x') 
  xlabel('bat'); ylabel('ve [?]'); title(OutputBase)
end
