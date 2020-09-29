clear all
close all

% read label stats
hadata{1} = readtable('Processed/0001/hepaticartery.surfacearea.csv')
hasurface area = hadata{1}.Vol_mm_3(hadata{1}.LabelID==1)
pvdata{1} = readtable('Processed/0001/portalvein.surfacearea.csv')
pvsurface area = pvdata{1}.Vol_mm_3(pvdata{1}.LabelID==1)
lpdata{1} = readtable('Processed/0001/laplacebc.csv')
bvmeasurement = lpdata{1}.Mean(lpdata{1}.LabelID==1)

% read mask info
infomask = niftiinfo('Processed/0001/smoothmask.nii.gz');
vol3d = niftiread(infomask);
nsize = infomask.ImageSize;
spacing = infomask.PixelDimensions;

% read mask gradient info
infograd = niftiinfo('Processed/0001/smoothgrad.nii.gz');
maskgrad = niftiread(infograd);

% read BC info
infolaplacebc = niftiinfo('Processed/0001/laplacebc.nii.gz');
masklaplacebc = niftiread(infolaplacebc );
masklaplacebc(masklaplacebc  == 1) = 0;
masklaplacebc(masklaplacebc  == 2) = 100;
masklaplacebc(masklaplacebc  == 3) =-100;

% setup fourier coefficients
[kX kY kZ ] = ndgrid([1:nsize(1)] ,[1:nsize(2)],[1:nsize(3)]);
mydenom = 4 * (  sin(pi*(kX-1)/nsize(1)).^2/spacing(1) + sin(pi*(kY-1)/nsize(2)).^2/spacing(2)  + sin(pi*(kZ-1)/nsize(3)).^2/spacing(3)  ).^(-1);
mydenom (1,1,1) = 0;

% setup
myeps = 1.e-3;
maskinverse = (vol3d+myeps).^(-1);

%fftlaplace = i*kX.*mydenom.*  convn( fftn(log(vol3d+myeps)) , fftn(grad3d), 'same');
disp('fftn');
fftlaplace = mydenom.* ( fftn( maskinverse.* maskgrad.*  masklaplacebc));
disp('ifftn');
solnvol3d = ifftn(fftlaplace);

infoout = infomask;
infoout.Filename = 'testifft';
infoout.Datatype = 'single';
niftiwrite(solnvol3d  ,infoout.Filename,infoout,'Compressed',true)


