function [residual]= analyticsoln(x)


alphaVec = x()
betaVec  = x()

alphatmp(subuniqueidx ) = alphaVec;
betatmp( subuniqueidx ) = betaVec ;

alphaImage = alphatmp(indlabelval);
alphaImage = reshape(alphaImage, size(aifID));

betaImage = betatmp(indlabelval);
betaImage = reshape(betaImage, size(aifID));



modelvalues = alphaImage *. xxx;
