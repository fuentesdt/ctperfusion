function [residual,jacobian]= analyticsoln(x,timing,rawdce,aifID,distanceImage,alphatmp,indlabelval,subuniqueidx,aif,derivaif,jacobianhelper ,mycurrentsoln)

%% prepare data structures
mycurrentsoln = x;
alphatmp(subuniqueidx ) = x;
alphaImage = alphatmp(indlabelval);
alphaImage = reshape(alphaImage, size(aifID));

image1Dsize = length(distanceImage(:));
%loop over all time
%residual= zeros(length(timing)*image1Dsize ,1);
residual= zeros(image1Dsize ,1);
%for kkk  = 1:length(timing)
for kkk  = 10:10
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

  % get predictec values
  modelValues = aif(xiImage);

  % accumulate residual 
  currentrawdata = rawdce(kkk,:,:,:);
  residual( ((kkk-1)*image1Dsize +1):kkk*image1Dsize )= double(currentrawdata(:)) - modelValues(:) ;
 
  % accumulate jacobian 
  derivValues = (distanceImage.* alphaImage.^-2).* derivaif(xiImage);
  jacobian = (jacobianhelper' * double(derivValues(:)))' ;
end

