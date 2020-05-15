function [residual,jacobian]= analyticsoln(x,timing,rawdce,aifID,distanceImage,indlabelval,aif,derivaif,aifLabelValue)

%% prepare data structures
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
  
  % TODO
  DeltaT = 1.5;
  xiImage= floor(1/DeltaT *xiImage)+1;
  
  % set OOB values
  xiImage(zeroIdx) = 1;
  xiImage(oobIdx)=length(timing);
  disp(sprintf('min %4.1f, max %4.1f, mean %4.1f, var %4.1f', min(xiImage(:)), max(xiImage(:)) , mean(xiImage(:)), std(xiImage(:)) ));

  % get predictec values
  modelValues = aif(xiImage);

  % accumulate residual 
  currentrawdata = rawdce(kkk,:,:,:);
  %residual( ((kkk-1)*image1Dsize +1):kkk*image1Dsize )= double(currentrawdata(:)) - modelValues(:) ;
  residual = double(currentrawdata(:)) - modelValues(:) ;
  residual(workarray==0 ) = 0 ; 
  residual(workarray==aifLabelValue) = 0 ; 
 
  % accumulate jacobian 
  derivValues = (distanceImage.* alphaImage.^-2).* derivaif(xiImage);
  jacbuildtmp = [1:length(indlabelval)]';
  %jacbuildtmptwo =  jacbuildtmp(workarray~=0 & workarray~=aifLabelValue); 
  %indlabelvaltmp =  indlabelval(workarray~=0 & workarray~=aifLabelValue); 
  jacobian = sparse(jacbuildtmp,indlabelval,double(derivValues(:)),length(indlabelval),length(x)); 

end

