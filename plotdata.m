clear all
close all

alldata  = readtable( 'wideformat.csv')
%fpv           InstanceUID   LabelID       meanglobalid  Properties    solution      ve
%globalid      ktrans        maxslope      meansolution  Row           Variables     Vol_mm_3

plotcounter = 0;
for idata = 1:4
%for idata = 2:2
  OutputBase        = ['Processed/',sprintf('%04d',idata),'/']
  hadata = readtable(fullfile(OutputBase,'hepaticartery.distance.csv'));
  haradmean(idata) = hadata.Mean(hadata.LabelID==1) *1.e-3
  haradstdd(idata) = hadata.StdD(hadata.LabelID==1) *1.e-3
  pvdata = readtable(fullfile(OutputBase,'portalvein.distance.csv'))
  pvradmean(idata) = pvdata.Mean(pvdata.LabelID==1) *1.e-3
  pvradstdd(idata) = pvdata.StdD(pvdata.LabelID==1) *1.e-3
  OutputCorrelation = [OutputBase , 'correlation']
  %studydata= alldata(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19,:);
  studydata= alldata(alldata.InstanceUID==idata & alldata.ve> .0 & alldata.batsolution<8. &alldata.fpv>-.15 & alldata.fpv<.15 &alldata.LabelID~=0& ~isnan(alldata.bat),:);
  set(gca,'FontSize',20)
  [sprho,sppval] = corr(studydata.batsolution, studydata.meansolution,'Type','Spearman') ;
  plotcounter = plotcounter +1; handle = figure(plotcounter );
  plot( studydata.batsolution,        studydata.meansolution ,'x', studydata.batsolution,sprho*studydata.batsolution,'r') 
  flowrate = 177; % ml/min
  flowrate = 177/ 60* 1e-6; % ml/min * 1min/60sec * 1e-6 mm^3/1ml
  mykappaha(idata) = mean(studydata.batsolution * pi * haradmean(idata)^4 /8./flowrate);
  mykappapv(idata) = mean(studydata.batsolution * pi * pvradmean(idata)^4 /8./flowrate);
  xlabel('pixelwise avg speed [mm/s]')
  ylabel('super pixel speed [mm/s]')
  text(5,8,['r = ',sprintf('%3.2f',sprho)])
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

  [myrho(:,:,idata),mypval(:,:,idata)] = corr([studydata.bat        ,studydata.batsolution, studydata.meansolution ,studydata.ktrans,studydata.fpv,studydata.ve,studydata.ktrans./studydata.ve] ,'Type','Spearman') ;

  plotcounter = plotcounter +1; handle = figure(plotcounter ); plot(studydata.batsolution, studydata.ktrans ,'x') 
  xlabel('pixelwise avg speed [mm/s]'); ylabel('ktrans [1/s]'); title(sprintf('%04d rho %f pval %f ',idata, myrho(4,2,idata),mypval(4,2,idata))); saveas(handle,sprintf('batslnktrans%04d',idata),'png')
  plotcoun= plotcounter +1; handle = figure(plotcounter ); plot(studydata.batsolution, studydata.fpv ,'x') 
  xlim([0 5]); ylim([-.15  .15]) ;set(gca,'FontSize',20)
  text(4,.05,['r = ',sprintf('%3.2f',myrho(5,2,idata))])
  %xlabel('pixelwise avg speed [mm/s]'); ylabel('fpv [1]'); title(sprintf('id%04d r = %3.2f pval %f ',idata, myrho(5,2,idata),mypval(5,2,idata))); saveas(handle,sprintf('batslnfpv%04d',idata),'png')
  xlabel('pixelwise avg speed [mm/s]'); ylabel('fpv [1]');%title(sprintf('id%04d r = %3.2f  ',idata, myrho(5,2,idata)                  ));
  saveas(handle,sprintf('batslnfpv%04d',idata),'png')
  plotcoun= plotcounter +1; handle = figure(plotcounter ); plot(studydata.batsolution, studydata.ve ,'x') 
  xlabel('pixelwise avg speed [mm/s]'); ylabel('ve [1]'); title(sprintf('%04d rho %f pval %f ',idata, myrho(6,2,idata),mypval(6,2,idata))); saveas(handle,sprintf('batslnve%04d',idata),'png')
  plotcounter = plotcounter +1; handle = figure(plotcounter ); plot(studydata.bat, studydata.ktrans ,'x') 
  xlabel('bat'); ylabel('ktrans [1/s]'); title(sprintf('%04d rho %f pval %f ',idata, myrho(4,1,idata),mypval(4,1,idata))); saveas(handle,sprintf('batktrans%04d',idata),'png')
  plotcounter = plotcounter +1; handle = figure(plotcounter ); plot(studydata.bat, studydata.fpv ,'x') 
  xlabel('bat'); ylabel('fpv [1]'); title(sprintf('%04d rho %f pval %f ',idata, myrho(5,1,idata),mypval(5,1,idata))); saveas(handle,sprintf('batfpv%04d',idata),'png')
  plotcounter = plotcounter +1; handle = figure(plotcounter ); plot(studydata.bat, studydata.ve ,'x') 
  xlabel('bat'); ylabel('ve [1]'); title(sprintf('%04d rho %f pval %f ',idata, myrho(6,1,idata),mypval(6,1,idata))); saveas(handle,sprintf('batve%04d',idata),'png')

end
%table({'bat';'ktrans';'ve';'fpv'},gblrawrho(:,1),gblrawpval(:,1),gblslnrho(:,1),gblslnpval(:,1),'VariableNames',{'id' 'rho' 'pval' 'slnrho' 'slnpval'})
table(repmat({'ktran'; 'fpv'; 've'; 'ktransinvve'}, [1 4]),squeeze(myrho(4:7,1,:)),squeeze(mypval(4:7,1,:)),'VariableNames',{'id' 'rawrho' 'rawpval' }')
table(repmat({'ktran'; 'fpv'; 've'; 'ktransinvve'}, [1 4]),squeeze(myrho(4:7,2,:)),squeeze(mypval(4:7,2,:)),'VariableNames',{'id' 'slnrho' 'slnpval' }')

table([1:4]',mykappaha', mykappapv','VariableNames',{'id' 'ha' 'pv' })
