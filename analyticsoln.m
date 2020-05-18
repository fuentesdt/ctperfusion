function [residual,jacobian]= analyticsoln(x,timing,rawdce,aifID,distanceImage,indlabelval,aif,derivaif,aifLabelValue)

%% prepare data structures
disp(sprintf('x -  min %4.1f, max %4.1f, mean %4.1f, var %4.1f', min(x), max(x) , mean(x), std(x) ));
alphaImage = x(indlabelval);
alphaImage = reshape(alphaImage, size(aifID));
workarray = aifID(:);

image1Dsize = length(distanceImage(:));
%loop over all time
%residual= zeros(length(timing)*image1Dsize ,1);
residual= zeros(image1Dsize ,1);
%for kkk  = 1:length(timing)
for kkk  = 13:13
  %% calculate xi
  xiImage = timing(kkk) - distanceImage.*(alphaImage.^-1);
  disp(sprintf('time = %d, min %4.1f , max %4.1f',kkk, min(xiImage(:)), max(xiImage(:)) ));
  
  % negative values are 0
  zeroIdx = find(xiImage < 0);
  % out of bounds 
  oobIdx = find(xiImage > timing(length(timing)));
  
  % interpolate aif values
  modelValues  = interp1(timing,aif,xiImage(:) );
  modelValues  = reshape(modelValues, size(xiImage ));
  
  % set OOB values
  modelValues(zeroIdx) = 0;
  modelValues(oobIdx)  = aif(length(timing));
  disp(sprintf('model - min %4.1f, max %4.1f, mean %4.1f, var %4.1f', min(modelValues(:)), max(modelValues(:)) , mean(modelValues(:)), std(modelValues(:)) ));

  % accumulate residual 
  currentrawdata = rawdce(kkk,:,:,:);
  %residual( ((kkk-1)*image1Dsize +1):kkk*image1Dsize )= double(currentrawdata(:)) - modelValues(:) ;
  residual    = double(currentrawdata(:)) - double(modelValues(:)) ;
  residual(workarray==0 ) = 0 ; 
  residual(workarray==aifLabelValue) = 0 ; 
  %residualtmp = double(currentrawdata(:)) - double(modelValues(:)) ;
  %residual    = residualtmp(workarray~=0 & workarray~=aifLabelValue); 
 
  % accumulate jacobian 
  derivImage  = interp1(timing,derivaif,xiImage(:) );
  derivImage  = reshape(derivImage, size(xiImage ));
  derivImage(zeroIdx) = 0;
  derivImage(oobIdx)  = derivaif(length(timing));

  % accumulate jacobian 
  derivValuestmp = (distanceImage.* alphaImage.^-2).* derivImage ;
  derivValuestmp =  residual.*derivValuestmp(:);
  jacbuildtmp = [1:length(indlabelval)]';
  jacbuildtmptwo =  jacbuildtmp(workarray~=0 & workarray~=aifLabelValue); 
  indlabelvaltmp =  indlabelval(workarray~=0 & workarray~=aifLabelValue); 
  derivValues    =  derivValuestmp(workarray~=0 & workarray~=aifLabelValue);
  jacobian = sparse(jacbuildtmptwo,indlabelvaltmp,double(derivValues(:)),length(residual),length(x)); 

end

