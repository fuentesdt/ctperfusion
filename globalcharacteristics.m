clear all 
close all

%% Load paths.
if ~isdeployed
  addpath('./nifti');
end

for idata = 3:3
OutputBase   = ['Processed/',sprintf('%04d',idata),'/']
inputfilelist = [ "G1C4anatomymask" "mean"];
%inputfilelist = [ "mean"];
for memberID = inputfilelist 



% input -  raw DCE NRRD, label file for aif, auc time intervale
% output - nifti auc map
%function RelativeAUC( c3dexe, OutputBase, InputNRRD, InputAIFNifti, AUCTimeInterval)

InputNRRD    = convertStringsToChars(strcat(OutputBase,'dynamic',memberID,'.nrrd'))
InputAIFNifti= [OutputBase,'aif.nii.gz']
InputDistance= [OutputBase,'sdt.nii.gz']
c3dexe       = '/usr/local/bin/c3d'
AUCTimeInterval = '10'
%disp( ['InputNRRD=      ''',InputNRRD      ,''';']);      

OutputSln = convertStringsToChars(strcat(OutputBase,memberID,'solution.nii.gz'))
OutputRsd = convertStringsToChars(strcat(OutputBase,memberID,'residual.nii.gz'))
OutputIdx = convertStringsToChars(strcat(OutputBase,memberID,'globalid.nii.gz'))
OutputNCCIdx = convertStringsToChars(strcat(OutputBase,memberID,'nccglobalid.nii.gz'))
OutputNCCSoln = convertStringsToChars(strcat(OutputBase,memberID,'nccsolution.nii.gz'))
OutputAif = convertStringsToChars(strcat(OutputBase,memberID,'aifplot'))
%% assert floating
AUCTimeInterval  = str2double(AUCTimeInterval)

%% Load DCE data
disp(['[rawdce, dcemeta] =nrrdread(''',InputNRRD,''');']);
[rawdce, dcemeta] = nrrdread(InputNRRD);

%% Get Timing Info
if memberID == 'mean'
   disp('HACK - use timing in other file ');
  [rawdcetiming, dcemeta] = nrrdread(convertStringsToChars(strcat(OutputBase,'dynamicG1C4anatomymask.nrrd')));
end
rawtiming = eval(['[',dcemeta.multivolumeframelabels,']']);
if dcemeta.multivolumeframeidentifyingdicomtagunits == 'ms'
  timing = rawtiming * 1.e-3   % convert to seconds 
end

%% variable spacing
deltat =  [ timing(2) - timing(1), timing(2:length(timing)) - timing(1:length(timing)-1)]

deltatmean   =  mean(deltat)
deltatmedian =  median(deltat)
% HACK - use median time as constant spacing
%% if (deltatmean   > 1.5 * deltatmedian )
%%    disp('timing error?? \n ');
%%    timing = deltatmedian *[0:length(timing)-1]
%%    deltat = deltatmedian *ones(1,length(timing))
%% end


%% Load Distance
disp(['distancenii = load_untouch_nii(''',InputDistance  ,''');']);
distancenii  = load_untouch_nii(InputDistance  );
distanceImage= distancenii.img;


%% Load AIF
disp(['aiflabel = load_untouch_nii(''',InputAIFNifti,''');']);
aiflabel  = load_untouch_nii(InputAIFNifti);
aifID = aiflabel.img;

%% nifti info
[npixelx, npixely, npixelz] = size(aifID);
spacingX = aiflabel.hdr.dime.pixdim(2);
spacingY = aiflabel.hdr.dime.pixdim(3);
spacingZ = aiflabel.hdr.dime.pixdim(4);
disp([npixelx, npixely, npixelz, spacingX, spacingY, spacingZ]);

%% find indices of ROI
if isempty(find(aifID >0 ))
   error('\n\n\t no aif input:  %s ',InputAIFNifti);
end
% TODO 
aifLabelValue = 1;
[xroi,yroi,zroi] = ind2sub(size(aifID), find(aifID ==aifLabelValue  ));

% extract AIF info
aif  = zeros(size(rawdce,1),length(xroi));
for jjj =1:length(xroi)
  %disp([xroi(jjj),yroi(jjj),zroi(jjj)]);
  aif(:,jjj) = rawdce(:,xroi(jjj),yroi(jjj),zroi(jjj));
end

  
handle = figure(1); set(gca,'fontsize',28); plot(  timing,  aif(:,1),'x-', timing, aif(:,2),'x-',timing, aif(:,3),'x-',timing, rawdce(:,294,215,80),'b');
handle = figure(1); set(gca,'fontsize',28); plot(  timing(2:end),  diff(aif(:,1)),'x-', timing, aif(:,2),'x-',timing, aif(:,3),'x-',timing(2:end), diff(rawdce(:,294,215,80)),'b');
xlabel('time [s]')
ylabel('attenuation [HU]')
saveas(handle,OutputAif ,'png')
% sum(abs(aif(:,1) - double(rawdce(:,290,274,71))))

% plot(rawdce(:,278,69,7 )); hold;  plot( rawdce(:,280,57,9)); plot(rawdce(:,251,63,12));
% TODO take avg ? 
modelaif =aif(:,1)
[ncc,lags] = xcorr(diff(rawdce(:,294,215,80)),diff(modelaif)); figure(2);stem(lags,ncc)
[maxncc, nccidx ] =  max(ncc)
stop
% global search residual
rsdsize = size(rawdce);
rsdsize(1) = 19;
residual = zeros(rsdsize);
for iii = 1:rsdsize(1)
  iii
  for kkk = 1:size(rawdce,1)
    residual(iii,:,:,:) = residual(iii,:,:,:) + abs(double(rawdce(kkk,:,:,:)) - modelaif(max(kkk-iii,1)));
  end
end 

% TODO - vectorize
nccglobalidx = zeros(size(rawdce,2),size(rawdce,3),size(rawdce,4));
for iii = 1:size(rawdce,2)
  for jjj = 1:size(rawdce,3)
    for kkk = 1:size(rawdce,4)
       [ncc,lags] = xcorr(rawdce(:,iii,jjj,kkk),modelaif,'normalize');
       [maxncc, nccidx ] =  max(ncc);
       nccglobalidx(iii,jjj,kkk)  = lags(nccidx);
    end
  end
end


%% dbg
%% residual(:,290,274,71)  = 0;
%% for iii = 1:size(rawdce,1)
%%   for kkk = 1:size(rawdce,1)
%%     residual(iii, 290,274,71) = residual(iii, 290,274,71) + abs(double(rawdce(kkk, 290,274,71)) - modelaif(max(kkk-iii,1)));
%%   end
%% end 
%% figure(2); plot( residual(:,290,274,71) );

% get global optimim
[globalmin, globalidx]  = min(residual,[],1) ;
globalidx = squeeze(globalidx);
globalmin = squeeze(globalmin);

% compute velocity map
velocity = 1/deltatmedian * distanceImage.*globalidx.^-1;
nccvelocity = 1/deltatmedian * distanceImage.*nccglobalidx.^-1;

%% save as nifti
nccidxnii = make_nii(nccglobalidx,[],[],[],'nccindex');
save_nii(nccidxnii,OutputNCCIdx ) ;
copyheader = ['!' c3dexe ' '  InputAIFNifti ' ' OutputNCCIdx ' -copy-transform -o ' OutputNCCIdx ];
disp(copyheader ); c3derrmsg = evalc(copyheader);

%% save as nifti
nccsolnnii = make_nii(nccvelocity,[],[],[],'nccvelocity');
save_nii(nccsolnnii,OutputNCCSoln ) ;
copyheader = ['!' c3dexe ' '  InputAIFNifti ' ' OutputNCCSoln ' -copy-transform -o ' OutputNCCSoln ];
disp(copyheader ); c3derrmsg = evalc(copyheader);

%% save as nifti
idxnii = make_nii(globalidx,[],[],[],'index');
save_nii(idxnii,OutputIdx) ;
copyheader = ['!' c3dexe ' '  InputAIFNifti ' ' OutputIdx ' -copy-transform -o ' OutputIdx ];
disp(copyheader ); c3derrmsg = evalc(copyheader);

%% save as nifti
solnnii = make_nii(velocity,[],[],[],'solution');
save_nii(solnnii,OutputSln) ;
copyheader = ['!' c3dexe ' '  InputAIFNifti ' ' OutputSln ' -copy-transform -o ' OutputSln ];
disp(copyheader ); c3derrmsg = evalc(copyheader);

%% save as nifti
rsdnii = make_nii(globalmin,[],[],[],'residual');
save_nii(rsdnii,OutputRsd) ;
copyheader = ['!' c3dexe ' '  InputAIFNifti ' ' OutputRsd ' -copy-transform -o ' OutputRsd ];
disp(copyheader ); c3derrmsg = evalc(copyheader);


%% imagesc(velocity(:,:,75))
end 
end
