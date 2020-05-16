function w = analyticjacmult(Jinfo,Y,flag,timing,rawdce,aifID,distanceImage,alphatmp,indlabelval,subuniqueidx,aif,derivaif,mycurrentsoln)
% This function computes the Jacobian multiply function
% for a 2n-by-n circulant matrix example

if flag > 0
    w = Jpositive(Y);
elseif flag < 0
    w = Jnegative(Y);
else
    w = Jnegative(Jpositive(Y));
end

    function a = Jpositive(q)
        % Calculate C*q
        alphatmp(subuniqueidx ) = q;
        alphaImage = alphatmp(indlabelval);
        alphaImage = reshape(alphaImage, size(aifID));
        
        image1Dsize = length(distanceImage(:));
        %loop over all time
        jacvecmult= zeros(length(timing)*image1Dsize ,1);
        for kkk  = 1:length(timing)
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
          derivValues = (distanceImage.* alphaImage.^-2).* derivaif(xiImage);
        
          % accumulate jacobian 
          currentrawdata = rawdce(kkk,:,:,:);
          jacvecmult( ((kkk-1)*image1Dsize +1):kkk*image1Dsize )= double(currentrawdata(:)) - modelValues(:) ;
        
        end


    end

    function a = Jnegative(q)
        % Calculate C'*q
        disp('non implemented');
        a =0;
    end
end

