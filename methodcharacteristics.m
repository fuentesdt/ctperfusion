% input -  raw DCE NRRD, label file for aif, auc time intervale
% output - nifti auc map
%function RelativeAUC( c3dexe, OutputBase, InputNRRD, InputAIFNifti, AUCTimeInterval)
InputNRRD    = 'Processed/0001/dynamic.nrrd'
InputAIFNifti= 'Processed/0001/label.nii.gz'
OutputBase   = 'Processed/0001/output'
c3dexe       = '/usr/local/bin/c3d'
AUCTimeInterval = '10'
disp( ['c3dexe=         ''',c3dexe         ,''';']);      
disp( ['InputNRRD=      ''',InputNRRD      ,''';']);      
disp( ['InputAIFNifti=  ''',InputAIFNifti  ,''';']);  
disp( ['AUCTimeInterval=''',AUCTimeInterval,''';']); 

OutputAUC = [OutputBase,'.roirel.nii.gz'];
OutputPre = [OutputBase,'.pre.roirel.nii.gz'];
OutputPst = [OutputBase,'.pst.roirel.nii.gz'];
disp( ['OutputAUC=     ''',OutputAUC     ,''';']);      
disp( ['OutputPre=     ''',OutputPre     ,''';']);      
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

%% %% Get Timing Info
%% rawtiming = eval(['[',dcemeta.multivolumeframelabels,']']);
%% if dcemeta.multivolumeframeidentifyingdicomtagunits == 'ms'
%%   timing = rawtiming * 1.e-3   % convert to seconds 
%% end
%% 
%% %% variable spacing
%% deltat =  [ timing(2) - timing(1), timing(2:length(timing)) - timing(1:length(timing)-1)]
%% 
%% deltatmean   =  mean(deltat)
%% deltatmedian =  median(deltat)
%% % HACK - use median time as constant spacing
%% if (deltatmean   > 1.5 * deltatmedian )
%%    disp('timing error?? \n ');
%%    timing = deltatmedian *[0:length(timing)-1]
%%    deltat = deltatmedian *ones(1,length(timing))
%% end
%% 
%% 
%% 
%% %% Load AIF
%% disp(['aiflabel = load_untouch_nii(''',InputAIFNifti,''');']);
%% aiflabel  = load_untouch_nii(InputAIFNifti);
%% aifID = int32(aiflabel.img);
%% 
%% %% nifti info
%% [npixelx, npixely, npixelz] = size(aifID);
%% spacingX = aiflabel.hdr.dime.pixdim(2);
%% spacingY = aiflabel.hdr.dime.pixdim(3);
%% spacingZ = aiflabel.hdr.dime.pixdim(4);
%% disp([npixelx, npixely, npixelz, spacingX, spacingY, spacingZ]);
%% 
%% %% find indices of ROI
%% if isempty(find(aifID >0 ))
%%    error('\n\n\t no aif input:  %s ',InputAIFNifti);
%% end
%% [xroi,yroi,zroi] = ind2sub(size(aifID), find(aifID >0 ));
%% 
%% %% extract AIF info
%% aif  = zeros(size(rawdce,1),length(xroi));
%% for jjj =1:length(xroi)
%%   disp([xroi(jjj),yroi(jjj),zroi(jjj)]);
%%   aif(:,jjj) = rawdce(:,xroi(jjj),yroi(jjj),zroi(jjj));
%% end
%% 
%% % plot(rawdce(:,278,69,7 )); hold;  plot( rawdce(:,280,57,9)); plot(rawdce(:,251,63,12));
%% 
%% %% extract AIF derivative info
%% diffaif  = zeros(size(rawdce,1),length(xroi));
%% for iii =2:size(rawdce,1)
%%     diffaif(iii,:)  = (aif(iii,:) - aif(iii-1,:))/deltat(iii);
%% end  
%% % for jjj =1:length(xroi)
%% %     plot(diffaif(:,jjj))
%% %     hold on
%% % end
%% 
%% %% bolus arrival time (bat) is average max location
%% [aifmax aifmaxloc] = max(diffaif);
%% bat = floor(mean(aifmaxloc));
%% 
%% %% offset bolus arrival time  by AUC Time
%% aucmaxid= bat;
%% while timing(aucmaxid) < (timing(bat)+ AUCTimeInterval )
%%   aucmaxid = aucmaxid + 1;
%% end
%% 
%% 
%% disp(sprintf('bat %d, bolus arrival %f, aucmaxid %d, timing(bat)+ AUCTimeInterval %f, length(timing) %d ', bat, timing(bat) ,aucmaxid,timing(bat)+AUCTimeInterval, length(timing) ))
%% 
%% %% compute pre bolus average signal
%% preBOLUS = zeros(npixelx, npixely, npixelz);
%% for iii = 2:bat
%%   preBOLUS =  preBOLUS + 0.5*(timing(iii) - timing(iii-1)) * double(squeeze(rawdce(iii,:,:,:) + rawdce(iii-1,:,:,:)));
%% end
%% signalmask = preBOLUS >10;
%% 
%% %% compute post bolus average signal
%% pstBOLUS = zeros(npixelx, npixely, npixelz);
%% for iii = bat+1:aucmaxid
%%   pstBOLUS =  pstBOLUS + 0.5*(timing(iii) - timing(iii-1)) * double(squeeze(rawdce(iii,:,:,:) + rawdce(iii-1,:,:,:)));
%% end
%% 
%% %% AUC image is the pointwise ratio
%% aucimage = (pstBOLUS./preBOLUS).*signalmask;
%% 
%% %% save as nifti
%% prenii = make_nii(preBOLUS,[],[],[],'prebolus');
%% save_nii(prenii,OutputPre) ;
%% copyheader = ['!' c3dexe ' '  InputAIFNifti ' ' OutputPre ' -copy-transform -o ' OutputPre ];
%% disp(copyheader ); c3derrmsg = evalc(copyheader);
%% 
%% %% save as nifti
%% pstnii = make_nii(pstBOLUS,[],[],[],'pstbolus');
%% save_nii(pstnii,OutputPst) ;
%% copyheader = ['!' c3dexe ' '  InputAIFNifti ' ' OutputPst ' -copy-transform -o ' OutputPst ];
%% disp(copyheader ); c3derrmsg = evalc(copyheader);
%% 
%% %% save as nifti
%% aucnii = make_nii(aucimage,[],[],[],'aucratio');
%% save_nii(aucnii,OutputAUC) ;
%% copyheader = ['!' c3dexe ' ' InputAIFNifti ' ' OutputAUC ' -copy-transform -o ' OutputAUC ];
%% disp(copyheader ); c3derrmsg = evalc(copyheader);
%% disp(['vglrun itksnap -g ', InputNRRD, ' -s ', InputAIFNifti, ' -o ',OutputAUC])
