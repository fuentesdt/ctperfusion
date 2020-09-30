function poissonfft( iofilepath )
%iofilepath = 'Processed/0001';
disp( ['iofilepath  = ''',iofilepath ,''';']);      

% read label stats

hadata = readtable(fullfile(iofilepath,'hepaticartery.surfacearea.csv'));
hasurfacearea = hadata.Vol_mm_3(hadata.LabelID==1)
pvdata = readtable(fullfile(iofilepath,'portalvein.surfacearea.csv'));
pvsurfacearea = pvdata.Vol_mm_3(pvdata.LabelID==1)
lpdata = readtable(fullfile(iofilepath,'laplacebc.csv'));
bvmeasurement = lpdata.Mean(lpdata.LabelID==1)

% read mask info
infomask = niftiinfo(fullfile(iofilepath,'smoothmask.nii.gz'))
vol3d = niftiread(infomask);
nsize = infomask.ImageSize;
spacing = infomask.PixelDimensions;

% read mask gradient info
infograd = niftiinfo(fullfile(iofilepath,'smoothgrad.nii.gz'))
maskgrad = niftiread(infograd);

% read BC info
infolaplacebc = niftiinfo(fullfile(iofilepath,'laplacebc.nii.gz'))
poslaplacebc = niftiread(infolaplacebc );
neglaplacebc = niftiread(infolaplacebc );
poslaplacebc(poslaplacebc  == 1) = .5;
poslaplacebc(poslaplacebc  == 2) =  0;
poslaplacebc(poslaplacebc  == 3) = 1.e1;
poslaplacebc(poslaplacebc  == 4) = 0.e0;
poslaplacebc= imgaussfilt3(poslaplacebc,[2 2 1]);
neglaplacebc(neglaplacebc  == 1) = .5;
neglaplacebc(neglaplacebc  == 2) =  0;
neglaplacebc(neglaplacebc  == 3) = 0.e0;
neglaplacebc(neglaplacebc  == 4) = 1.e1;
neglaplacebc= imgaussfilt3(neglaplacebc,[2 2 1]);


% setup fourier coefficients
[kX kY kZ ] = ndgrid([1:nsize(1)] ,[1:nsize(2)],[1:nsize(3)]);
mydenom = 4 * (  sin(pi*(kX-1)/nsize(1)).^2/spacing(1) + sin(pi*(kY-1)/nsize(2)).^2/spacing(2)  + sin(pi*(kZ-1)/nsize(3)).^2/spacing(3)  ).^(-1);
mydenom (1,1,1) = 0;

% setup
myeps = 1.e-8;
maskinverse = (vol3d+myeps).^(-1);
%maskinverse (masklaplacebc  == 0) = 0;

%fftlaplace = i*kX.*mydenom.*  convn( fftn(log(vol3d+myeps)) , fftn(grad3d), 'same');
disp('fftn');
posfftlaplace = mydenom.* ( fftn( maskinverse.* maskgrad.*  single(poslaplacebc)));
nantest = sum(isnan(posfftlaplace(:)) )
negfftlaplace = mydenom.* ( fftn( maskinverse.* maskgrad.*  single(neglaplacebc)));
nantest = sum(isnan(negfftlaplace(:)) )
disp('ifftn');
possolnvol3d = ifftn(posfftlaplace);
negsolnvol3d = ifftn(negfftlaplace);

posinfoout = infomask;
posinfoout.Filename = fullfile(iofilepath,'ifftpos');
posinfoout.Datatype = 'single';
niftiwrite(possolnvol3d  ,posinfoout.Filename,posinfoout,'Compressed',true)

neginfoout = infomask;
neginfoout.Filename = fullfile(iofilepath,'ifftneg');
neginfoout.Datatype = 'single';
niftiwrite(negsolnvol3d  ,neginfoout.Filename,neginfoout,'Compressed',true)


infoout = infomask;
infoout.Filename = fullfile(iofilepath,'ifft');
infoout.Datatype = 'single';
niftiwrite(possolnvol3d - negsolnvol3d  ,infoout.Filename,infoout,'Compressed',true)

end
