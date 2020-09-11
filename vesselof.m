
iddata = 1;


jjj = 12;


[ tmpvol metadata ] =  nrrdread(sprintf('Processed/%04d/dynamicG1C4anatomymask.nrrd',iddata));
arclength = niftiread(sprintf('Processed/%04d/arclengthha.nii.gz',iddata));
coords    = squeeze(niftiread(sprintf('Processed/%04d/cmp.nii.gz',iddata)));
dudt      = niftiread(sprintf('Processed/%04d/dt.%04d.nii.gz',iddata,jjj));
gradudx   = squeeze(niftiread(sprintf('Processed/%04d/gradient.%04d.nii.gz',iddata,jjj)));
 
[idx,idy,idz] = ind2sub(size(arclength ), find(arclength > 0 )  );

speed = zeros(length(idx),1);

for iii = 1:length(idx)-1
    nablau    = squeeze(gradudx(idx(iii),idy(iii),idz(iii),:));
    derivudt  = squeeze(dudt(idx(iii),idy(iii),idz(iii)));
    loc0      = squeeze(coords(idx(iii  ),idy(iii  ),idz(iii  ),:));
    loc1      = squeeze(coords(idx(iii+1),idy(iii+1),idz(iii+1),:));
    ehat      = 1/norm(loc1-loc0) * (loc1 - loc0);
    speed(iii)= -derivudt/  (ehat'*nablau    );
end

hist(abs(speed(1:length(speed)-1)),50)


[[1:length(idx) ]' idx idy idz speed] 


