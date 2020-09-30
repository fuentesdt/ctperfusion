clear all
close all

alldata  = readtable( 'wideformat.csv')
%fpv           InstanceUID   LabelID       meanglobalid  Properties    solution      ve
%globalid      ktrans        maxslope      meansolution  Row           Variables     Vol_mm_3

for idata = 1:1
  OutputBase        = ['Processed/',sprintf('%04d',idata),'/']
  OutputCorrelation = [OutputBase , 'correlation']
  
  set(gca,'FontSize',16)
  handle = figure(1);
  [myrho,mypval] = corr(alldata.solution(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19), alldata.meansolution(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19) ,'Type','Spearman')
  plot( alldata.solution(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19),        alldata.meansolution(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19) ,'x') 
  hold
  plot( alldata.solution(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19), myrho* alldata.solution(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19) ) 
  xlabel('pixelwise avg speed [mm/s]')
  ylabel('super pixel speed [mm/s]')
  text(8,5,['r = ',sprintf('%3.2f',myrho)])
  xlim([0 inf])
  ylim([0 inf])
  saveas(handle,OutputCorrelation ,'png')
  figure(2); plot(alldata.globalid(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19), alldata.meanglobalid(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19),'x') 
  figure(3); plot(alldata.solution(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19), alldata.ktrans(alldata.InstanceUID==idata& alldata.meanglobalid ~= 19) ,'x') 

end
