function [residual]= analyticsoln(x,timing,rawdce,distanceImage,alphatmp,indlabelval,subuniqueidx,aif)

%% prepare data structures
alphatmp(subuniqueidx ) = x;
alphaImage = alphatmp(indlabelval);
alphaImage = reshape(alphaImage, size(aifID));

%loop over all time
for kkk  = 1:length(timing)
  %% calculate xi
  xiImage = timing(kkk) - distanceImage.*(alphaImage.^-1);
  
  % negative values are 0
  zeroIdx = find(xiImage < 0);
  % out of bounds 
  oobIdx = find(xiImage > timing(length(timing)));
  
  % TODO
  DeltaT = 1.5;
  xiImage= floor(1/DeltaT *xiImage);
  
  % set OOB values
  xiImage(zeroIdx) = 1;
  xiImage(oobIdx)=length(timing);

  % get predictec values
  modelValues = aif(xiImage);

  % accumulate residual 
  residual =residual + rawdce(kkk,:,:,:) - modelValues ;
end


