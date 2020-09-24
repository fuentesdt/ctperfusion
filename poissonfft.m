clear all
close all


infomask = niftiinfo('Processed/0001/smoothmask.nii.gz');
vol3d = niftiread(infomask);

infomaskgradx = niftiinfo('Processed/0001/smoothgrad01.nii.gz');
maskgradx = niftiread(infomaskgradx );

infograd = niftiinfo('Processed/0001/testgrad.nii.gz');
grad3d = .1* single(niftiread(infograd));

[kX kY kZ ] = ndgrid([1:infomask.ImageSize(1)] ,[1:infomask.ImageSize(2)],[1:infomask.ImageSize(3)]);

myeps = 1.e-4;

mydenom = 4 * (  sin(pi*(kX-1)/infomask.ImageSize(1)).^2 + sin(pi*(kY-1)/infomask.ImageSize(2)).^2 + sin(pi*(kZ-1)/infomask.ImageSize(3)).^2 ).^(-1);
mydenom (1,1,1) = 0;
maskinverse = (vol3d+myeps).^(-1);

%fftlaplace = i*kX.*mydenom.*  convn( fftn(log(vol3d+myeps)) , fftn(grad3d), 'same');
disp('fftn');
fftlaplace = mydenom.* ( fftn( maskinverse.* maskgradx.*  grad3d  ));
disp('ifftn');
solnvol3d = ifftn(fftlaplace);

infoout = infomask;
infoout.Filename = 'testifft';
infoout.Datatype = 'single';
niftiwrite(solnvol3d  ,infoout.Filename,infoout,'Compressed',true)


