clear all 
close all
% input -  raw DCE NRRD, label file for aif, auc time intervale
% output - nifti auc map
%function RelativeAUC( c3dexe, OutputBase, InputNRRD, InputAIFNifti, AUCTimeInterval)
InputNRRD    = 'Processed/0001/dynamic.nrrd'
InputAIFNifti= 'Processed/0001/mask.nii.gz'
InputAIFNifti= 'Processed/0001/slicmask.nii.gz'
InputAIFNifti= 'Processed/0001/gmmaif.nii.gz'
InputAIFNifti= 'Processed/0001/slicgmm.nii.gz'
InputDistance= 'Processed/0001/sdt.nii.gz'
OutputBase   = 'Processed/0001/output'
c3dexe       = '/usr/local/bin/c3d'
AUCTimeInterval = '10'
disp( ['c3dexe=         ''',c3dexe         ,''';']);      
disp( ['InputNRRD=      ''',InputNRRD      ,''';']);      
disp( ['InputAIFNifti=  ''',InputAIFNifti  ,''';']);  
disp( ['InputDistance=  ''',InputDistance  ,''';']);  
disp( ['AUCTimeInterval=''',AUCTimeInterval,''';']); 

OutputSln = [OutputBase,'.solution.nii.gz'];
OutputRsd = [OutputBase,'.residual.nii.gz'];
OutputPst = [OutputBase,'.pst.roirel.nii.gz'];
disp( ['OutputRsd=     ''',OutputRsd     ,''';']);      
disp( ['OutputSln=     ''',OutputSln     ,''';']);      
disp( ['OutputPst=     ''',OutputPst     ,''';']);      
%% assert floating
AUCTimeInterval  = str2double(AUCTimeInterval)

%% Load paths.
if ~isdeployed
  addpath('./nifti');
end

%% Load DCE data
disp(['[rawdce, dcemeta] =nrrdread(''',InputNRRD,''');']);
[rawdce, dcemeta] = nrrdread(InputNRRD);

%% Get Timing Info
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
disp(['aiflabel = load_untouch_nii(''',InputDistance  ,''');']);
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

plot( aif(:,1));hold; plot( aif(:,2)); plot( aif(:,10));
% plot(rawdce(:,278,69,7 )); hold;  plot( rawdce(:,280,57,9)); plot(rawdce(:,251,63,12));

% the unique label values form the basis
[uniquelabelsfull, revlabelval, indlabelval] = unique(aifID);

% build data structures for jacobian build
derivaif = [ 0; (aif(2:length(aif(:,1)),1) - aif(1:length(aif(:,1))-1,1))./timing(2:length(timing))'];

% initialize
x0 = .1*ones(length(uniquelabelsfull),1);
mycurrentsoln = zeros(length(uniquelabelsfull),1);
myfunc = @(x)analyticsoln(x,timing,rawdce,aifID,distanceImage,indlabelval,aif(:,1),derivaif,aifLabelValue );

% solve  'JacobMult',@(Jinfo,Y,flag)analyticjacmult(Jinfo,Y,flag,timing,rawdce,aifID,distanceImage,indlabelval,aif(:,1),derivaif,mycurrentsoln ), 'InitDamping', '100'
opts1=  optimset('Algorithm','levenberg-marquardt','display','iter-detailed', 'Jacobian','on', 'Diagnostics','on', 'DerivativeCheck', 'off' , 'FinDiffRelStep',1.e-4)

[x,resnorm,residual,exitflag,output] =  lsqnonlin(myfunc,x0,[],[],opts1);


%% save as nifti
solnImage = x(indlabelval);
solnImage = reshape(solnImage, size(aifID));
solnnii = make_nii(solnImage,[],[],[],'solution');
save_nii(solnnii,OutputSln) ;
copyheader = ['!' c3dexe ' '  InputAIFNifti ' ' OutputSln ' -copy-transform -o ' OutputSln ];
disp(copyheader ); c3derrmsg = evalc(copyheader);


%% save as nifti
rsdImage = reshape(abs(residual), size(aifID));
rsdnii = make_nii(rsdImage,[],[],[],'residual');
save_nii(rsdnii,OutputRsd) ;
copyheader = ['!' c3dexe ' '  InputAIFNifti ' ' OutputRsd ' -copy-transform -o ' OutputRsd ];
disp(copyheader ); c3derrmsg = evalc(copyheader);

%% %% save as nifti
%% aucnii = make_nii(aucimage,[],[],[],'aucratio');
%% save_nii(aucnii,OutputAUC) ;
%% copyheader = ['!' c3dexe ' ' InputAIFNifti ' ' OutputAUC ' -copy-transform -o ' OutputAUC ];
%% disp(copyheader ); c3derrmsg = evalc(copyheader);
%% disp(['vglrun itksnap -g ', InputNRRD, ' -s ', InputAIFNifti, ' -o ',OutputAUC])
