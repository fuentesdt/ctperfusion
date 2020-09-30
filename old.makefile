
Processed/%/dynamicSY.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.SY  -n 0 -s MI -t SY -m 60x150x40 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.SY  -n 0 -s MI -t SY -m 60x150x40 > dynamicSY.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

tuning: Processed/0004/dynamicG1C3.nhdr  Processed/0004/dynamicG1C7.nhdr  Processed/0004/dynamicGRC3.nhdr  Processed/0004/dynamicGRC7.nhdr  Processed/0004/dynamicGRCC.nhdr  Processed/0004/dynamicG4C3.nhdr  Processed/0004/dynamicG4C7.nhdr  Processed/0004/dynamicG4CC.nhdr  

Processed/%/dynamicantsreg.nhdr: 
	cd $(@D); ../../antsRegistrationSyN.sh -d 3 -f dynamic.0000.nii.gz  -m dynamic.0033.nii.gz -o antsreg > antsreg.log 2>&1;
	echo /opt/apps/ANTS/dev/install/bin//antsRegistration --verbose 1 --dimensionality 3 --float 0 --collapse-output-transforms 1 --output [ antsreg,antsregWarped.nii.gz,antsregInverseWarped.nii.gz ] --interpolation Linear --use-histogram-matching 0 --winsorize-image-intensities [ 0.005,0.995 ] --initial-moving-transform [ dynamic.0000.nii.gz,dynamic.0033.nii.gz,1 ] --transform Rigid[ 0.1 ] --metric MI[ dynamic.0000.nii.gz,dynamic.0033.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform Affine[ 0.1 ] --metric MI[ dynamic.0000.nii.gz,dynamic.0033.nii.gz,1,32,Regular,0.25 ] --convergence [ 1000x500x250x100,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox --transform SyN[ 0.1,3,0 ] --metric CC[ dynamic.0000.nii.gz,dynamic.0033.nii.gz,1,4 ] --convergence [ 100x70x50x20,1e-6,10 ] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox
	cd $(@D); echo /opt/apps/ANTS/dev/install/bin/antsMotionCorr -v 1 -d 3 -o [motcorr,motcorr.nii.gz] -m gc[ dynamic.0000.nii.gz , dynamic.nrrd , 1 , 1 , Random, 0.05  ] -t Affine[ 0.005 ] -i 20 -u 1 -e 1 -s 0 -f 1  -m CC[  dynamic.0000.nii.gz , dynamic.nrrd , 1 , 2 ] -t GaussianDisplacementField[0.15,3,0.5] -i 20 -u 1 -e 1 -s 0 -f 1 -n 34
	cd $(@D); /opt/apps/ANTS/dev/install/bin/antsMotionCorr -v 1 -d 3 -o [motcorrgcgd,motcorrgcgd.nii.gz,motcorrgcgdavg.nii.gz] -m gc[ dynamic.0000.nii.gz , dynamicc4d.nii.gz , 1 , 1 , Random, 0.05  ] -t Affine[ 0.01 ] -u 1 -i 20 -e 1 -s 0 -f 1  -m CC[  dynamic.0000.nii.gz , dynamicc4d.nii.gz , 1 , 4 ] -t GaussianDisplacementField[0.15,3,0.5] -u 1 -i 20 -e 1 -s 0 -f 1 > origantsmotioncorr.log 2>&1;
	cd $(@D); /opt/apps/ANTS/dev/install/bin/antsMotionCorr -v 1 -d 3 --use-histogram-matching 1 -o [motcorr,motcorr.nii.gz] --transform Rigid[ 0.1 ] --metric MI[ dynamic.0000.nii.gz,dynamicc4d.nii.gz,1,32,Regular,0.25 ] --iterations  500x250x100 -u 1 -e 1 --shrinkFactors 4x2x1 --smoothingSigmas 2x1x0 --transform Affine[ 0.1 ] --metric MI[ dynamic.0000.nii.gz,dynamicc4d.nii.gz,1,32,Regular,0.25 ] --iterations 500x250x100 -u 1 -e 1 --shrinkFactors 4x2x1 --smoothingSigmas 2x1x0 --transform SyN[ 0.3,3,0 ] --metric CC[ dynamic.0000.nii.gz,dynamicc4d.nii.gz,1,4 ] --iterations 70x50x20 -u 1 -e 1 --shrinkFactors 4x2x1 --smoothingSigmas 2x1x0 > antsmotioncorr.log 2>&1;
Processed/%/dynamicG1C3.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G1C3  -n 0 -s C3 -t G1 -m 40x100x30 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G1C3  -n 0 -s C3 -t G1 -m 40x100x30 > dynamicG1C3.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@

Processed/%/dynamicG1C7.nhdr: 
	cd $(@D); for idfile in $$(seq -f "%04g" 0 0); do echo ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G1C7  -n 0 -s C7 -t G1 -m 40x100x30 ;  ../../antsIntroduction.sh -d 3 -r dynamic.0033.nii.gz  -i dynamic.$$idfile.nii.gz    -o dynamic.$$idfile.G1C7  -n 0 -s C7 -t G1 -m 40x100x30 > dynamicG1C7.$$idfile.log 2>&1;  done
	@echo vglrun itksnap -g $(word 2,$^) -o $(basename $(basename $@)).antsintrodeformed.nii.gz
	@echo c3d -verbose $(@D)/dynamic.*.antsintrodeformed.nii.gz $(@D)/dynamic.0033.nii.gz  -omc $@
