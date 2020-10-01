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
  studydata= alldata(alldata.InstanceUID==idata,:);
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
  %% plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.solution, studydata.ktrans ,'x') 
  %% xlabel('pixelwise avg speed [mm/s]'); ylabel('ktrans [1/s]'); title(OutputBase)
  %% plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.solution, studydata.fpv ,'x') 
  %% xlabel('pixelwise avg speed [mm/s]'); ylabel('fpv [?]'); title(OutputBase)
  %% plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.solution, studydata.ve ,'x') 
  %% xlabel('pixelwise avg speed [mm/s]'); ylabel('ve [?]'); title(OutputBase)
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.solution, studydata.nccsolution ,'x') 
  xlabel('pixelwise avg speed [mm/s]'); ylabel('ncc avg speed [mm/s]'); title(OutputBase)
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.nccsolution, studydata.ktrans ,'x') 
  xlabel('ncc pixelwise avg speed [mm/s]'); ylabel('ktrans [1/s]'); title(OutputBase)
  [myrho,mypval] = corr(studydata.nccsolution, studydata.fpv ,'Type','Spearman')
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.nccsolution, studydata.fpv ,'x') 
  xlabel('ncc pixelwise avg speed [mm/s]'); ylabel('fpv [?]'); title(OutputBase)
  [myrho,mypval] = corr(studydata.nccsolution, studydata.ve ,'Type','Spearman')
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.nccsolution, studydata.ve ,'x') 
  xlabel('ncc pixelwise avg speed [mm/s]'); ylabel('ve [?]'); title(OutputBase)
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.nccglobalid, studydata.ktrans ,'x') 
  xlabel('ncc globalid'); ylabel('ktrans [1/s]'); title(OutputBase)
  [myrho,mypval] = corr(studydata.nccglobalid, studydata.fpv ,'Type','Spearman')
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.nccglobalid, studydata.fpv ,'x') 
  xlabel('ncc globalid'); ylabel('fpv [?]'); title(OutputBase)
  [myrho,mypval] = corr(studydata.nccglobalid, studydata.ve ,'Type','Spearman')
  plotcounter = plotcounter +1; figure(plotcounter ); plot(studydata.nccglobalid, studydata.ve ,'x') 
  xlabel('ncc globalid'); ylabel('ve [?]'); title(OutputBase)
end
